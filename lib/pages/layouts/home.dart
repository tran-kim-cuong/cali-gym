import 'package:californiaflutter/bases/app_session.dart';
import 'package:californiaflutter/bases/base_api.dart';
import 'package:californiaflutter/bases/loading_wrapper.dart';
import 'package:californiaflutter/bases/notification_mixin.dart';
import 'package:californiaflutter/helpers/convert_model.dart';
import 'package:californiaflutter/models/booking_class_model.dart';
import 'package:californiaflutter/models/member_model.dart';
import 'package:californiaflutter/pages/layouts/class.dart';
import 'package:californiaflutter/pages/layouts/class_detail.dart';
// import 'package:californiaflutter/pages/layouts/loyalty.dart';
import 'package:californiaflutter/pages/layouts/member_card.dart';
import 'package:californiaflutter/pages/layouts/other_benefits.dart';
import 'package:californiaflutter/pages/master.dart';
// import 'package:californiaflutter/pages/layouts/schedule.dart';
import 'package:californiaflutter/pages/shared/check_in_bottom_sheet.dart';
import 'package:californiaflutter/pages/shared/common_background.dart';
// import 'package:californiaflutter/pages/shared/common_bottom_nav_bar.dart';
import 'package:californiaflutter/pages/shared/common_class_card.dart';
import 'package:californiaflutter/pages/shared/common_membership_card.dart';
import 'package:californiaflutter/pages/shared/common_point_badge.dart';
import 'package:californiaflutter/pages/shared/language_bottom_sheet.dart';
import 'package:californiaflutter/services/booking_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:californiaflutter/helpers/session_manager.dart';
import 'package:californiaflutter/helpers/size_utils.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with LoadingWrapper, NotificationMixin {
  // int _selectedIndex = 0;
  String? _activeCardId;
  List<Map<String, dynamic>> _memberCards = [];
  List<BookingData> _upcomingClasses = [];
  String? clientId;

  @override
  void initState() {
    super.initState();
    _memberCards = buildMemberCards(SessionManager.member);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // clientId = await SessionManager.getClientId();
      await _initData();
      _checkNotificationPermission();
    });
  }

  Future<void> _initData() async {
    // 1. GOM 2 TÁC VỤ VÀO 1 HANDLE API DUY NHẤT
    await handleApi(
      context,
      Future.wait([_fetchMemberCards(), _fetchUpcomingClasses()]),
    );

    // Sau khi cả 2 load xong, Loading sẽ tự tắt
    debugPrint("--- Đã tải xong toàn bộ dữ liệu trang Home ---");
  }

  // --- GIỮ NGUYÊN LOGIC API ---
  Future<void> _fetchUpcomingClasses() async {
    try {
      final List<BookingData> rs = await BookingService.getUpcomingClasses(
        AppSession().clientId,
      );

      if (mounted) {
        setState(() {
          _upcomingClasses = rs;
        });
      }
    } catch (e) {
      debugPrint("Lỗi lấy danh sách lớp: $e");
    }
  }

  Future<void> _fetchMemberCards() async {
    try {
      final response = await BaseApi().client.post(
        '/api/booking/check/member',
        data: {
          "clientcode": AppSession().clientId,
          "phone_number": AppSession().phoneNumber,
        },
      );

      if (200 == response.statusCode && response.data != null) {
        final member = MemberModel.fromJson(response.data['data']);
        if (mounted) {
          setState(() {
            AppSession().member = member; // Save in RAM
            SessionManager.member = member; // Save in Disk
            SessionManager.sTenKh = member.firstName!;
            SessionManager.sMembershipNumber = member.membershipNumber!;
            _memberCards = buildMemberCards(AppSession().member);
          });
        }
      }
    } catch (e) {
      showTopNotification("Không thể cập nhật thông tin thẻ", isError: true);
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
    final double bottomSafeHeight = MediaQuery.of(context).padding.bottom;
    // final double navBarHeight = context.resH(60) + context.resH(24);

    return Scaffold(
      backgroundColor: const Color(0xFF242424),
      body: Stack(
        children: [
          // LỚP 1: BACKGROUND MỜ
          CommonBackgroundWidget.buildBackgroundImage(
            context,
            dotenv.get('IMAGES_BG_HOME_V3_LAYER'),
          ),

          // LỚP 2: NỘI DUNG CHÍNH (SCROLLABLE)
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
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
                  _buildSectionHeader(
                    'home.section_member_card'.tr(),
                    'home.see_all'.tr(),
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              MemberListScreen(cards: _memberCards),
                        ),
                      );
                    },
                  ),
                  _buildMembershipList(),

                  SizedBox(height: context.resH(24)),

                  // 5. QUICK ACTIONS
                  _buildQuickActions(),

                  SizedBox(height: context.resH(24)),

                  // 6. UPCOMING CLASSES
                  _buildSectionHeader(
                    'home.section_next_class'.tr(),
                    'home.see_all'.tr(),
                    () {
                      // CẬP NHẬT TẠI ĐÂY: Cho phép nhấn vào chữ "Xem tất cả" ở trên đầu
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ClassScreen()),
                      );
                    },
                  ),
                  _upcomingClasses.isEmpty
                      ? _buildEmptyState(
                          'home.no_class'.tr(),
                          'home.register_now'.tr(),
                        )
                      : _buildClassList(),

                  SizedBox(height: context.resH(24)),

                  // 7. PT COURSE
                  _buildSectionHeader(
                    'home.section_practice_pt'.tr(),
                    'home.see_all'.tr(),
                    () {},
                  ),
                  _buildEmptyState('home.coming_soon'.tr(), null),

                  SizedBox(height: context.resH(24)),

                  // 8. HOT PROGRAM
                  _buildSectionHeader(
                    'home.hot_program'.tr(),
                    'home.see_all'.tr(),
                    () {},
                  ),
                  _buildHotProgram(),

                  SizedBox(
                    height: bottomSafeHeight + 20, // Keep can use navBarHeight
                  ), // Chừa chỗ cho FAB
                ],
              ),
            ),
          ),

          // THÔNG BÁO
          buildNotificationWidget(),
        ],
      ),
      // floatingActionButton: _buildCaliFAB(),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      // bottomNavigationBar: CommonBottomNavBar(
      //   currentIndex: _selectedIndex,
      //   onTap: _onItemTapped,
      // ),
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
          // 1. Cánh trái: Placeholder cho Logo hoặc Tên màn hình
          Container(
            width: context.resW(
              141,
            ), // Độ rộng co giãn theo chiều ngang màn hình
            height: context.resH(
              24,
            ), // Chiều cao co giãn theo chiều dọc màn hình
            clipBehavior: Clip.antiAlias,
            decoration: const BoxDecoration(),
            child: Stack(
              children: [
                // GẮN SVG TẠI ĐÂY
                SvgPicture.asset(
                  'assets/images/CWG-Logo-White.svg', // Đường dẫn file SVG của bạn
                  width: double
                      .infinity, // Để SVG tự giãn đầy chiều ngang Container
                  height:
                      double.infinity, // Để SVG tự giãn đầy chiều cao Container
                  // QUAN TRỌNG: BoxFit.contain giúp logo luôn giữ đúng tỉ lệ
                  // và nằm gọn trong khung (141x24) mà không bị méo
                  fit: BoxFit.contain,

                  // Bạn có thể đổi màu logo sang trắng hoặc màu khác tại đây nếu cần
                  // colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                ),
              ],
            ),
          ),

          // 2. Cánh phải: Cụm Icon Buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            // Sử dụng spacing theo đúng code gốc của bạn
            children: [
              // ICON 1: Thông báo
              _buildLanguageButton(),

              // Khoảng cách giữa 2 icon (thay cho spacing: 10 nếu Flutter bản cũ)
              SizedBox(width: context.resW(10)),
            ],
          ),
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
          CommonPointBadge(
            value: '500',
            svgPath: 'assets/images/vuesax/ranking.svg',
          ),
          CommonPointBadge(
            value: '5 voucher',
            svgPath: 'assets/images/vuesax/ticket-discount.svg',
            useGradient: false,
          ),
        ],
      ),
    );
  }

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
          _actionCircle(
            'home.fnc_pick_up_class'.tr(),
            'assets/images/vuesax/teacher.svg',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MasterScreen(initialIndex: 1),
                ),
              );
            },
          ),
          _actionCircle(
            'home.fnc_other_benefit'.tr(),
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
            'home.fnc_practice_teacher'.tr(),
            'assets/images/vuesax/dumbbell-large-minimalistic-svgrepo-com.svg',
          ),
        ],
      ),
    );
  }

  Widget _actionCircle(String label, String iconPath, {VoidCallback? onTap}) {
    // Sử dụng màu đỏ thương hiệu từ login.dart hoặc các nút đặt chỗ
    const Color brandRed = Color(0xFFDA212D);

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
              colorFilter: const ColorFilter.mode(brandRed, BlendMode.srcIn),
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
      height: context.resH(145),
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
    // Luôn lấy tối đa 3 phần tử đầu tiên từ danh sách API trả về
    int displayCount = _upcomingClasses.length > 3
        ? 3
        : _upcomingClasses.length;

    return SizedBox(
      height: context.resH(265).clamp(250, 280),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.only(left: context.resW(20)),
        itemCount: _upcomingClasses.length,
        itemBuilder: (context, index) {
          if (index < displayCount) {
            final classData = _upcomingClasses[index];

            // Hiển thị thẻ lớp học bình thường
            return GestureDetector(
              // SỰ KIỆN CLICK VÀO CARD
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ClassDetailScreen(
                      scheduleId: classData.scheduleId, // Map từ scheduleId
                      seatCode: classData.code, // Map từ code (mã ghế/đặt chỗ)
                      clubCode: classData.clubCode, // Map từ clubCode
                    ),
                  ),
                );
              },
              child: CommonClassCard(
                data: classData,
                index: index,
                onCheckIn: () {
                  CheckInBottomSheet.show(
                    context,
                    classData,
                    onScanned: (String qrData) {
                      debugPrint(qrData);
                    },
                    onConfirm: (code) {
                      debugPrint(code);
                    },
                  );
                },
              ),
            );
          } else {
            // Item cuối cùng luôn là thẻ "Xem tất cả"
            return _buildViewAllCard();
          }
        },
      ),
    );
  }

  Widget _buildViewAllCard() {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: context.resW(150),
        // Sử dụng margin và shadow đồng bộ với CommonClassCard
        margin: EdgeInsets.only(right: context.resW(16), bottom: 6, top: 5),
        decoration: ShapeDecoration(
          color: const Color(0xFF3E3E3E),
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 1, color: Color(0xFF6B6B6B)),
            borderRadius: BorderRadius.circular(8),
          ),
          shadows: const [
            BoxShadow(
              color: Color(0xFF545152),
              offset: Offset(4, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon mũi tên theo hình ảnh mẫu
            Icon(
              Icons.arrow_forward,
              color: const Color(0xFF9A9A9A),
              size: context.resW(32),
            ),
            SizedBox(height: context.resH(12)),
            Text(
              'home.see_all'.tr(),
              style: TextStyle(
                color: const Color(0xFF9A9A9A),
                fontSize: context.resClamp(14, 12, 16),
                fontFamily: 'Inter',
                fontWeight: FontWeight.w400,
              ),
            ),
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
