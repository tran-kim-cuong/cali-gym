import 'package:californiaflutter/helpers/session_manager.dart';
import 'package:californiaflutter/helpers/member_cache_manager.dart';
import 'package:californiaflutter/models/member_model.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/widgets.dart';
import 'package:package_info_plus/package_info_plus.dart';

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

  String latestVersion = "";
  String updateUrl = "";
  bool hasNewUpdate = false;

  // 3. Hàm LOAD duy nhất - Gắn giá trị 1 lần
  Future<void> load() async {
    if (isInitialized) return; // Tránh load lại nhiều lần không cần thiết

    // Await một lần duy nhất tại đây
    phoneNumber = await SessionManager.getPhoneNumber() ?? "";
    clientId = await SessionManager.getClientId() ?? "";
    member = MemberCacheManager().getCachedMember() ?? SessionManager.member;
    customerId = await SessionManager.getCustomerId() ?? "";

    SessionManager.member = member ?? MemberModel();
    SessionManager.sTenKh = member?.firstName ?? "";
    SessionManager.sMembershipNumber = member?.membershipNumber ?? "";

    bool loggedIn = await SessionManager.isLoggedIn();
    isLoggedIn = loggedIn && phoneNumber.isNotEmpty;

    isInitialized = true;
    debugPrint("--- AppSession Loaded Successfully ---");
  }

  // 4. Hàm UPDATE_VERSION
  Future<void> checkUpdate() async {
    try {
      final remoteConfig = FirebaseRemoteConfig.instance;

      await remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: const Duration(hours: 1),
        ),
      );

      await remoteConfig.fetchAndActivate();

      latestVersion = remoteConfig.getString('latest_version');
      debugPrint('Latest version: $latestVersion');
      updateUrl = remoteConfig.getString('update_url');
      debugPrint('Update URL: $updateUrl');

      final packageInfo = await PackageInfo.fromPlatform();
      String currentVersion = packageInfo.version;

      // So sánh phiên bản
      if (latestVersion.isNotEmpty && latestVersion != currentVersion) {
        hasNewUpdate = true;
      }
    } catch (e) {
      debugPrint("Error check update: $e");
    }
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
      SessionManager.sTenKh = mem.firstName ?? "";
      SessionManager.sMembershipNumber = mem.membershipNumber ?? "";
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
