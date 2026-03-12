import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ImageHelper {
  static Map<String, Map<String, dynamic>>? _membershipCardMap;

  /// Tải và cache dữ liệu thẻ từ assets/jsons/membershi-cards.json.
  /// Gọi một lần khi khởi động app.
  static Future<void> initMembershipCards() async {
    if (_membershipCardMap != null) return;
    final jsonStr = await rootBundle.loadString(
      'assets/jsons/membershi-cards.json',
    );
    final List<dynamic> list = json.decode(jsonStr);
    _membershipCardMap = {};
    for (final item in list) {
      final type = item['membershipType'] as String;
      // putIfAbsent để giữ entry đầu tiên nếu bị trùng membershipType
      _membershipCardMap!.putIfAbsent(
        type,
        () => Map<String, dynamic>.from(item as Map),
      );
    }
  }

  /// Chuẩn hóa key: uppercase, bỏ khoảng trắng thừa, thay space → underscore.
  static String _normalizeKey(String s) =>
      s.trim().toUpperCase().replaceAll(' ', '_');

  /// Trả về dữ liệu thẻ (img URL, color).
  /// Thử [membershipNameCard] trước (khớp chính xác hơn),
  /// rồi [membershipType], cuối cùng fallback về 'DEFAULT'.
  static Map<String, dynamic>? getMembershipCardData({
    String? membershipType,
    String? membershipNameCard,
  }) {
    if (_membershipCardMap == null) return _membershipCardMap?['DEFAULT'];
    if (membershipNameCard != null && membershipNameCard.isNotEmpty) {
      final r = _membershipCardMap![_normalizeKey(membershipNameCard)];
      if (r != null) return r;
    }
    if (membershipType != null && membershipType.isNotEmpty) {
      final r = _membershipCardMap![_normalizeKey(membershipType)];
      if (r != null) return r;
    }
    return _membershipCardMap!['DEFAULT'];
  }

  /// Hàm trả về đường dẫn asset dựa trên loại lớp học
  static String getClassThumbnail(String? classType) {
    // Chuyển về chữ thường để so sánh chính xác hơn
    final type = classType?.toLowerCase() ?? '';

    if (type.contains('yoga')) {
      return dotenv.get('CLUBS_YOGA');
    } else if (type.contains('cycling') || type.contains('đạp xe')) {
      return dotenv.get('CLUBS_CYCLING');
    } else if (type.contains('dance') || type.contains('nhảy')) {
      return dotenv.get('CLUBS_DEFAULT');
    } else if (type.contains('gym') || type.contains('pt')) {
      return dotenv.get('CLUBS_DEFAULT');
    } else if (type.contains('group-x')) {
      return dotenv.get('CLUBS_GROUP_X');
    }

    // Ảnh mặc định nếu không khớp loại nào
    return dotenv.get('CLUBS_DEFAULT');
  }

  static String getCardImageByMembershipType(String? membershipType) {
    final type = membershipType?.toLowerCase().replaceAll(' ', '_') ?? '';

    if (type.contains('supplement')) {
      return 'assets/images/cards/supplement.png';
    } else if (type.contains('icon')) {
      return 'assets/images/cards/gold.png';
    } else if (type.contains('diamond-x')) {
      return 'assets/images/cards/diamond-x.png';
    }

    return 'assets/images/cards/staff.png';
  }
}
