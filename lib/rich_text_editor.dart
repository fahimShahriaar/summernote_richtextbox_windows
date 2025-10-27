import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:path_provider/path_provider.dart';
import 'logger.dart';

WebViewEnvironment? webViewEnvironment;

class RichTextEditor extends StatefulWidget {
  final Function(String)? onContentChanged;
  final String? initialContent;

  const RichTextEditor({
    super.key,
    this.onContentChanged,
    this.initialContent,
  });

  @override
  State<RichTextEditor> createState() => RichTextEditorState();
}

class RichTextEditorState extends State<RichTextEditor> {
  InAppWebViewController? _webViewController;
  bool _isLoading = true;
  String _errorMessage = '';
  bool _webViewEnvironmentReady = false;

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
    log('RichTextEditor initState called');
    initializeWindowsWebViewEnvironment();
  }

  @override
  Widget build(BuildContext context) {
    log('Building RichTextEditor widget - WebView ready: $_webViewEnvironmentReady');

    return Stack(
      children: [
        if (!Platform.isWindows || _webViewEnvironmentReady)
          InAppWebView(
            initialFile: "assets/summernote.html",
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
              _webViewController = controller;
              log("WebView created successfully");

              // Add JavaScript handlers
              controller.addJavaScriptHandler(
                handlerName: 'contentChanged',
                callback: (args) {
                  log("Content changed: ${args.isNotEmpty ? args[0].toString().substring(0, args[0].toString().length > 100 ? 100 : args[0].toString().length) : 'empty'}${args.isNotEmpty && args[0].toString().length > 100 ? '...' : ''}");
                  if (args.isNotEmpty) {
                    widget.onContentChanged?.call(args[0].toString());
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
                    log("Editor loading state set to false");

                    // Set initial content if provided
                    if (widget.initialContent != null) {
                      log("Setting initial content: ${widget.initialContent!.substring(0, widget.initialContent!.length > 50 ? 50 : widget.initialContent!.length)}${widget.initialContent!.length > 50 ? '...' : ''}");
                      Future.delayed(const Duration(milliseconds: 500), () {
                        setContent(widget.initialContent!);
                      });
                    }
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

  Future<String?> getContent() async {
    if (_webViewController == null) {
      log("getContent called but webViewController is null");
      return null;
    }

    try {
      log("Getting content from editor");
      final result = await _webViewController!.evaluateJavascript(
        source: "window.getContent();",
      );
      log("Content retrieved successfully");
      return result?.toString();
    } catch (e) {
      log("Error getting content: $e");
      return null;
    }
  }

  Future<void> setContent(String content) async {
    if (_webViewController == null) {
      log("setContent called but webViewController is null");
      return;
    }

    try {
      log("Setting content: ${content.substring(0, content.length > 100 ? 100 : content.length)}${content.length > 100 ? '...' : ''}");
      // Escape the content properly for JavaScript
      final escapedContent = content.replaceAll('\\', '\\\\').replaceAll('`', '\\`').replaceAll('\$', '\\\$');

      await _webViewController!.evaluateJavascript(
        source: "window.setContent(`$escapedContent`);",
      );
      log("Content set successfully");
    } catch (e) {
      log("Error setting content: $e");
    }
  }

  Future<void> clearContent() async {
    if (_webViewController == null) {
      log("clearContent called but webViewController is null");
      return;
    }

    try {
      log("Clearing editor content");
      await _webViewController!.evaluateJavascript(
        source: "window.clearContent();",
      );
      log("Content cleared successfully");
    } catch (e) {
      log("Error clearing content: $e");
    }
  }

  Future<void> execCommand(String command) async {
    if (_webViewController == null) {
      log("execCommand called but webViewController is null");
      return;
    }

    try {
      log("Executing command: $command");
      await _webViewController!.evaluateJavascript(
        source: "window.execCommand('$command');",
      );
      log("Command executed successfully: $command");
    } catch (e) {
      log("Error executing command '$command': $e");
    }
  }

  Future<void> insertText(String text) async {
    if (_webViewController == null) {
      log("insertText called but webViewController is null");
      return;
    }

    try {
      log("Inserting text: ${text.substring(0, text.length > 50 ? 50 : text.length)}${text.length > 50 ? '...' : ''}");
      // Escape the text properly for JavaScript
      final escapedText = text.replaceAll('\\', '\\\\').replaceAll("'", "\\'").replaceAll('\n', '\\n').replaceAll('\r', '\\r');

      await _webViewController!.evaluateJavascript(
        source: "window.insertText('$escapedText');",
      );
      log("Text inserted successfully");
    } catch (e) {
      log("Error inserting text: $e");
    }
  }

  @override
  void dispose() {
    log("RichTextEditor disposed");
    super.dispose();
  }
}
