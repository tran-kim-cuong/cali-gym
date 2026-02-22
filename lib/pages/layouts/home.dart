import 'package:californiaflutter/bases/base_api.dart';
import 'package:californiaflutter/bases/loading_wrapper.dart';
import 'package:californiaflutter/bases/notification_mixin.dart';
import 'package:californiaflutter/helpers/convert_model.dart';
import 'package:californiaflutter/models/member_model.dart';
import 'package:californiaflutter/pages/layouts/class_detail.dart';
import 'package:californiaflutter/pages/layouts/loyalty.dart';
import 'package:californiaflutter/pages/layouts/member_card.dart';
import 'package:californiaflutter/pages/layouts/other_benefits.dart';
import 'package:californiaflutter/pages/shared/common_bottom_nav_bar.dart';
import 'package:californiaflutter/pages/shared/common_membership_card.dart';
import 'package:californiaflutter/pages/shared/common_point_badge.dart';
import 'package:californiaflutter/pages/shared/language_bottom_sheet.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:californiaflutter/helpers/session_manager.dart';
import 'package:californiaflutter/helpers/size_utils.dart';
import '../../models/schedule_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with LoadingWrapper, NotificationMixin {
  int _selectedIndex = 0;
  String? _activeCardId;
  List<Map<String, dynamic>> _memberCards = [];
  List<ScheduleModel> _upcomingClasses = [];

  @override
  void initState() {
    super.initState();
    _memberCards = buildMemberCards(SessionManager.member);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchMemberCards();
      _fetchUpcomingClasses();
      _checkNotificationPermission();
    });
  }

  // --- GIỮ NGUYÊN LOGIC API ---
  Future<void> _fetchUpcomingClasses() async {
    try {
      final now = DateTime.now();
      final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
      final String fromDate = formatter.format(
        DateTime(now.year, now.month, now.day, 0, 0, 0),
      );
      final String toDate = formatter.format(
        now
            .add(const Duration(days: 3))
            .copyWith(hour: 23, minute: 59, second: 59),
      );

      final response = await handleApi(
        context,
        BaseApi().client.get(
          '/api/booking/get/schedules',
          queryParameters: {
            "from_date": fromDate,
            "to_date": toDate,
            "club_code": "AMY,AMU",
          },
        ),
      );

      if (response?.statusCode == 200 && response?.data != null) {
        final List<dynamic> rawData = response?.data is List
            ? response?.data
            : (response?.data['data'] ?? []);
        final List<ScheduleModel> fetchedClasses = rawData
            .map((e) => ScheduleModel.fromJson(e))
            .toList();
        setState(() {
          _upcomingClasses = fetchedClasses;
        });
      }
    } catch (e) {
      debugPrint("Lỗi lấy danh sách lớp: $e");
    }
  }

  Future<void> _fetchMemberCards() async {
    try {
      final String? phoneNumber = await SessionManager.getPhoneNumber();

      if (mounted == false) return;

      final response = await handleApi(
        context,
        BaseApi().client.post(
          '/api/booking/check/member',
          data: {
            "clientcode": dotenv.env["CLIENT_ID"],
            "phone_number": phoneNumber,
          },
        ),
      );

      if (response?.statusCode == 200 && response?.data != null) {
        final member = MemberModel.fromJson(response?.data['data']);
        setState(() {
          SessionManager.member = member;
          SessionManager.sTenKh = member.firstName!;
          _memberCards = buildMemberCards(SessionManager.member);
        });
      }
    } catch (e) {
      showTopNotification("Không thể cập nhật thông tin thẻ", isError: true);
    }
  }

  void _onItemTapped(int index) {
    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoyaltyScreen()),
      );
    } else {
      setState(() => _selectedIndex = index);
    }
  }

  Future<void> _checkNotificationPermission() async {
    final prefs = await SharedPreferences.getInstance();
    if (!(prefs.getBool('has_requested_notification') ?? false)) {
      await Permission.notification.request();
      await prefs.setBool('has_requested_notification', true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF242424),
      body: Stack(
        children: [
          // LỚP 1: BACKGROUND MỜ
          Positioned(
            left: -68,
            top: 0,
            child: Opacity(
              opacity: 0.15,
              child: Container(
                width: context.resW(555),
                height: context.resH(740),
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                      "assets/images/background_home_v3_layer.png",
                    ), // Thay bằng ảnh thật của bạn
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),

          // LỚP 2: NỘI DUNG CHÍNH (SCROLLABLE)
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. HEADER (9:41 & NGÔN NGỮ)
                  _buildTopHeader(),

                  // 2. USER HELLO
                  _buildUserGreeting(),

                  // 3. STATS ROW (500 POINT, 5 VOUCHER)
                  _buildStatsRow(),

                  SizedBox(height: context.resH(24)),

                  // 4. MEMBERSHIP SECTION
                  _buildSectionHeader('Thẻ hội viên', 'Xem tất cả', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            MemberListScreen(cards: _memberCards),
                      ),
                    );
                  }),
                  _buildMembershipList(),

                  SizedBox(height: context.resH(24)),

                  // 5. QUICK ACTIONS
                  _buildQuickActions(),

                  SizedBox(height: context.resH(24)),

                  // 6. UPCOMING CLASSES
                  _buildSectionHeader('Lớp học sắp tới', 'Xem tất cả', () {}),
                  _upcomingClasses.isEmpty
                      ? _buildEmptyState('Không có lớp học nào', 'Đăng ký ngay')
                      : _buildClassList(),

                  SizedBox(height: context.resH(24)),

                  // 7. PT COURSE
                  _buildSectionHeader('Khoá học PT', 'Xem tất cả', () {}),
                  _buildEmptyState('Sắp ra mắt', null),

                  SizedBox(height: context.resH(24)),

                  // 8. HOT PROGRAM
                  _buildSectionHeader('Chương trình hot', 'Xem tất cả', () {}),
                  _buildHotProgram(),

                  SizedBox(height: context.resH(100)), // Chừa chỗ cho FAB
                ],
              ),
            ),
          ),

          // THÔNG BÁO
          buildNotificationWidget(),
        ],
      ),
      // floatingActionButton: _buildCaliFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: CommonBottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildTopHeader() {
    return Container(
      width: double.infinity,
      height: context.resH(44),
      padding: EdgeInsets.symmetric(horizontal: context.resW(20)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w500,
              fontFamily: 'Inter',
            ),
          ),
          _buildLanguageButton(),
        ],
      ),
    );
  }

  Widget _buildUserGreeting() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.resW(20),
        vertical: context.resH(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'home.hello'.tr(),
            style: const TextStyle(color: Color(0xFFC7C7C7), fontSize: 13),
          ),
          Text(
            SessionManager.sTenKh,
            style: TextStyle(
              color: Colors.white,
              // Responsive cho tên khách hàng
              fontSize: context.resClamp(20, 18, 24),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.resW(20)),
      child: Row(
        spacing: context.resW(8),
        children: [
          CommonPointBadge(value: '500', svgPath: 'assets/images/vuesax/ranking.svg'),
          CommonPointBadge(value: '5 voucher', svgPath: 'assets/images/vuesax/ticket-discount.svg', useGradient: false),
        ],
      ),
    );
  }

  // Widget _statItem(String value, {required bool isPoint}) {
  //   return Container(
  //     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  //     decoration: BoxDecoration(
  //       color: Colors.white.withValues(alpha: 0.05),
  //       border: Border.all(color: const Color(0xFFE8E8E8), width: 0.5),
  //       borderRadius: BorderRadius.circular(4),
  //     ),
  //     child: Row(
  //       children: [
  //         Text(
  //           value,
  //           style: TextStyle(
  //             color: Colors.white,
  //             // Responsive cho các chỉ số point/voucher
  //             fontSize: context.resClamp(12, 10, 14),
  //             height: 1.5,
  //           ),
  //         ),
  //         if (isPoint) ...[
  //           const SizedBox(width: 4),
  //           Container(
  //             width: 16,
  //             height: 16,
  //             decoration: const BoxDecoration(
  //               color: Color(0xFFD92229),
  //               shape: BoxShape.circle,
  //             ),
  //             child: const Center(
  //               child: Text(
  //                 "C",
  //                 style: TextStyle(
  //                   color: Colors.white,
  //                   fontSize: 9,
  //                   fontWeight: FontWeight.bold,
  //                 ),
  //               ),
  //             ),
  //           ),
  //         ],
  //       ],
  //     ),
  //   );
  // }

  Widget _buildSectionHeader(String title, String action, VoidCallback onTap) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.resW(20), vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              // Responsive cho tiêu đề các mục chính
              fontSize: context.resClamp(16, 14, 20),
              fontWeight: FontWeight.w600,
              height: 1.5,
            ),
          ),
          GestureDetector(
            onTap: onTap,
            child: Text(
              action,
              style: TextStyle(
                color: const Color(0xFF9A9A9A),
                // Responsive cho nút "Xem tất cả"
                fontSize: context.resClamp(14, 12, 16),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.resW(20)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _actionCircle('Đặt lớp học', 'assets/images/vuesax/teacher.svg'),
          _actionCircle(
            'Quyền lợi khác',
            'assets/images/vuesax/gift.svg',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const OtherBenefitsScreen(),
                ),
              );
            },
          ),
          _actionCircle(
            'Tập cùng PT',
            'assets/images/vuesax/dumbbell-large-minimalistic-svgrepo-com.svg',
          ),
        ],
      ),
    );
  }

  Widget _actionCircle(String label, String iconPath, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: context.resW(65),
            height: context.resW(65),
            padding: const EdgeInsets.all(18),
            decoration: const BoxDecoration(
              color: Color(0xFF3E3E3E),
              shape: BoxShape.circle,
            ),
            child: SvgPicture.asset(
              iconPath,
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              // Responsive cho nhãn các nút chức năng nhanh
              fontSize: context.resClamp(12, 10, 14),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message, String? btnText) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: context.resW(20)),
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF3E3E3E),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          Text(
            message,
            style: TextStyle(
              color: const Color(0xFF9A9A9A),
              fontSize: context.resClamp(12, 10, 14), // Responsive
            ),
          ),
          if (btnText != null) ...[
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD92229),
              ),
              child: Text(
                btnText,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: context.resClamp(12, 10, 14), // Responsive
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHotProgram() {
    return Container(
      width: double.infinity,
      height: 145,
      margin: EdgeInsets.symmetric(horizontal: context.resW(20)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        image: const DecorationImage(
          image: AssetImage("assets/images/hot_program.png"),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  // Widget _buildCaliFAB() {
  //   return SizedBox(
  //     width: 65,
  //     height: 65,
  //     child: FloatingActionButton(
  //       onPressed: () {},
  //       backgroundColor: Colors.white,
  //       elevation: 5,
  //       shape: const CircleBorder(),
  //       child: const Text(
  //         "Cali",
  //         style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
  //       ),
  //     ),
  //   );
  // }

  // --- REUSE OLD COMPONENTS ---
  Widget _buildMembershipList() {
    return SizedBox(
      height: 220,
      child: PageView.builder(
        controller: PageController(viewportFraction: 0.9),
        itemCount: _memberCards.length,
        itemBuilder: (context, index) {
          final cardData = _memberCards[index];
          final String uniqueKey = "${index}_${cardData['id']}";
          return CommonMembershipCard(
            data: cardData,
            isExpanded: _activeCardId == uniqueKey,
            onToggle: () => setState(
              () => _activeCardId = (_activeCardId == uniqueKey
                  ? null
                  : uniqueKey),
            ),
          );
        },
      ),
    );
  }

  Widget _buildClassList() {
    return SizedBox(
      height: 320,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.only(left: context.resW(20)),
        itemCount: _upcomingClasses.length,
        itemBuilder: (context, index) =>
            _buildClassCard(_upcomingClasses[index]),
      ),
    );
  }

  Widget _buildClassCard(ScheduleModel data) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ClassDetailScreen(schedule: data),
        ),
      ),
      child: Container(
        width: 240,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF333333),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: Image.asset(
                'assets/images/image_class.jpg',
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            // ... (Phần text nội dung card giữ nguyên từ home.dart cũ)
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageButton() {
    final currentCode = context.locale.languageCode;
    return GestureDetector(
      onTap: () => LanguageBottomSheet.show(context: context),
      child: Row(
        children: [
          SvgPicture.asset(
            currentCode == 'vi'
                ? 'assets/images/vietnam.svg'
                : 'assets/images/kingdom.svg',
            width: 20,
          ),
          const SizedBox(width: 8),
          Text(
            currentCode == 'vi' ? 'Tiếng Việt' : 'English',
            style: TextStyle(
              color: Colors.white,
              fontSize: context.resClamp(12, 10, 14), // Responsive
            ),
          ),
        ],
      ),
    );
  }
}
