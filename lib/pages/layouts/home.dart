import 'package:californiaflutter/pages/layouts/loyalty.dart';
import 'package:californiaflutter/pages/layouts/member_card.dart';
import 'package:californiaflutter/pages/shared/common_bottom_nav_bar.dart';
import 'package:californiaflutter/pages/shared/common_membership_card.dart';
import 'package:californiaflutter/pages/shared/language_bottom_sheet.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:californiaflutter/helpers/session_manager.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  String? _activeCardId;

  // Màu chủ đạo lấy từ Figma
  final Color _redColor = const Color(0xFFD92229);
  final Color _greyText = const Color(0xFF6B6B6B);
  final Color _darkText = const Color(0xFF141414);

  // Thêm vào trong class _HomeScreenState
  final List<Map<String, dynamic>> _memberCards = [
    {
      "name": "LOAN PHAM",
      "id": "S0100958",
      "status": "Active",
      "expiry": "27/01/2027",
      "colors": [Color(0xFF574E4C), Color(0xFF231E1D)], // Màu đen (Mặc định)
    },
    {
      "name": "LOAN PHAM",
      "id": "C9998888",
      "status": "Centuryon",
      "expiry": "15/05/2028",
      "colors": [Color(0xFFD4AF37), Color(0xFF8B7500)], // Màu vàng Gold
    },
    {
      "name": "LOAN PHAM",
      "id": "S1234567",
      "status": "Expired",
      "expiry": "01/01/2023",
      "colors": [Color(0xFF757F9A), Color(0xFFD7DDE8)], // Màu xám bạc
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkNotificationPermission();
    });
  }

  Future<void> _checkNotificationPermission() async {
    final prefs = await SharedPreferences.getInstance();
    bool hasRequested = prefs.getBool('has_requested_notification') ?? false;
    if (!hasRequested) {
      PermissionStatus status = await Permission.notification.request();
      if (status.isGranted || status.isDenied || status.isPermanentlyDenied) {
        await prefs.setBool('has_requested_notification', true);
      }
    }
  }

  void _onItemTapped(int index) {
    if (index == 2) {
      // 1. Khi bấm vào "Khuyến mãi" (index 2), chuyển sang trang Loyalty
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoyaltyScreen()),
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: Stack(
        children: [
          // LỚP 1: Nền Gradient (Chỉ hình ảnh, không nút bấm)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 250,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF4E4B4B), Color(0xFF1F0707)],
                ),
              ),
            ),
          ),

          // LỚP 2: Nội dung Body (Trượt lên trên nền)
          SingleChildScrollView(
            padding: const EdgeInsets.only(top: 130), // Chừa chỗ cho Header
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  _buildStatsRow(),
                  const SizedBox(height: 24),
                  _buildBodyContent(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),

          // LỚP 3: Header Content (Nút bấm nằm trên cùng để nhận cảm ứng)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              // Dùng SafeArea để tránh tai thỏ
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ), // Căn chỉnh vị trí
                child:
                    _buildHeaderContent(), // Gọi hàm chứa Avatar, Nút ngôn ngữ...
              ),
            ),
          ),
        ],
      ),
      // ... (FloatingActionButton và BottomNavBar giữ nguyên)
      floatingActionButton: SizedBox(
        width: 65,
        height: 65,
        child: FloatingActionButton(
          onPressed: () {},
          backgroundColor: Colors.white,
          elevation: 5,
          shape: const CircleBorder(),
          child: const Text(
            "Cali",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      // GẮN CHUNG Ở ĐÂY
      bottomNavigationBar: CommonBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  // ==========================================
  // PHẦN 1: HEADER & STATS
  // ==========================================

  Widget _buildHeaderContent() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Avatar + Tên
        Row(
          children: [
            const CircleAvatar(
              radius: 22,
              backgroundColor: Colors.grey,
              // backgroundImage: NetworkImage("..."),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'home.hello'.tr(),
                  style: const TextStyle(
                    color: Color(0xFFC7C7C7),
                    fontSize: 13,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  SessionManager.sTenKh,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'Mulish',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),

        // Nút Ngôn ngữ + Chuông
        Row(
          children: [
            _buildLanguageButton(), // Nút này giờ đã nằm trên cùng -> Bấm được!
            const SizedBox(width: 12),
            const Icon(Icons.notifications_none, color: Colors.white, size: 26),
          ],
        ),
      ],
    );
  }

  // Thanh hiển thị Điểm và Voucher (2 nút riêng biệt)
  Widget _buildStatsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // Nút 1: Điểm (500 C)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFFE8E8E8),
              ), // Viền xám nhạt
            ),
            child: Row(
              children: [
                Text(
                  "500",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: _darkText,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: _redColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      "C",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Nút 2: Voucher
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE8E8E8)),
            ),
            child: Row(
              children: [
                // Dùng Icon thay thế nếu chưa có SVG
                const Icon(
                  Icons.confirmation_number_outlined,
                  size: 16,
                  color: Colors.black87,
                ),
                const SizedBox(width: 6),
                Text(
                  "12 voucher",
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: _darkText,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // PHẦN 2: NỘI DUNG BODY
  // ==========================================

  Widget _buildBodyContent() {
    return Column(
      children: [
        // --- Tiêu đề Thẻ hội viên ---
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Thẻ hội viên (${_memberCards.length})", // Hoặc .tr()
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _darkText,
                  fontFamily: 'Inter',
                ),
              ),
              GestureDetector(
                onTap: () {
                  // --- CODE ĐIỀU HƯỚNG MỚI ---
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      // Truyền danh sách _memberCards hiện có sang màn hình mới
                      builder: (context) =>
                          MemberListScreen(cards: _memberCards),
                    ),
                  );
                },
                child: Text(
                  "Xem tất cả",
                  style: TextStyle(
                    fontSize: 12,
                    color: _greyText,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // --- Thẻ Thành Viên (Membership Card) ---
        _buildMembershipList(),

        const SizedBox(height: 24),

        // --- Menu tròn (Quick Actions) ---
        _buildQuickActions(),

        const SizedBox(height: 24),

        // --- Lớp học sắp tới ---
        _buildSection(
          title: "Lớp học sắp tới",
          actionText: "Xem tất cả",
          child: _buildEmptyState("Không có lớp học nào", "Đăng ký ngay"),
        ),

        const SizedBox(height: 12),

        // --- Khoá học PT ---
        _buildSection(
          title: "Khoá học PT",
          actionText: "Xem tất cả",
          child: _buildEmptyState("Sắp ra mắt", null),
        ),

        const SizedBox(height: 12),

        // --- Chương trình hot ---
        _buildSection(
          title: "Chương trình hot",
          actionText: "Xem tất cả",
          child: Container(
            height: 145,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              // Ảnh demo
              image: const DecorationImage(
                image: AssetImage("assets/images/hot_program.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Widget Thẻ đen California
  // Widget _buildMembershipCard(Map<String, dynamic> data) {
  //   return Container(
  //     // Bỏ Padding bọc ngoài, thay bằng margin để các card cách nhau ra
  //     margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
  //     width: double.infinity,
  //     // height: 190, // Bỏ height cố định ở đây, để thằng cha quyết định
  //     decoration: BoxDecoration(
  //       borderRadius: BorderRadius.circular(16),
  //       gradient: LinearGradient(
  //         colors: data['colors'], // Dùng màu từ data
  //         begin: Alignment.topLeft,
  //         end: Alignment.bottomRight,
  //       ),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withOpacity(0.2),
  //           blurRadius: 10,
  //           offset: const Offset(0, 5),
  //         ),
  //       ],
  //     ),
  //     child: Stack(
  //       children: [
  //         // Watermark icon
  //         Positioned(
  //           right: -20,
  //           bottom: -20,
  //           child: Icon(
  //             Icons.fitness_center,
  //             size: 150,
  //             color: Colors.white.withValues(alpha: 0.05),
  //           ),
  //         ),
  //         Padding(
  //           padding: const EdgeInsets.all(20),
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Row(
  //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                 children: [
  //                   Image.asset(
  //                     "assets/images/logo.png",
  //                     height: 20,
  //                     fit: BoxFit.contain,
  //                     color: Colors.white,
  //                   ),
  //                   Container(
  //                     padding: const EdgeInsets.symmetric(
  //                       horizontal: 8,
  //                       vertical: 4,
  //                     ),
  //                     decoration: BoxDecoration(
  //                       border: Border.all(color: Colors.white),
  //                       borderRadius: BorderRadius.circular(4),
  //                     ),
  //                     child: Text(
  //                       data['status'], // Dùng status từ data
  //                       style: const TextStyle(
  //                         color: Colors.white,
  //                         fontSize: 10,
  //                       ),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //               const Spacer(),
  //               Text(
  //                 data['name'], // Dùng tên từ data
  //                 style: const TextStyle(
  //                   color: Colors.white,
  //                   fontSize: 18,
  //                   fontWeight: FontWeight.bold,
  //                 ),
  //               ),
  //               const SizedBox(height: 4),
  //               Text(
  //                 data['id'], // Dùng ID từ data
  //                 style: const TextStyle(color: Colors.white70, fontSize: 14),
  //               ),
  //               const SizedBox(height: 12),
  //               const Divider(color: Colors.white24, height: 1),
  //               const SizedBox(height: 12),
  //               Row(
  //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                 children: [
  //                   Text(
  //                     "Hạn: ${data['expiry']}", // Dùng ngày từ data
  //                     style: const TextStyle(
  //                       color: Colors.white70,
  //                       fontSize: 12,
  //                     ),
  //                   ),
  //                   Container(
  //                     padding: const EdgeInsets.symmetric(
  //                       horizontal: 8,
  //                       vertical: 4,
  //                     ),
  //                     decoration: BoxDecoration(
  //                       border: Border.all(color: Colors.white54),
  //                       borderRadius: BorderRadius.circular(4),
  //                     ),
  //                     child: const Text(
  //                       "Hiển thị mã QR",
  //                       style: TextStyle(color: Colors.white, fontSize: 10),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildMembershipList() {
    return SizedBox(
      height: 220, // Khớp với height của CommonMembershipCard
      child: PageView.builder(
        controller: PageController(viewportFraction: 0.9),
        itemCount: _memberCards.length,
        onPageChanged: (index) {
          // (Tùy chọn) Nếu muốn khi vuốt sang thẻ khác thì tự động đóng thẻ cũ:
          setState(() {
            _activeCardId = null;
          });
        },
        itemBuilder: (context, index) {
          final cardData = _memberCards[index];
          final String cardId = cardData['id'];

          return CommonMembershipCard(
            data: cardData,
            // Kiểm tra xem ID của thẻ này có trùng với ID đang active không
            isExpanded: _activeCardId == cardId,

            // Logic: Bấm vào thì nếu đang mở -> đóng, đang đóng -> mở thẻ này (và tự đóng thẻ khác)
            onToggle: () {
              setState(() {
                if (_activeCardId == cardId) {
                  _activeCardId = null; // Đóng lại
                } else {
                  _activeCardId = cardId; // Mở thẻ này
                }
              });
            },
          );
        },
      ),
    );
  }

  // Widget 4 nút tròn (Quick Actions)
  // 1. Widget Quick Actions (Chỉ còn 3 mục giống thiết kế)
  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 30,
      ), // Tăng padding để gom 3 nút vào giữa hơn
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween, // Căn đều khoảng cách
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mục 1: Đặt lớp học
          _actionItem(
            'assets/images/vuesax/teacher.svg', // Thay bằng đường dẫn file SVG của bạn (ví dụ hình cái mũ/lịch)
            "Đặt lớp học",
          ),

          // Mục 2: Quyền lợi
          _actionItem(
            'assets/images/vuesax/gift.svg', // Thay bằng file SVG hộp quà
            "Quyền lợi khác",
          ),

          // Mục 3: Tập cùng PT
          _actionItem(
            'assets/images/vuesax/star.svg', // Thay bằng file SVG người/ngôi sao
            "Tập cùng PT",
          ),
        ],
      ),
    );
  }

  Widget _actionItem(String svgPath, String label) {
    return Column(
      children: [
        Container(
          width: 65, // Kích thước vòng tròn (To hơn chút cho đẹp)
          height: 65,
          padding: const EdgeInsets.all(
            18,
          ), // Padding để icon bên trong không bị sát viền
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06), // Bóng mờ nhẹ tinh tế
                spreadRadius: 2,
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          // Hiển thị SVG
          child: SvgPicture.asset(
            svgPath,
            // Tô màu đỏ chủ đạo cho icon (nếu icon gốc màu đen/trắng)
            // Nếu icon của bạn đã có màu chuẩn rồi thì xóa dòng colorFilter này đi
            colorFilter: ColorFilter.mode(_redColor, BlendMode.srcIn),

            // Placeholder phòng trường hợp chưa chép file vào assets
            placeholderBuilder: (_) =>
                Icon(Icons.image_not_supported, color: _redColor),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: 80, // Giới hạn chiều rộng để text tự xuống dòng nếu dài
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: _greyText,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
              height: 1.2,
            ),
          ),
        ),
      ],
    );
  }

  // Widget Section bao ngoài (Tiêu đề + Nội dung con)
  Widget _buildSection({
    required String title,
    required String actionText,
    required Widget child,
  }) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _darkText,
                ),
              ),
              Text(
                actionText,
                style: TextStyle(color: _greyText, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  // Widget trạng thái trống (Empty State)
  Widget _buildEmptyState(String message, String? buttonText) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(
            Icons.calendar_today_outlined,
            color: Colors.grey[400],
            size: 40,
          ),
          const SizedBox(height: 12),
          Text(message, style: TextStyle(color: _greyText, fontSize: 14)),
          if (buttonText != null) ...[
            const SizedBox(height: 16),
            SizedBox(
              height: 36,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: _redColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  buttonText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ==========================================
  // PHẦN 3: CÁC WIDGET CHỨC NĂNG
  // ==========================================

  Widget _buildLanguageButton() {
    final currentCode = context.locale.languageCode;

    return GestureDetector(
      onTap: () {
        // Debug: In ra log để chắc chắn đã nhận sự kiện
        print("Đã bấm nút ngôn ngữ");
        LanguageBottomSheet.show(context: context);
      },
      // Quan trọng: Giúp nhận diện cú chạm ngay cả khi nền trong suốt
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(4), // Tăng vùng bấm lên một chút
        color: Colors.transparent,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: SvgPicture.asset(
                currentCode == 'vi'
                    ? 'assets/images/vietnam.svg'
                    : 'assets/images/kingdom.svg',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              currentCode == 'vi'
                  ? 'common.lang_vi'.tr()
                  : 'common.lang_en'.tr(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
