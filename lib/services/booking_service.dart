import 'package:californiaflutter/bases/base_api.dart';
import 'package:californiaflutter/models/booking_class_model.dart';
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
}
