import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class AppDebugLogger {
  static const String _yellow = '\u001B[33m';
  static const String _reset = '\u001B[0m';
  static const int _chunkSize = 800;
  static const int _defaultMaxLines = 200;

  static void log(
    String title, {
    Object? data,
    Map<String, Object?> extra = const <String, Object?>{},
    int maxLines = _defaultMaxLines,
  }) {
    if (!kDebugMode) {
      return;
    }

    final lines = <String>['$title${_formatValue(data)}'];

    for (final entry in extra.entries) {
      lines.add('${entry.key}:${_formatValue(entry.value)}');
    }

    _printLines(lines, maxLines: maxLines);
  }

  static void apiRequest(RequestOptions options, {String scope = 'REQUEST'}) {
    log(
      '⚡ [$scope] ${options.method} ${options.uri}',
      extra: {
        'Headers': options.headers,
        if (options.queryParameters.isNotEmpty)
          'Query': options.queryParameters,
        if (options.data != null) 'Body': options.data,
      },
    );
  }

  static void apiResponse(
    Response<dynamic> response, {
    String scope = 'RESPONSE',
  }) {
    log(
      '⚡ [$scope] ${response.statusCode} ${response.requestOptions.method} ${response.requestOptions.uri}',
      extra: {'Data': response.data},
    );
  }

  static void apiError(DioException error, {String scope = 'ERROR'}) {
    log(
      '⚡ [$scope] ${error.response?.statusCode} ${error.requestOptions.method} ${error.requestOptions.uri}',
      extra: {
        'Message': error.message,
        if (error.response?.data != null) 'Response': error.response?.data,
      },
    );
  }

  static String _formatValue(Object? value) {
    if (value == null) {
      return '';
    }

    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) {
        return ' ';
      }

      try {
        final decoded = jsonDecode(trimmed);
        return '\n${const JsonEncoder.withIndent('  ').convert(decoded)}';
      } catch (_) {
        return ' $value';
      }
    }

    if (value is Map || value is List) {
      try {
        return '\n${const JsonEncoder.withIndent('  ').convert(value)}';
      } catch (_) {
        return ' $value';
      }
    }

    if (value is FormData) {
      final formDataMap = <String, Object?>{
        'fields': value.fields.map((e) => {e.key: e.value}).toList(),
        'files': value.files
            .map(
              (entry) => {
                'key': entry.key,
                'filename': entry.value.filename,
                'contentType': entry.value.contentType?.toString(),
                'length': entry.value.length,
              },
            )
            .toList(),
      };
      return '\n${const JsonEncoder.withIndent('  ').convert(formDataMap)}';
    }

    return ' $value';
  }

  static void _printLines(
    List<String> messages, {
    int maxLines = _defaultMaxLines,
  }) {
    var printedLines = 0;

    for (final message in messages) {
      if (printedLines >= maxLines) break;

      final safeMessage = message.replaceAll('\r\n', '\n');
      final lines = safeMessage.split('\n');

      for (final line in lines) {
        if (printedLines >= maxLines) {
          debugPrintSynchronously(
            '$_yellow... (truncated, exceeded $maxLines lines)$_reset',
          );
          return;
        }

        if (line.isEmpty) {
          debugPrintSynchronously('$_yellow$_reset');
          printedLines++;
          continue;
        }

        for (var start = 0; start < line.length; start += _chunkSize) {
          final end = (start + _chunkSize < line.length)
              ? start + _chunkSize
              : line.length;
          debugPrintSynchronously(
            '$_yellow${line.substring(start, end)}$_reset',
          );
        }
        printedLines++;
      }
    }
  }
}
