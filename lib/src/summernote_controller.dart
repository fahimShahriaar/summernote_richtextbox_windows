import 'dart:developer';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';

/// Controller for the SummernoteEditor widget.
///
/// This controller provides methods to interact with the editor programmatically.
/// Use this controller to get and set content, execute commands, and control the editor.
class SummernoteController {
  InAppWebViewController? _webViewController;
  bool _isReady = false;

  /// Whether the editor is ready to receive commands.
  bool get isReady => _isReady;

  /// Internal method called by the widget to set the WebView controller.
  /// This method should only be called by SummernoteEditor.
  void attachWebViewController(InAppWebViewController controller) {
    _webViewController = controller;
  }

  /// Internal method called by the widget when the editor is ready.
  /// This method should only be called by SummernoteEditor.
  void setReady(bool ready) {
    _isReady = ready;
  }

  /// Internal method called by the widget when content changes.
  /// This method should only be called by SummernoteEditor.
  /// Note: Content changes are handled through the onContentChanged callback.
  void updateContent(String newContent) {
    // Content updates are handled through callbacks, no need to store internally
  }

  /// Gets the current HTML content from the editor.
  ///
  /// Returns the HTML string content, or null if the editor is not ready.
  Future<String?> getContent() async {
    if (_webViewController == null) {
      log("getContent called but webViewController is null");
      return null;
    }

    try {
      log("Getting content from editor via controller");
      final result = await _webViewController!.evaluateJavascript(
        source: "window.getContent();",
      );
      log("Content retrieved successfully via controller");
      final content = result?.toString();
      return content;
    } catch (e) {
      log("Error getting content via controller: $e");
      return null;
    }
  }

  /// Sets the HTML content of the editor.
  ///
  /// [content] should be a valid HTML string.
  Future<void> setContent(String content) async {
    if (_webViewController == null) {
      log("setContent called but webViewController is null");
      return;
    }

    try {
      log("Setting content via controller: ${content.substring(0, content.length > 100 ? 100 : content.length)}${content.length > 100 ? '...' : ''}");
      // Escape the content properly for JavaScript
      final escapedContent = content.replaceAll('\\', '\\\\').replaceAll('`', '\\`').replaceAll('\$', '\\\$');

      await _webViewController!.evaluateJavascript(
        source: "window.setContent(`$escapedContent`);",
      );
      log("Content set successfully via controller");
    } catch (e) {
      log("Error setting content via controller: $e");
    }
  }

  /// Clears all content from the editor.
  Future<void> clearContent() async {
    if (_webViewController == null) {
      log("clearContent called but webViewController is null");
      return;
    }

    try {
      log("Clearing editor content via controller");
      await _webViewController!.evaluateJavascript(
        source: "window.clearContent();",
      );
      log("Content cleared successfully via controller");
    } catch (e) {
      log("Error clearing content via controller: $e");
    }
  }

  /// Executes a Summernote command.
  ///
  /// [command] should be a valid Summernote command like 'bold', 'italic', etc.
  Future<void> execCommand(String command) async {
    if (_webViewController == null) {
      log("execCommand called but webViewController is null");
      return;
    }

    try {
      log("Executing command via controller: $command");
      await _webViewController!.evaluateJavascript(
        source: "window.execCommand('$command');",
      );
      log("Command executed successfully via controller: $command");
    } catch (e) {
      log("Error executing command '$command' via controller: $e");
    }
  }

  /// Inserts text at the current cursor position in the editor.
  ///
  /// [text] is the plain text to insert.
  Future<void> insertText(String text) async {
    if (_webViewController == null) {
      log("insertText called but webViewController is null");
      return;
    }

    try {
      log("Inserting text via controller: ${text.substring(0, text.length > 50 ? 50 : text.length)}${text.length > 50 ? '...' : ''}");
      // Escape the text properly for JavaScript
      final escapedText = text.replaceAll('\\', '\\\\').replaceAll("'", "\\'").replaceAll('\n', '\\n').replaceAll('\r', '\\r');

      await _webViewController!.evaluateJavascript(
        source: "window.insertText('$escapedText');",
      );
      log("Text inserted successfully via controller");
    } catch (e) {
      log("Error inserting text via controller: $e");
    }
  }

  /// Inserts HTML content at the current cursor position.
  ///
  /// [html] should be valid HTML string.
  Future<void> insertHtml(String html) async {
    if (_webViewController == null) {
      log("insertHtml called but webViewController is null");
      return;
    }

    try {
      log("Inserting HTML via controller: ${html.substring(0, html.length > 50 ? 50 : html.length)}${html.length > 50 ? '...' : ''}");
      // Escape the HTML properly for JavaScript
      final escapedHtml = html.replaceAll('\\', '\\\\').replaceAll('`', '\\`').replaceAll('\$', '\\\$');

      await _webViewController!.evaluateJavascript(
        source: "window.insertHtml(`$escapedHtml`);",
      );
      log("HTML inserted successfully via controller");
    } catch (e) {
      log("Error inserting HTML via controller: $e");
    }
  }

  /// Focuses the editor.
  Future<void> focus() async {
    if (_webViewController == null) {
      log("focus called but webViewController is null");
      return;
    }

    try {
      await _webViewController!.evaluateJavascript(
        source: "window.focusEditor();",
      );
      log("Editor focused via controller");
    } catch (e) {
      log("Error focusing editor via controller: $e");
    }
  }

  /// Blurs (unfocuses) the editor.
  Future<void> blur() async {
    if (_webViewController == null) {
      log("blur called but webViewController is null");
      return;
    }

    try {
      await _webViewController!.evaluateJavascript(
        source: "window.blurEditor();",
      );
      log("Editor blurred via controller");
    } catch (e) {
      log("Error blurring editor via controller: $e");
    }
  }

  /// Cleanup method to be called when the controller is no longer needed.
  void dispose() {
    log("SummernoteController disposed");
    _webViewController = null;
  }
}
