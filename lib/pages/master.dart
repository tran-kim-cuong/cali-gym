import 'package:californiaflutter/bases/app_session.dart';
import 'package:californiaflutter/pages/layouts/home.dart';
import 'package:californiaflutter/pages/layouts/login.dart';
import 'package:californiaflutter/pages/layouts/schedule.dart';
import 'package:californiaflutter/pages/layouts/loyalty.dart';
import 'package:californiaflutter/pages/shared/common_bottom_nav_bar.dart';
import 'package:flutter/material.dart';

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
    });

    _pages = [
      const HomeScreen(), // Index 0
      const ScheduleScreen(), // Index 1
      const LoyaltyScreen(), // Index 2 (Ví dụ)
      const Scaffold(body: Center(child: Text("Hồ sơ"))), // Index 3
    ];
  }

  void _checkAuthStatus() {
    // 2. Kiểm tra nếu thiếu Phone hoặc ClientID thì đẩy ra Login
    if (AppSession().phoneNumber.isEmpty || AppSession().clientId.isEmpty) {
      debugPrint("--- Auth Guard: Thiếu dữ liệu, chuyển hướng về Welcome ---");

      // Sử dụng pushAndRemoveUntil để xóa sạch lịch sử các màn hình trước đó
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false, // Xóa tất cả các route cũ
      );
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
    final double systemBottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFF151515),
      // Quan trọng: Cho phép body tràn dưới Navbar để hiệu ứng mờ (blur) hoạt động đẹp
      extendBody: true,

      // 2. Sử dụng IndexedStack để giữ trạng thái (State) của các trang
      body: IndexedStack(index: _currentIndex, children: _pages),

      // 3. Thanh điều hướng dùng chung cho toàn bộ app
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CommonBottomNavBar(currentIndex: _currentIndex, onTap: _onTabTapped),
          // ĐIỀU CHỈNH BOTTOM: Thêm khoảng trống nếu máy có dải tác vụ hệ thống
          if (systemBottomPadding > 0)
            Container(
              height: systemBottomPadding,
              color: const Color(0xFF3E3E3E), // Màu nền đồng bộ với Navbar
            ),
        ],
      ),
    );
  }
}
