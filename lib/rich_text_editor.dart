import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class RichTextEditor extends StatefulWidget {
  final Function(String)? onContentChanged;
  final String? initialContent;

  const RichTextEditor({
    Key? key,
    this.onContentChanged,
    this.initialContent,
  }) : super(key: key);

  @override
  State<RichTextEditor> createState() => RichTextEditorState();
}

class RichTextEditorState extends State<RichTextEditor> {
  InAppWebViewController? _webViewController;
  bool _isLoading = true;

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
            // debuggingEnabled: false,
          ),
          onWebViewCreated: (controller) {
            _webViewController = controller;

            // Add JavaScript handlers
            controller.addJavaScriptHandler(
              handlerName: 'contentChanged',
              callback: (args) {
                if (args.isNotEmpty) {
                  widget.onContentChanged?.call(args[0].toString());
                }
              },
            );

            controller.addJavaScriptHandler(
              handlerName: 'editorReady',
              callback: (args) {
                setState(() {
                  _isLoading = false;
                });

                // Set initial content if provided
                if (widget.initialContent != null) {
                  setContent(widget.initialContent!);
                }
              },
            );
          },
          onLoadStop: (controller, url) async {
            // WebView has finished loading
          },
          onConsoleMessage: (controller, consoleMessage) {
            debugPrint("Console: ${consoleMessage.message}");
          },
        ),
        if (_isLoading)
          Container(
            color: Colors.white,
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Loading editor...',
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 14,
                    ),
                  ),
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
      await _webViewController!.evaluateJavascript(
        source: "window.setContent(`$content`);",
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
      await _webViewController!.evaluateJavascript(
        source: "window.insertText('$text');",
      );
    } catch (e) {
      debugPrint("Error inserting text: $e");
    }
  }
}
