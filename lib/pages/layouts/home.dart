import 'package:californiaflutter/bases/app_session.dart';
import 'package:californiaflutter/bases/base_api.dart';
import 'package:californiaflutter/bases/notification_mixin.dart';
import 'package:californiaflutter/helpers/convert_model.dart';
import 'package:californiaflutter/helpers/loading_widget.dart';
import 'package:californiaflutter/helpers/member_cache_manager.dart';
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
import 'package:californiaflutter/pages/widgets/common_user_share_card.dart';
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

class _HomeScreenState extends State<HomeScreen> with NotificationMixin {
  static const LinearGradient _pointBadgeGradient = LinearGradient(
    begin: Alignment.centerRight,
    end: Alignment.centerLeft,
    colors: [Color(0xFF00E200), Color(0xFF180F0F)],
  );

  static const LinearGradient _voucherBadgeGradient = LinearGradient(
    begin: Alignment.centerRight,
    end: Alignment.centerLeft,
    colors: [Color(0xFFFFAF3D), Color(0xFF180F0F)],
  );

  // int _selectedIndex = 0;
  String? _activeCardId;
  List<Map<String, dynamic>> _memberCards = [];
  List<BookingData> _upcomingClasses = [];
  String? clientId;

  bool _isProcessing = false;
  bool _isInitialLoading = true;
  Map<String, dynamic>? _latestMemberRaw;

  @override
  void initState() {
    super.initState();
    _memberCards = buildMemberCards(SessionManager.member);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkNotificationPermission();
      _loadInitialData();
    });
  }

  Future<void> _loadInitialData() async {
    await _refreshHomeData(showBlockingLoading: true);
  }

  Future<void> _refreshHomeData({bool showBlockingLoading = false}) async {
    if (_isProcessing) return; // Nếu đang load thì không chạy nữa
    _isProcessing = true;

    if (showBlockingLoading && mounted) {
      setState(() {
        _isInitialLoading = true;
      });
    }

    try {
      final clientId =
          await SessionManager.getClientId() ?? AppSession().clientId;
      final results = await Future.wait([
        _fetchMemberCards(),
        _fetchUpcomingClasses(clientId),
      ]);

      final MemberModel? member = results[0] as MemberModel?;
      final List<BookingData>? upcomingClasses =
          results[1] as List<BookingData>?;
      final bool hasRefreshError = member == null || upcomingClasses == null;

      if (!mounted) return;

      setState(() {
        if (member != null) {
          AppSession().member = member;
          SessionManager.member = member;
          SessionManager.sTenKh = member.firstName ?? "";
          SessionManager.sMembershipNumber = member.membershipNumber ?? "";
          _memberCards = buildMemberCards(AppSession().member);
        }
        if (upcomingClasses != null) {
          _upcomingClasses = upcomingClasses;
        }
      });

      if (member != null && _latestMemberRaw != null) {
        await MemberCacheManager().saveMemberRaw(_latestMemberRaw!);
      }

      if (hasRefreshError && mounted) {
        showTopNotification(
          "Không thể cập nhật dữ liệu mới, đang hiển thị dữ liệu đã lưu",
          isError: true,
        );
      }
    } finally {
      if (showBlockingLoading && mounted) {
        setState(() {
          _isInitialLoading = false;
        });
      }
      _isProcessing = false;
      debugPrint("--- Đã tải xong toàn bộ dữ liệu trang Home ---");
    }
  }

  // --- GIỮ NGUYÊN LOGIC API ---
  Future<List<BookingData>?> _fetchUpcomingClasses(String clientId) async {
    try {
      final response = await BaseApi().client.post(
        '/api/booking/post/getUserBookedClasses',
        data: {"clientcode": clientId},
      );

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> rawData = response.data is List
            ? response.data as List<dynamic>
            : (response.data['booking_data'] ?? []) as List<dynamic>;

        final List<BookingData> fetchedClasses = rawData
            .map((e) => BookingData.fromJson(e))
            .toList();

        fetchedClasses.sort((a, b) {
          if (a.startDate == null || b.startDate == null) return 0;
          return a.startDate!.compareTo(b.startDate!);
        });

        return fetchedClasses;
      }

      return [];
    } catch (e) {
      debugPrint("Lỗi lấy danh sách lớp: $e");
      return null;
    }
  }

  Future<MemberModel?> _fetchMemberCards() async {
    _latestMemberRaw = null;
    try {
      final response = await BaseApi().client.post(
        '/api/booking/check/member',
        data: {
          "clientcode": AppSession().clientId,
          "phone_number": AppSession().phoneNumber,
        },
      );

      if (200 == response.statusCode && response.data != null) {
        final dynamic rawData = response.data['data'];
        if (rawData is! Map) return null;
        final memberRaw = Map<String, dynamic>.from(rawData);
        _latestMemberRaw = memberRaw;
        final member = MemberModel.fromJson(memberRaw);
        return member;
        // if (mounted) {
        //   setState(() {
        //     AppSession().member = member; // Save in RAM
        //     SessionManager.member = member; // Save in Disk
        //     SessionManager.sTenKh = member.firstName!;
        //     SessionManager.sMembershipNumber = member.membershipNumber!;
        //     _memberCards = buildMemberCards(AppSession().member);
        //   });
        // }
      }
    } catch (e) {
      debugPrint("Lỗi lấy thông tin thẻ: $e");
    }

    return null;
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
            child: NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification notification) {
                if (notification.metrics.pixels < -100 &&
                    notification is ScrollUpdateNotification) {
                  // 2. KÍCH HOẠT: Chỉ gọi refresh khi không có loading nào đang chạy
                  // Bạn có thể dùng một biến flag để tránh gọi liên tục nhiều lần trong 1 lần kéo
                  _refreshHomeData();
                }
                return false;
              },
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
                          MaterialPageRoute(
                            builder: (context) => ClassScreen(),
                          ),
                        );
                      },
                    ),

                    // _buildEmptyState(
                    //   'home.no_class'.tr(),
                    //   'home.register_now'.tr(),
                    // ),
                    _upcomingClasses.isEmpty
                        ? _buildEmptyState(
                            'home.no_class'.tr(),
                            'home.register_now'.tr(),
                          )
                        : _buildClassList(),
                    SizedBox(height: context.resH(24)),

                    // 7. PT COURSE
                    // _buildSectionHeader(
                    //   'home.section_practice_pt'.tr(),
                    //   'home.see_all'.tr(),
                    //   () {
                    //     CommonNotification.show(
                    //       context,
                    //       message: "home.features_coming_soon".tr(),
                    //     );
                    //   },
                    // ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.resW(20),
                        vertical: 6,
                      ),
                      child: Text(
                        'home.section_practice_pt'.tr(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: context.resClamp(16, 14, 20),
                          fontWeight: FontWeight.w600,
                          height: 1.5,
                        ),
                      ),
                    ),
                    _buildComingSoonState('home.coming_soon'.tr(), null),

                    SizedBox(height: context.resH(24)),

                    // 8. HOT PROGRAM
                    // _buildSectionHeader(
                    //   'home.hot_program'.tr(),
                    //   'home.see_all'.tr(),
                    //   () {
                    //     CommonNotification.show(
                    //       context,
                    //       message: "home.features_coming_soon".tr(),
                    //     );
                    //   },
                    // ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.resW(20),
                        vertical: 6,
                      ),
                      child: Text(
                        'home.hot_program'.tr(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: context.resClamp(16, 14, 20),
                          fontWeight: FontWeight.w600,
                          height: 1.5,
                        ),
                      ),
                    ),
                    _buildHotProgram(),

                    SizedBox(
                      height:
                          bottomSafeHeight + 20, // Keep can use navBarHeight
                    ), // Chừa chỗ cho FAB
                  ],
                ),
              ),
            ),
            // child: RefreshIndicator(
            //   color: Colors.transparent,
            //   backgroundColor: Colors.transparent,
            //   elevation: 0, // Bỏ bóng đổ của vòng xoay
            //   child: ,
            //   onRefresh: () async {
            //     await _initData();
            //   },
            // ),
          ),

          // THÔNG BÁO
          buildNotificationWidget(),
          if (_isInitialLoading) const Positioned.fill(child: LoadingWidget()),
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
                  'assets/images/logo_cali.svg',
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
            svgPath: 'assets/images/vuesax/v5/ranking.svg',
            useGradient: false,
            backgroundGradient: _pointBadgeGradient,
          ),
          CommonPointBadge(
            value: '5 voucher',
            svgPath: 'assets/images/vuesax/v5/ticket-discount.svg',
            useGradient: false,
            backgroundGradient: _voucherBadgeGradient,
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
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _actionCircle(
            'home.fnc_pick_up_class'.tr(),
            'assets/images/vuesax/v5/teacher.png',
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
            'assets/images/vuesax/v5/gift.png',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const OtherBenefitsScreen(),
                ),
              );
            },
          ),
          // _actionCircle(
          //   'home.fnc_practice_teacher'.tr(),
          //   'assets/images/vuesax/v5/dumbbell-large-minimalistic-svgrepo-com.png',
          //   onTap: () {
          //     CommonNotification.show(
          //       context,
          //       message: "home.features_coming_soon".tr(),
          //     );
          //   },
          // ),
        ],
      ),
    );
  }

  Widget _actionCircle(String label, String iconPath, {VoidCallback? onTap}) {
    // Sử dụng màu đỏ thương hiệu từ login.dart hoặc các nút đặt chỗ
    // const Color brandRed = Color(0xFFDA212D);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: context.resW(65),
            height: context.resW(65),
            padding: EdgeInsets.all(context.resW(10)),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                color: Color(0xFFEF4822),
                width: 2, // độ dày viền
              ),
            ),
            child: Image.asset(
              iconPath,
              fit: BoxFit.contain,
              // colorFilter: const ColorFilter.mode(brandRed, BlendMode.srcIn),
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
    // Mã màu đỏ mới (đã giảm độ rực xuống)
    const Color mutedRed = Color(0xFF8E0404);
    const Color mutedBorderRed = Color(0xFF8B0404);

    return Container(
      width: double.infinity,
      height: context.resH(134),
      margin: EdgeInsets.symmetric(horizontal: context.resW(20)),
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        // 1. GRADIENT: Sử dụng màu đỏ trầm hơn để giảm độ gắt
        gradient: const LinearGradient(
          begin: Alignment(0.07, 0.58),
          end: Alignment(1.04, 0.56),
          colors: [mutedRed, Color(0xFF000000)],
        ),
        shape: RoundedRectangleBorder(
          // Cập nhật viền đồng bộ với màu nền mới
          side: const BorderSide(width: 1, color: mutedBorderRed),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      child: Stack(
        children: [
          // 2. HÌNH NỀN: Giữ nguyên logic hiển thị
          Positioned.fill(
            child: Opacity(
              opacity: 0.4,
              child: Image.asset(
                "assets/images/v5/home_empty.png",
                fit: BoxFit.cover,
              ),
            ),
          ),

          // 3. NỘI DUNG CĂN DƯỚI
          Positioned(
            left: 0,
            right: 0,
            bottom: context.resH(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("⭐", style: TextStyle(fontSize: 12)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        message,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: context.resClamp(12, 11, 14),
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          height: 1.50,
                        ),
                      ),
                    ),
                    const Text("⭐", style: TextStyle(fontSize: 12)),
                  ],
                ),
                if (btnText != null) ...[
                  SizedBox(height: context.resH(8)),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const MasterScreen(initialIndex: 1),
                        ),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.resW(24),
                        vertical: context.resH(8),
                      ),
                      decoration: ShapeDecoration(
                        color: const Color(0xFFD92229),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      child: Text(
                        btnText,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: context.resClamp(14, 12, 16),
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          height: 1.50,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComingSoonState(String message, String? btnText) {
    return Container(
      width: double.infinity,
      height: context.resH(127), // Chiều cao responsive
      margin: EdgeInsets.symmetric(horizontal: context.resW(20)),
      decoration: ShapeDecoration(
        // 1. GRADIENT: Chuyển từ màu tím đậm sang xám sáng
        gradient: LinearGradient(
          begin: const Alignment(0.00, 0.58),
          end: const Alignment(0.98, 0.56),
          colors: [const Color(0xFF2A051B), const Color(0xFFEBEBEB)],
        ),
        shape: RoundedRectangleBorder(
          side: const BorderSide(
            width: 1,
            color: Color(0xFFFE75B4),
          ), // Viền hồng
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: ClipRRect(
        // Đảm bảo hình ảnh không tràn ra ngoài bo góc
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: [
            // 2. HÌNH ẢNH "COMING SOON" (BÊN TRÁI)
            Positioned(
              left: context.resW(11),
              top: context.resH(17),
              child: SizedBox(
                width: context.resW(94),
                height: context.resW(94),
                child: Image.asset(
                  "assets/images/v5/coming_soon_sign.png", // Thay bằng path ảnh của bạn
                  fit: BoxFit.contain,
                ),
              ),
            ),

            // 3. HÌNH ẢNH MINH HỌA YOGA (BÊN PHẢI)
            Positioned(
              right: context.resW(-20), // Đẩy nhẹ ra biên để tạo hiệu ứng tràn
              top: context.resH(-10),
              child: Transform(
                // Giữ nguyên logic rotate và scale nếu cần thiết
                transform: Matrix4.diagonal3Values(1.0, 1.0, 1.0),
                child: SizedBox(
                  width: context.resW(171),
                  height: context.resW(171),
                  child: Image.asset(
                    "assets/images/v5/yoga_illustration.png", // Thay bằng path ảnh của bạn
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ],
        ),
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
            onClickToShare: () {
              // debugPrint("Home: ${cardData['membershipNumber']}");
              CommonUserShareCardWidget.show(
                context: context,
                membershipNumber: cardData['membershipNumber'],
              );
            },
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
    final bool shouldShowViewAllCard = _upcomingClasses.length > displayCount;
    final int itemCount = shouldShowViewAllCard
        ? displayCount + 1
        : displayCount;

    return SizedBox(
      height: context.resH(265).clamp(250, 280),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.only(left: context.resW(20)),
        itemCount: itemCount,
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
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ClassScreen()),
        );
      },
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
