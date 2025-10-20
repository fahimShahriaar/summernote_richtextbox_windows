import 'dart:io';
import 'dart:developer' as developer;

/// A custom logger for the Summernote RichTextBox package.
///
/// This logger writes to both console and a file in C:\summernotelogs\
/// for debugging purposes, especially useful for production builds.
class CustomLogger {
  static final CustomLogger _instance = CustomLogger._internal();
  static CustomLogger get instance => _instance;

  CustomLogger._internal();

  File? _logFile;
  bool _initialized = false;

  /// Initializes the logger and creates the log file.
  ///
  /// Creates a daily log file in C:\summernotelogs\
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Create the logs directory
      final logsDir = Directory('C:\\summernotelogs');
      if (!await logsDir.exists()) {
        await logsDir.create(recursive: true);
      }

      // Create or get the log file with current date
      final now = DateTime.now();
      final dateStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      _logFile = File('C:\\summernotelogs\\summernote_logs_$dateStr.txt');

      // Write initial log entry
      await _writeToFile('=== Summernote Rich Text Editor Log Started ===');

      _initialized = true;
      print('Logger initialized: ${_logFile!.path}');
    } catch (e) {
      print('Failed to initialize logger: $e');
    }
  }

  Future<void> _writeToFile(String message) async {
    if (_logFile == null) return;

    try {
      final now = DateTime.now();
      final timestamp = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} '
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}.${now.millisecond.toString().padLeft(3, '0')}';

      final logEntry = '[$timestamp] $message\n';
      await _logFile!.writeAsString(logEntry, mode: FileMode.append);
    } catch (e) {
      print('Failed to write to log file: $e');
    }
  }

  /// Logs a message with the specified level.
  void log(String message, {String level = 'INFO'}) {
    // Print to console as well
    print('[$level] $message');
    developer.log(message, name: 'SummernoteApp');

    // Write to file
    _writeToFile('$level: $message');
  }

  /// Logs a debug message.
  void debug(String message) {
    log(message, level: 'DEBUG');
  }

  /// Logs an info message.
  void info(String message) {
    log(message, level: 'INFO');
  }

  /// Logs a warning message.
  void warning(String message) {
    log(message, level: 'WARNING');
  }

  /// Logs an error message.
  void error(String message) {
    log(message, level: 'ERROR');
  }

  /// Logs a WebView-specific message.
  void webViewLog(String message) {
    log(message, level: 'WEBVIEW');
  }

  /// Logs a JavaScript-specific message.
  void jsLog(String message) {
    log(message, level: 'JAVASCRIPT');
  }
}
