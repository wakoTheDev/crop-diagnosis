import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

/// Log levels for the application
enum LogLevel {
  debug,
  info,
  warning,
  error,
  fatal,
}

/// Professional logging service for production-ready applications
/// Provides structured logging with different log levels and automatic timestamp formatting
class LoggerService {
  static final LoggerService _instance = LoggerService._internal();
  factory LoggerService() => _instance;
  LoggerService._internal();

  /// Minimum log level to display (can be configured per environment)
  LogLevel _minLogLevel = kDebugMode ? LogLevel.debug : LogLevel.info;

  /// Date formatter for log timestamps
  final DateFormat _dateFormatter = DateFormat('yyyy-MM-dd HH:mm:ss.SSS');

  /// Set the minimum log level
  void setMinLogLevel(LogLevel level) {
    _minLogLevel = level;
  }

  /// Log a debug message (only visible in debug mode)
  void debug(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.debug, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  /// Log an informational message
  void info(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.info, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  /// Log a warning message
  void warning(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.warning, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  /// Log an error message
  void error(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.error, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  /// Log a fatal error message
  void fatal(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.fatal, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  /// Internal logging method
  void _log(
    LogLevel level,
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    // Check if this log level should be displayed
    if (level.index < _minLogLevel.index) return;

    final timestamp = _dateFormatter.format(DateTime.now());
    final levelStr = _getLevelString(level);
    final tagStr = tag != null ? '[$tag]' : '';
    
    // Build the log message
    final logMessage = '$timestamp $levelStr $tagStr $message';

    // Output based on log level
    if (level == LogLevel.error || level == LogLevel.fatal) {
      debugPrint(' $logMessage');
      if (error != null) {
        debugPrint('   Error: $error');
      }
      if (stackTrace != null) {
        debugPrint('   Stack trace:\n$stackTrace');
      }
    } else if (level == LogLevel.warning) {
      debugPrint('  $logMessage');
      if (error != null) {
        debugPrint('   Details: $error');
      }
    } else if (level == LogLevel.info) {
      debugPrint('  $logMessage');
    } else {
      debugPrint('  $logMessage');
    }

    // In production, you could also:
    // - Send logs to a remote logging service (e.g., Firebase Crashlytics, Sentry)
    // - Write logs to a file
    // - Store logs in a local database
  }

  /// Get string representation of log level
  String _getLevelString(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return '[DEBUG]';
      case LogLevel.info:
        return '[INFO] ';
      case LogLevel.warning:
        return '[WARN] ';
      case LogLevel.error:
        return '[ERROR]';
      case LogLevel.fatal:
        return '[FATAL]';
    }
  }

  /// Log a method entry (useful for debugging flow)
  void methodEntry(String className, String methodName, {Map<String, dynamic>? params}) {
    if (!kDebugMode) return;
    
    final paramsStr = params != null ? ' with params: $params' : '';
    debug('→ Entering $className.$methodName$paramsStr', tag: 'Flow');
  }

  /// Log a method exit (useful for debugging flow)
  void methodExit(String className, String methodName, {dynamic result}) {
    if (!kDebugMode) return;
    
    final resultStr = result != null ? ' returning: $result' : '';
    debug('← Exiting $className.$methodName$resultStr', tag: 'Flow');
  }

  /// Log API request
  void apiRequest(String method, String endpoint, {Map<String, dynamic>? data}) {
    info('API Request: $method $endpoint', tag: 'API');
    if (data != null && kDebugMode) {
      debug('Request data: $data', tag: 'API');
    }
  }

  /// Log API response
  void apiResponse(String endpoint, int statusCode, {dynamic data}) {
    if (statusCode >= 200 && statusCode < 300) {
      info('API Response: $endpoint - $statusCode', tag: 'API');
    } else {
      warning('API Response: $endpoint - $statusCode', tag: 'API');
    }
    if (data != null && kDebugMode) {
      debug('Response data: $data', tag: 'API');
    }
  }

  /// Log API error
  void apiError(String endpoint, Object error, {StackTrace? stackTrace}) {
    this.error('API Error: $endpoint', tag: 'API', error: error, stackTrace: stackTrace);
  }
}

/// Global logger instance for easy access
final logger = LoggerService();
