import 'package:californiaflutter/bases/base_api.dart';
import 'package:californiaflutter/models/booking_class_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class BookingService {
  /// Hàm lấy danh sách lớp học đã đặt của hội viên
  // ignore: unintended_html_in_doc_comment
  /// Trả về một List<BookingData> đã được sắp xếp theo thời gian
  static Future<List<BookingData>> getUpcomingClasses(String clientId) async {
    try {
      final response = await BaseApi().client.post(
        '/api/booking/post/getUserBookedClasses',
        data: {"clientcode": clientId},
      );

      if (response.statusCode == 200 && response.data != null) {
        // 1. Xử lý các trường hợp cấu trúc dữ liệu trả về khác nhau
        final List<dynamic> rawData = response.data is List
            ? response.data
            : (response.data['booking_data'] ?? []);

        // 2. Chuyển đổi sang Model
        final List<BookingData> fetchedClasses = rawData
            .map((e) => BookingData.fromJson(e))
            .toList();

        // 3. Sắp xếp theo ngày bắt đầu tăng dần (gần nhất hiện lên trước)
        fetchedClasses.sort((a, b) {
          if (a.startDate == null || b.startDate == null) return 0;
          return a.startDate!.compareTo(b.startDate!);
        });

        return fetchedClasses;
      }
      return [];
    } catch (e) {
      debugPrint("--- BookingService Error: $e ---");
      return []; // Trả về list rỗng nếu có lỗi để tránh crash UI
    }
  }

  /// Gửi đánh giá lớp học
  static Future<Map<String, dynamic>> submitClassReview({
    required String clientCode,
    required int scheduleId,
    required int rate,
    required String description,
    required int rate1,
    required String description1,
    required int rate2,
    required String description2,
    required int rate3,
    required String description3,
  }) async {
    try {
      final formData = FormData.fromMap({
        'clientcode': clientCode,
        'schedule_id': scheduleId.toString(),
        'rate': rate.toString(),
        'description': description,
        'rate1': rate1.toString(),
        'description1': description1,
        'rate2': rate2.toString(),
        'description2': description2,
        'rate3': rate3.toString(),
        'description3': description3,
      });
      final response = await BaseApi().client.post(
        '/post/submitClassReview',
        data: formData,
      );
      if (response.data != null) {
        return Map<String, dynamic>.from(response.data);
      }
      return {'success': false, 'message': 'Đã xảy ra lỗi, vui lòng thử lại'};
    } on DioException catch (e) {
      debugPrint("--- BookingService.submitClassReview Error: $e ---");
      final data = e.response?.data;
      if (data is Map) {
        return Map<String, dynamic>.from(data);
      }
      return {'success': false, 'message': 'Đã xảy ra lỗi, vui lòng thử lại'};
    }
  }
}
