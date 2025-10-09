import 'dart:io';
import 'dart:developer' as developer;

class CustomLogger {
  static final CustomLogger _instance = CustomLogger._internal();
  static CustomLogger get instance => _instance;

  CustomLogger._internal();

  File? _logFile;
  bool _initialized = false;

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

  void log(String message, {String level = 'INFO'}) {
    // Print to console as well
    print('[$level] $message');
    developer.log(message, name: 'SummernoteApp');

    // Write to file
    _writeToFile('$level: $message');
  }

  void debug(String message) {
    log(message, level: 'DEBUG');
  }

  void info(String message) {
    log(message, level: 'INFO');
  }

  void warning(String message) {
    log(message, level: 'WARNING');
  }

  void error(String message) {
    log(message, level: 'ERROR');
  }

  void webViewLog(String message) {
    log(message, level: 'WEBVIEW');
  }

  void jsLog(String message) {
    log(message, level: 'JAVASCRIPT');
  }
}
