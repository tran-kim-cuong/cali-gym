import 'package:flutter_dotenv/flutter_dotenv.dart';

class ImageHelper {
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
    return 'assets/images/none.jpg';
  }
}
