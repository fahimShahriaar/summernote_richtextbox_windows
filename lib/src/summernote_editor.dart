import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:path_provider/path_provider.dart';
import 'summernote_controller.dart';

WebViewEnvironment? webViewEnvironment;

/// A rich text editor widget that uses Summernote with WebView integration.
///
/// This widget provides a WYSIWYG editor interface powered by Summernote.js
/// and is designed to work specifically with Windows desktop applications.
class SummernoteEditor extends StatefulWidget {
  /// Controller for managing the editor's content and operations.
  final SummernoteController? controller;

  /// Callback function that is called when the content of the editor changes.
  final Function(String)? onContentChanged;

  /// Callback function that is called when the editor gains focus (focus event).
  /// The callback receives the current content as a parameter.
  final Function(String)? onFocus;

  /// Callback function that is called when the editor loses focus (blur event).
  /// The callback receives the current content as a parameter.
  final Function(String)? onBlur;

  /// Initial content to display in the editor when it loads.
  final String? initialContent;

  /// Creates a new SummernoteEditor widget.
  ///
  /// [controller] is optional. If not provided, the widget will create its own controller.
  /// [onContentChanged] is called whenever the user modifies the editor content.
  /// [onFocus] is called when the editor gains focus, providing the current content.
  /// [onBlur] is called when the editor loses focus, providing the current content.
  /// [initialContent] can be used to pre-populate the editor with HTML content.
  const SummernoteEditor({
    super.key,
    this.controller,
    this.onContentChanged,
    this.onFocus,
    this.onBlur,
    this.initialContent,
  });

  @override
  State<SummernoteEditor> createState() => SummernoteEditorState();
}

/// The state class for [SummernoteEditor].
class SummernoteEditorState extends State<SummernoteEditor> {
  bool _isLoading = true;
  String _errorMessage = '';
  bool _webViewEnvironmentReady = false;
  late SummernoteController _controller;

  void initializeWindowsWebViewEnvironment() async {
    log('Initializing Windows WebView Environment...');

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.windows) {
      try {
        final availableVersion = await WebViewEnvironment.getAvailableVersion();
        log('WebView2 available version: $availableVersion');

        assert(availableVersion != null, 'Failed to find an installed WebView2 Runtime or non-stable Microsoft Edge installation.');

        final appDataDir = await getApplicationSupportDirectory();
        log('App data directory: ${appDataDir.path}');

        webViewEnvironment = await WebViewEnvironment.create(
          settings: WebViewEnvironmentSettings(userDataFolder: '${appDataDir.path}\\EBWebView'),
        );

        log('WebView Environment created successfully');

        // Update state to indicate WebView environment is ready
        if (mounted) {
          setState(() {
            _webViewEnvironmentReady = true;
          });
        }
      } catch (e) {
        log('Failed to initialize WebView Environment: $e');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    log('SummernoteEditor initState called');

    // Initialize controller
    _controller = widget.controller ?? SummernoteController();

    initializeWindowsWebViewEnvironment();
  }

  @override
  Widget build(BuildContext context) {
    log('Inside Widget build (SummernoteEditor widget) - WebView ready: $_webViewEnvironmentReady');

    return Stack(
      children: [
        if (!Platform.isWindows || _webViewEnvironmentReady)
          InAppWebView(
            initialFile: "packages/summernote_richtextbox/assets/summernote.html",
            webViewEnvironment: Platform.isWindows ? webViewEnvironment : null,
            initialSettings: InAppWebViewSettings(
              allowUniversalAccessFromFileURLs: true,
              allowFileAccessFromFileURLs: true,
              allowFileAccess: true,
              transparentBackground: true,
              disableContextMenu: false,
              supportZoom: false,
              allowsInlineMediaPlayback: true,
              mediaPlaybackRequiresUserGesture: false,
              clearCache: false,
              javaScriptEnabled: true,
              domStorageEnabled: true,
              allowsLinkPreview: false,
              iframeAllow: "camera; microphone",
              iframeAllowFullscreen: true,
            ),
            onWebViewCreated: (controller) {
              _controller.attachWebViewController(controller);
              log("WebView created successfully");

              // Add JavaScript handlers
              controller.addJavaScriptHandler(
                handlerName: 'contentChanged',
                callback: (args) {
                  if (args.isNotEmpty) {
                    final content = args[0].toString();
                    log("Content changed: ${content.substring(0, content.length > 100 ? 100 : content.length)}${content.length > 100 ? '...' : ''}");

                    // Update controller
                    _controller.updateContent(content);

                    // Call widget callback
                    widget.onContentChanged?.call(content);
                  }
                },
              );

              controller.addJavaScriptHandler(
                handlerName: 'editorReady',
                callback: (args) {
                  log("Editor ready callback received");
                  if (mounted) {
                    setState(() {
                      _isLoading = false;
                      _errorMessage = '';
                    });
                    _controller.setReady(true);
                    log("Editor loading state set to false");

                    // Set initial content if provided
                    if (widget.initialContent != null) {
                      log("Setting initial content: ${widget.initialContent!.substring(0, widget.initialContent!.length > 50 ? 50 : widget.initialContent!.length)}${widget.initialContent!.length > 50 ? '...' : ''}");
                      Future.delayed(const Duration(milliseconds: 500), () {
                        _controller.setContent(widget.initialContent!);
                      });
                    }
                  }
                },
              );

              controller.addJavaScriptHandler(
                handlerName: 'editorFocused',
                callback: (args) {
                  if (args.isNotEmpty) {
                    final content = args[0].toString();
                    log("Editor focused with content: ${content.substring(0, content.length > 100 ? 100 : content.length)}${content.length > 100 ? '...' : ''}");

                    // Update controller
                    _controller.updateContent(content);

                    // Call widget focus callback if provided
                    widget.onFocus?.call(content);
                  }
                },
              );

              controller.addJavaScriptHandler(
                handlerName: 'editorBlurred',
                callback: (args) {
                  if (args.isNotEmpty) {
                    final content = args[0].toString();
                    log("Editor blurred with content: ${content.substring(0, content.length > 100 ? 100 : content.length)}${content.length > 100 ? '...' : ''}");

                    // Update controller
                    _controller.updateContent(content);

                    // Call widget blur callback if provided
                    widget.onBlur?.call(content);
                  }
                },
              );
            },
            onLoadStart: (controller, url) {
              log("Load started: $url");
            },
            onLoadStop: (controller, url) async {
              log("Load stopped: $url");
              // Add a timeout fallback in case the editor doesn't initialize
              Future.delayed(const Duration(seconds: 10), () {
                if (mounted && _isLoading) {
                  log("Timeout reached, forcing editor ready");
                  setState(() {
                    _isLoading = false;
                    _errorMessage = 'Editor took longer than expected to load, but may still be functional.';
                  });
                }
              });
            },
            onLoadError: (controller, url, code, message) {
              log("Load error - URL: $url, Code: $code, Message: $message");
              if (mounted) {
                setState(() {
                  _isLoading = false;
                  _errorMessage = 'Failed to load editor: $message';
                });
              }
            },
            onConsoleMessage: (controller, consoleMessage) {
              log("Console [${consoleMessage.messageLevel}]: ${consoleMessage.message}");
            },
          ),
        if (_isLoading || (Platform.isWindows && !_webViewEnvironmentReady))
          Container(
            color: Colors.white,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    Platform.isWindows && !_webViewEnvironmentReady ? 'Initializing WebView environment...' : 'Loading editor...',
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 14,
                    ),
                  ),
                  if (_errorMessage.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      _errorMessage,
                      style: const TextStyle(
                        color: Color(0xFFDC2626),
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }

  /// Gets the controller for this editor.
  ///
  /// This provides access to all editor operations like getContent, setContent, etc.
  SummernoteController getController() => _controller;

  /// Sets a new controller for this editor.
  ///
  /// This allows dynamic controller replacement if needed.
  void setController(SummernoteController newController) {
    _controller = newController;
  }

  @override
  void dispose() {
    log("SummernoteEditor disposed");
    super.dispose();
  }
}
