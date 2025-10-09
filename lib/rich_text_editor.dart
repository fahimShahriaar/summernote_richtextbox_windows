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

  void initializeWindowsWebViewEnvironment() async {
    CustomLogger.instance.info('Initializing Windows WebView Environment...');

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.windows) {
      try {
        final availableVersion = await WebViewEnvironment.getAvailableVersion();
        CustomLogger.instance.info('WebView2 available version: $availableVersion');

        assert(availableVersion != null, 'Failed to find an installed WebView2 Runtime or non-stable Microsoft Edge installation.');

        final appDataDir = await getApplicationSupportDirectory();
        CustomLogger.instance.info('App data directory: ${appDataDir.path}');

        webViewEnvironment = await WebViewEnvironment.create(
          settings: WebViewEnvironmentSettings(userDataFolder: '${appDataDir.path}\\EBWebView'),
        );

        CustomLogger.instance.info('WebView Environment created successfully');
      } catch (e) {
        CustomLogger.instance.error('Failed to initialize WebView Environment: $e');
      }

      /* this.setState(() {
        isLoading = false;
      }); */
    }
  }

  @override
  void initState() {
    super.initState();
    CustomLogger.instance.info('RichTextEditor initState called');
    initializeWindowsWebViewEnvironment();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
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
            CustomLogger.instance.webViewLog("WebView created successfully");

            // Add JavaScript handlers
            controller.addJavaScriptHandler(
              handlerName: 'contentChanged',
              callback: (args) {
                CustomLogger.instance.jsLog("Content changed: ${args.isNotEmpty ? args[0].toString().substring(0, args[0].toString().length > 100 ? 100 : args[0].toString().length) : 'empty'}${args.isNotEmpty && args[0].toString().length > 100 ? '...' : ''}");
                if (args.isNotEmpty) {
                  widget.onContentChanged?.call(args[0].toString());
                }
              },
            );

            controller.addJavaScriptHandler(
              handlerName: 'editorReady',
              callback: (args) {
                CustomLogger.instance.webViewLog("Editor ready callback received");
                if (mounted) {
                  setState(() {
                    _isLoading = false;
                    _errorMessage = '';
                  });
                  CustomLogger.instance.info("Editor loading state set to false");

                  // Set initial content if provided
                  if (widget.initialContent != null) {
                    CustomLogger.instance.info("Setting initial content: ${widget.initialContent!.substring(0, widget.initialContent!.length > 50 ? 50 : widget.initialContent!.length)}${widget.initialContent!.length > 50 ? '...' : ''}");
                    Future.delayed(const Duration(milliseconds: 500), () {
                      setContent(widget.initialContent!);
                    });
                  }
                }
              },
            );
          },
          onLoadStart: (controller, url) {
            CustomLogger.instance.webViewLog("Load started: $url");
          },
          onLoadStop: (controller, url) async {
            CustomLogger.instance.webViewLog("Load stopped: $url");
            // Add a timeout fallback in case the editor doesn't initialize
            Future.delayed(const Duration(seconds: 10), () {
              if (mounted && _isLoading) {
                CustomLogger.instance.warning("Timeout reached, forcing editor ready");
                setState(() {
                  _isLoading = false;
                  _errorMessage = 'Editor took longer than expected to load, but may still be functional.';
                });
              }
            });
          },
          onLoadError: (controller, url, code, message) {
            CustomLogger.instance.error("Load error - URL: $url, Code: $code, Message: $message");
            if (mounted) {
              setState(() {
                _isLoading = false;
                _errorMessage = 'Failed to load editor: $message';
              });
            }
          },
          onConsoleMessage: (controller, consoleMessage) {
            CustomLogger.instance.jsLog("Console [${consoleMessage.messageLevel}]: ${consoleMessage.message}");
          },
        ),
        if (_isLoading)
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
                  const Text(
                    'Loading editor...',
                    style: TextStyle(
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
      CustomLogger.instance.warning("getContent called but webViewController is null");
      return null;
    }

    try {
      CustomLogger.instance.debug("Getting content from editor");
      final result = await _webViewController!.evaluateJavascript(
        source: "window.getContent();",
      );
      CustomLogger.instance.debug("Content retrieved successfully");
      return result?.toString();
    } catch (e) {
      CustomLogger.instance.error("Error getting content: $e");
      return null;
    }
  }

  Future<void> setContent(String content) async {
    if (_webViewController == null) {
      CustomLogger.instance.warning("setContent called but webViewController is null");
      return;
    }

    try {
      CustomLogger.instance.debug("Setting content: ${content.substring(0, content.length > 100 ? 100 : content.length)}${content.length > 100 ? '...' : ''}");
      // Escape the content properly for JavaScript
      final escapedContent = content.replaceAll('\\', '\\\\').replaceAll('`', '\\`').replaceAll('\$', '\\\$');

      await _webViewController!.evaluateJavascript(
        source: "window.setContent(`$escapedContent`);",
      );
      CustomLogger.instance.debug("Content set successfully");
    } catch (e) {
      CustomLogger.instance.error("Error setting content: $e");
    }
  }

  Future<void> clearContent() async {
    if (_webViewController == null) {
      CustomLogger.instance.warning("clearContent called but webViewController is null");
      return;
    }

    try {
      CustomLogger.instance.debug("Clearing editor content");
      await _webViewController!.evaluateJavascript(
        source: "window.clearContent();",
      );
      CustomLogger.instance.debug("Content cleared successfully");
    } catch (e) {
      CustomLogger.instance.error("Error clearing content: $e");
    }
  }

  Future<void> execCommand(String command) async {
    if (_webViewController == null) {
      CustomLogger.instance.warning("execCommand called but webViewController is null");
      return;
    }

    try {
      CustomLogger.instance.debug("Executing command: $command");
      await _webViewController!.evaluateJavascript(
        source: "window.execCommand('$command');",
      );
      CustomLogger.instance.debug("Command executed successfully: $command");
    } catch (e) {
      CustomLogger.instance.error("Error executing command '$command': $e");
    }
  }

  Future<void> insertText(String text) async {
    if (_webViewController == null) {
      CustomLogger.instance.warning("insertText called but webViewController is null");
      return;
    }

    try {
      CustomLogger.instance.debug("Inserting text: ${text.substring(0, text.length > 50 ? 50 : text.length)}${text.length > 50 ? '...' : ''}");
      // Escape the text properly for JavaScript
      final escapedText = text.replaceAll('\\', '\\\\').replaceAll("'", "\\'").replaceAll('\n', '\\n').replaceAll('\r', '\\r');

      await _webViewController!.evaluateJavascript(
        source: "window.insertText('$escapedText');",
      );
      CustomLogger.instance.debug("Text inserted successfully");
    } catch (e) {
      CustomLogger.instance.error("Error inserting text: $e");
    }
  }

  @override
  void dispose() {
    CustomLogger.instance.info("RichTextEditor disposed");
    super.dispose();
  }
}
