import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const String keyIsLoggedIn = "isLoggedIn";
  static String otp = "1234";
  static String sSdt = "";
  static String sTenKh = "";
  static String sClientId = "s0100904";

  // Lưu trạng thái đã đăng nhập
  static Future<void> setLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyIsLoggedIn, value);
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
}
