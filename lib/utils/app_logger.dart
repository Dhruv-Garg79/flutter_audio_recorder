import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart' as Log;

class AppLogger {
  static final AppLogger _loggerInstance = AppLogger._makeInstance();
  static bool _showLogs = true;

  factory AppLogger() {
    return _loggerInstance;
  }

  AppLogger._makeInstance();

  static void showLogs(bool val) {
    _showLogs = val;
  }

  static final _logger = Log.Logger(
    printer: Log.PrettyPrinter(
      printEmojis: true,
      printTime: false,
      methodCount: 0,
    ),
  );

  static void print(dynamic value) {
    if (!kReleaseMode && _showLogs) {
      _logger.d(value.toString());
    }
  }

  static void error(e, s) {
    if (!kReleaseMode && _showLogs) {
      _logger.e(e, s);
    }
  }
}
