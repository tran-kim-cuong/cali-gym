import 'package:californiaflutter/bases/app_session.dart';
import 'package:californiaflutter/helpers/session_manager.dart';
import 'package:californiaflutter/pages/layouts/home.dart';
import 'package:californiaflutter/pages/layouts/login.dart';
import 'package:californiaflutter/pages/layouts/profile.dart';
import 'package:californiaflutter/pages/layouts/schedule.dart';
import 'package:californiaflutter/pages/layouts/loyalty.dart';
import 'package:californiaflutter/pages/shared/common_bottom_nav_bar.dart';
import 'package:californiaflutter/pages/shared/common_modal.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MasterScreen extends StatefulWidget {
  final int initialIndex; // Thêm tham số này

  const MasterScreen({super.key, this.initialIndex = 0});

  @override
  State<MasterScreen> createState() => _MasterScreenState();
}

class _MasterScreenState extends State<MasterScreen> {
  late int _currentIndex;

  // Danh sách các trang nội dung thay đổi
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    _currentIndex = widget.initialIndex;

    // 1. KIỂM TRA AUTH NGAY KHI VÀO MÀN HÌNH
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthStatus();
      // HIỂN THỊ THÔNG BÁO TẠI ĐÂY
      _showUpdateIfNeeded();
    });

    _pages = [
      const HomeScreen(), // Index 0
      const ScheduleScreen(), // Index 1
      const LoyaltyScreen(), // Index 2 (Ví dụ)
      const ProfileScreen(), // Index 3
    ];
  }

  Future<void> _checkAuthStatus() async {
    String? clientId = await SessionManager.getClientId();
    String? phoneNumber = await SessionManager.getPhoneNumber();
    String? customerId = await SessionManager.getCustomerId();

    // 2. Kiểm tra nếu thiếu Phone hoặc ClientID thì đẩy ra Login
    if (phoneNumber!.isEmpty || clientId!.isEmpty || customerId!.isEmpty) {
      debugPrint("--- Auth Guard: Thiếu dữ liệu, chuyển hướng về Welcome ---");

      if (!mounted) return;

      // Sử dụng pushAndRemoveUntil để xóa sạch lịch sử các màn hình trước đó
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false, // Xóa tất cả các route cũ
      );
    } else {
      AppSession().phoneNumber = phoneNumber;
      AppSession().clientId = clientId;
      AppSession().customerId = customerId;
    }
  }

  Future<void> _showUpdateIfNeeded() async {
    // Kiểm tra version đã bỏ qua dưới Disk
    String? skipped = await SessionManager.getSkippedVersion();

    if (AppSession().hasNewUpdate && AppSession().latestVersion != skipped) {
      if (!mounted) return;
      // Gọi hàm hiển thị Dialog (Sử dụng CommonModalWidget nếu bạn đã có)
      CommonModalWidget.showQuestionModal(
        context: context,
        imagePath: '',
        title: 'common.msg_new_version'.tr(args: [AppSession().latestVersion]),
        onConfirm: () {
          _performUpdate();
        },
        onCancel: () async {
          await SessionManager.setSkippedVersion(AppSession().latestVersion);
        },
      );
    }
  }

  Future<void> _performUpdate() async {
    // 1. Lấy URL từ AppSession (đã được nạp từ Remote Config trước đó)
    final String urlString = AppSession().updateUrl;

    if (urlString.isEmpty) {
      debugPrint("--- Lỗi: Không tìm thấy link cập nhật trong AppSession ---");
      return;
    }

    final Uri url = Uri.parse(urlString);

    try {
      // 2. Kiểm tra xem hệ điều hành có hỗ trợ mở link này không
      if (await canLaunchUrl(url)) {
        // 3. Kích hoạt trình duyệt hoặc Store của máy
        await launchUrl(
          url,
          // Chế độ này cực kỳ quan trọng để giữ Session
          mode: LaunchMode.externalApplication,
        );
      } else {
        debugPrint("--- Không thể mở link: $urlString ---");
      }
    } catch (e) {
      debugPrint("--- Lỗi khi thực hiện cập nhật: $e ---");
    }
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 1. Lấy độ cao dải tác vụ hệ thống (Gesture bar) để điều chỉnh UI
    // final double systemBottomPadding = MediaQuery.of(context).padding.bottom;
    final _ = context.locale;

    return Scaffold(
      backgroundColor: const Color(0xFF151515),
      // Quan trọng: Cho phép body tràn dưới Navbar để hiệu ứng mờ (blur) hoạt động đẹp
      extendBody: true,

      // 2. Sử dụng IndexedStack để giữ trạng thái (State) của các trang
      body: IndexedStack(index: _currentIndex, children: _pages),

      // CHỈ CẦN GỌI TRỰC TIẾP NHƯ THẾ NÀY
      bottomNavigationBar: CommonBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
