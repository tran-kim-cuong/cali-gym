import 'package:californiaflutter/models/member_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const String keyIsLoggedIn = "isLoggedIn";
  static String otp = "1234";
  static String sSdt = "phone_number";
  static String sTenKh = "";
  static String sClientId = "";
  static String sMembershipNumber = "";
  static String sKeyCode = "JKLM012NOBCDQRS3456TUEFGPAHIVWXYZ7890";
  static String sCustomerId = "";
  static MemberModel member = MemberModel();

  static const String keyToken =
      "bearerToken"; // Key dùng để định danh token trong bộ nhớ

  // Lưu trạng thái đã đăng nhập
  static Future<void> setLoggedIn(bool value, String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyIsLoggedIn, value);
    await prefs.setString(keyToken, token);
  }

  // Kiểm tra xem đã đăng nhập chưa
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keyIsLoggedIn) ??
        false; // Mặc định là false nếu chưa có dữ liệu
  }

  // Đăng xuất (xóa dữ liệu)
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(keyIsLoggedIn);
  }

  // Hàm lấy Token mà bạn đang tìm
  static Future<String?> getToken() async {
    final prefs =
        await SharedPreferences.getInstance(); // Khởi tạo SharedPreferences
    return prefs.getString(
      keyToken,
    ); // Trả về chuỗi token hoặc null nếu chưa có
  }

  static Future<void> setPhoneNumber(String phoneNumber) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(sSdt, phoneNumber);
  }

  static Future<String?> getPhoneNumber() async {
    final prefs =
        await SharedPreferences.getInstance(); // Khởi tạo SharedPreferences
    return prefs.getString(sSdt); // Trả về chuỗi token hoặc null nếu chưa có
  }

  static Future<void> setClientId(String clientId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(sClientId, clientId);
  }

  static Future<String?> getClientId() async {
    final prefs =
        await SharedPreferences.getInstance(); // Khởi tạo SharedPreferences
    return prefs.getString(
      sClientId,
    ); // Trả về chuỗi token hoặc null nếu chưa có
  }
}
