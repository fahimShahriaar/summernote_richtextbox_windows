import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

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

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        InAppWebView(
          initialFile: "assets/summernote.html",
          initialSettings: InAppWebViewSettings(
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
            debugPrint("WebView created");

            // Add JavaScript handlers
            controller.addJavaScriptHandler(
              handlerName: 'contentChanged',
              callback: (args) {
                debugPrint("Content changed: ${args.isNotEmpty ? args[0].toString().substring(0, 50) : 'empty'}...");
                if (args.isNotEmpty) {
                  widget.onContentChanged?.call(args[0].toString());
                }
              },
            );

            controller.addJavaScriptHandler(
              handlerName: 'editorReady',
              callback: (args) {
                debugPrint("Editor ready callback received");
                if (mounted) {
                  setState(() {
                    _isLoading = false;
                    _errorMessage = '';
                  });

                  // Set initial content if provided
                  if (widget.initialContent != null) {
                    Future.delayed(const Duration(milliseconds: 500), () {
                      setContent(widget.initialContent!);
                    });
                  }
                }
              },
            );
          },
          onLoadStart: (controller, url) {
            debugPrint("Load started: $url");
          },
          onLoadStop: (controller, url) async {
            debugPrint("Load stopped: $url");
            // Add a timeout fallback in case the editor doesn't initialize
            Future.delayed(const Duration(seconds: 10), () {
              if (mounted && _isLoading) {
                debugPrint("Timeout reached, forcing editor ready");
                setState(() {
                  _isLoading = false;
                  _errorMessage = 'Editor took longer than expected to load, but may still be functional.';
                });
              }
            });
          },
          onLoadError: (controller, url, code, message) {
            debugPrint("Load error: $message");
            if (mounted) {
              setState(() {
                _isLoading = false;
                _errorMessage = 'Failed to load editor: $message';
              });
            }
          },
          onConsoleMessage: (controller, consoleMessage) {
            debugPrint("Console [${consoleMessage.messageLevel}]: ${consoleMessage.message}");
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
    if (_webViewController == null) return null;

    try {
      final result = await _webViewController!.evaluateJavascript(
        source: "window.getContent();",
      );
      return result?.toString();
    } catch (e) {
      debugPrint("Error getting content: $e");
      return null;
    }
  }

  Future<void> setContent(String content) async {
    if (_webViewController == null) return;

    try {
      // Escape the content properly for JavaScript
      final escapedContent = content.replaceAll('\\', '\\\\').replaceAll('`', '\\`').replaceAll('\$', '\\\$');

      await _webViewController!.evaluateJavascript(
        source: "window.setContent(`$escapedContent`);",
      );
    } catch (e) {
      debugPrint("Error setting content: $e");
    }
  }

  Future<void> clearContent() async {
    if (_webViewController == null) return;

    try {
      await _webViewController!.evaluateJavascript(
        source: "window.clearContent();",
      );
    } catch (e) {
      debugPrint("Error clearing content: $e");
    }
  }

  Future<void> execCommand(String command) async {
    if (_webViewController == null) return;

    try {
      await _webViewController!.evaluateJavascript(
        source: "window.execCommand('$command');",
      );
    } catch (e) {
      debugPrint("Error executing command: $e");
    }
  }

  Future<void> insertText(String text) async {
    if (_webViewController == null) return;

    try {
      // Escape the text properly for JavaScript
      final escapedText = text.replaceAll('\\', '\\\\').replaceAll("'", "\\'").replaceAll('\n', '\\n').replaceAll('\r', '\\r');

      await _webViewController!.evaluateJavascript(
        source: "window.insertText('$escapedText');",
      );
    } catch (e) {
      debugPrint("Error inserting text: $e");
    }
  }
}
