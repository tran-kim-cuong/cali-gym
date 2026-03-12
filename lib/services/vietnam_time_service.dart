import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class VietnamTimeService {
  VietnamTimeService._();

  static final VietnamTimeService instance = VietnamTimeService._();

  static const Duration _requestTimeout = Duration(seconds: 5);
  static const String _timeZone = 'Asia/Ho_Chi_Minh';
  static final Uri _timeApiUri = Uri.parse(
    'https://timeapi.io/api/time/current/zone?timeZone=$_timeZone',
  );

  Future<DateTime> getNowFromTimeApi() async {
    final response = await http.get(_timeApiUri).timeout(_requestTimeout);

    if (response.statusCode != 200) {
      throw Exception('TimeAPI status ${response.statusCode}');
    }

    final dynamic decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Invalid TimeAPI response format');
    }

    final int? year = _asInt(decoded['year']);
    final int? month = _asInt(decoded['month']);
    final int? day = _asInt(decoded['day']);
    final int? hour = _asInt(decoded['hour']);
    final int? minute = _asInt(decoded['minute']);
    final int second = _asInt(decoded['seconds']) ?? 0;
    final int millisecond = _asInt(decoded['milliSeconds']) ?? 0;
    final int microsecond = _asInt(decoded['microSeconds']) ?? 0;

    if (year == null ||
        month == null ||
        day == null ||
        hour == null ||
        minute == null) {
      final String? rawDateTime = decoded['dateTime']?.toString();
      if (rawDateTime == null || rawDateTime.isEmpty) {
        throw Exception('Missing date fields from TimeAPI');
      }

      final DateTime? parsedDateTime = DateTime.tryParse(rawDateTime);
      if (parsedDateTime == null) {
        throw Exception('Invalid dateTime from TimeAPI');
      }

      return DateTime(
        parsedDateTime.year,
        parsedDateTime.month,
        parsedDateTime.day,
        parsedDateTime.hour,
        parsedDateTime.minute,
        parsedDateTime.second,
        parsedDateTime.millisecond,
        parsedDateTime.microsecond,
      );
    }

    return DateTime(
      year,
      month,
      day,
      hour,
      minute,
      second,
      millisecond,
      microsecond,
    );
  }

  DateTime getDeviceNowVietnam() {
    final DateTime nowVietnam = DateTime.now().toUtc().add(
      const Duration(hours: 7),
    );

    // Chuẩn hóa thành local wall-clock để so sánh ổn định với dữ liệu lớp.
    return DateTime(
      nowVietnam.year,
      nowVietnam.month,
      nowVietnam.day,
      nowVietnam.hour,
      nowVietnam.minute,
      nowVietnam.second,
      nowVietnam.millisecond,
      nowVietnam.microsecond,
    );
  }

  Future<DateTime> getNowVietnamWithFallback() async {
    try {
      return await getNowFromTimeApi();
    } catch (e) {
      debugPrint('VietnamTimeService fallback to device time: $e');
      return getDeviceNowVietnam();
    }
  }

  static int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }
}
