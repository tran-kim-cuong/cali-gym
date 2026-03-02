import 'package:californiaflutter/helpers/session_manager.dart';
import 'package:californiaflutter/models/member_model.dart';
import 'package:flutter/widgets.dart';

class AppSession {
  // 1. Khởi tạo Singleton pattern
  static final AppSession _instance = AppSession._internal();
  factory AppSession() => _instance;
  AppSession._internal();

  // 2. Các biến lưu trữ dữ liệu trong RAM (Sẽ không bao giờ bị mất khi chuyển màn hình)
  String phoneNumber = "";
  String clientId = "";
  MemberModel? member;
  bool isInitialized = false;
  bool isLoggedIn = false;
  String customerId = "";

  // 3. Hàm LOAD duy nhất - Gắn giá trị 1 lần
  Future<void> load() async {
    if (isInitialized) return; // Tránh load lại nhiều lần không cần thiết

    // Await một lần duy nhất tại đây
    phoneNumber = await SessionManager.getPhoneNumber() ?? "";
    clientId = await SessionManager.getClientId() ?? "";
    member = SessionManager.member;
    customerId = SessionManager.sCustomerId;

    bool loggedIn = await SessionManager.isLoggedIn();
    isLoggedIn = loggedIn && phoneNumber.isNotEmpty;

    isInitialized = true;
    debugPrint("--- AppSession Loaded Successfully ---");
  }

  // Hàm cập nhật nóng (Ví dụ sau khi login/otp thành công)
  void updateSession({String? phone, String? cid, MemberModel? mem}) async {
    if (phone != null) {
      phoneNumber = phone;
      // LƯU XUỐNG DISK TẠI ĐÂY
      await SessionManager.setPhoneNumber(phone);
    }
    if (cid != null) {
      clientId = cid;
      // LƯU XUỐNG DISK TẠI ĐÂY
      await SessionManager.setClientId(cid);
    }
    if (mem != null) {
      member = mem;
      // Lưu object member nếu cần
      SessionManager.member = mem;
    }

    // Cập nhật trạng thái đăng nhập
    isLoggedIn = phoneNumber.isNotEmpty && clientId.isNotEmpty;
    isInitialized = true;
  }

  void clear() {
    phoneNumber = "";
    clientId = "";
    member = null;
    isInitialized = false;
    isLoggedIn = false;
    customerId = "";
    debugPrint("--- AppSession RAM Cleared ---");
  }
}
