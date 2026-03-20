import 'package:californiaflutter/bases/app_session.dart';
import 'package:californiaflutter/bases/loading_wrapper.dart';
import 'package:californiaflutter/helpers/convert_model.dart';
import 'package:californiaflutter/helpers/member_cache_manager.dart';
import 'package:californiaflutter/helpers/session_manager.dart';
import 'package:californiaflutter/helpers/size_utils.dart';
import 'package:californiaflutter/pages/layouts/history_schedule.dart';
import 'package:californiaflutter/pages/layouts/login.dart';
import 'package:californiaflutter/pages/layouts/member_card.dart';
import 'package:californiaflutter/pages/layouts/personal_info.dart';
import 'package:californiaflutter/pages/shared/common_background.dart';
import 'package:californiaflutter/pages/shared/language_bottom_sheet.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with LoadingWrapper {
  bool _isNotificationEnabled = true;

  @override
  Widget build(BuildContext context) {
    final double systemTopPadding = MediaQuery.of(context).padding.top;
    final double systemBottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFF151515),
      body: Stack(
        children: [
          // 1. BACKGROUND LAYER (Opacity 0.15)
          CommonBackgroundWidget.buildBackgroundImage(
            context,
            dotenv.get('IMAGES_BG_HOME_V3_LAYER'),
          ),

          // 2. CONTENT LAYER
          Column(
            children: [
              // Header giả định (9:41)
              SizedBox(height: systemTopPadding + context.resH(8)),

              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.only(
                    bottom: systemBottomPadding, // + context.resH(100),
                  ),
                  child: Column(
                    children: [
                      // USER AVATAR & NAME
                      _buildUserInfo(),
                      SizedBox(height: context.resH(32)),

                      // SECTION: CÁ NHÂN
                      // _buildSectionTitle('profile.sec_privacy'.tr()),
                      // _buildMenuItem(
                      //   'assets/images/profiles/user.svg',
                      //   'profile.sec_privacy_info'.tr(),
                      // ),
                      // _buildMenuItem(
                      //   'assets/images/profiles/card.svg',
                      //   'profile.sec_privacy_member_card'.tr(),
                      // ),
                      // _buildMenuItem(
                      //   'assets/images/vuesax/teacher.svg',
                      //   'profile.sec_privacy_future_class'.tr(),
                      // ),
                      // _buildMenuItem(
                      //   'assets/images/vuesax/document-text.svg',
                      //   'profile.sec_privacy_my_bill'.tr(),
                      // ),
                      // _buildMenuItem(
                      //   'assets/images/vuesax/ticket-discount.svg',
                      //   'profile.sec_privacy_my_voucher'.tr(),
                      // ),

                      // SizedBox(height: context.resH(16)),

                      // // SECTION: CÀI ĐẶT
                      // _buildSectionTitle('profile.sec_settings'.tr()),
                      // _buildSwitchItem(
                      //   'assets/images/profiles/notification.svg',
                      //   'profile.sec_settings_notification'.tr(),
                      // ),
                      // _buildLanguageItem(
                      //   'assets/images/profiles/global.svg',
                      //   'profile.sec_settings_language'.tr(),
                      // ),

                      // SizedBox(height: context.resH(16)),

                      // // SECTION: HỖ TRỢ
                      // _buildSectionTitle('profile.sec_support'.tr()),
                      // _buildMenuItem(
                      //   'assets/images/profiles/messages.svg',
                      //   'profile.sec_support_comment'.tr(),
                      // ),
                      // _buildMenuItem(
                      //   'assets/images/profiles/document.svg',
                      //   'profile.sec_support_term_condition'.tr(),
                      // ),
                      // _buildMenuItem(
                      //   'assets/images/profiles/lock.svg',
                      //   'profile.sec_support_security'.tr(),
                      // ),
                      // _buildMenuItem(
                      //   'assets/images/profiles/message-question.svg',
                      //   'profile.sec_support_center'.tr(),
                      // ),

                      // SizedBox(height: context.resH(24)),

                      // SECTION: CÁ NHÂN
                      _buildSectionTitle('profile.sec_privacy'.tr()),
                      _buildMenuItem(
                        'assets/images/profiles/user.svg',
                        'profile.sec_privacy_info'.tr(),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PersonalInfoScreen(),
                          ),
                        ),
                      ),
                      _buildMenuItem(
                        'assets/images/profiles/card.svg',
                        'profile.sec_privacy_member_card'.tr(),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MemberListScreen(
                              cards: buildMemberCards(SessionManager.member),
                            ),
                          ),
                        ),
                      ),
                      _buildMenuItem(
                        'assets/images/vuesax/teacher.svg',
                        'profile.sec_privacy_future_class'.tr(),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const HistoryScheduleScreen(),
                          ),
                        ),
                      ),
                      SizedBox(height: context.resH(16)),

                      // SECTION: CÀI ĐẶT
                      _buildSectionTitle('profile.sec_settings'.tr()),
                      _buildSwitchItem(
                        'assets/images/profiles/notification.svg',
                        'profile.sec_settings_notification'.tr(),
                      ),
                      _buildLanguageItem(
                        'assets/images/profiles/global.svg',
                        'profile.sec_settings_language'.tr(),
                      ),
                      SizedBox(height: context.resH(16)),

                      // SECTION: HỖ TRỢ
                      _buildSectionTitle('profile.sec_support'.tr()),
                      _buildLinkItem(
                        'assets/images/profiles/document.svg',
                        'profile.sec_support_term_condition'.tr(),
                        'https://cali.vn/dieu-khoan-su-dung',
                      ),
                      _buildLinkItem(
                        'assets/images/profiles/lock.svg',
                        'profile.sec_support_security'.tr(),
                        'https://cali.vn/chinh-sach-bao-mat',
                      ),
                      SizedBox(height: context.resH(16)),

                      // NÚT ĐĂNG XUẤT
                      _buildLogoutButton(),

                      // VERSION
                      Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: context.resH(20),
                        ),
                        child: Text(
                          'Version 1.0.1',
                          style: TextStyle(
                            color: const Color(0xFF9A9A9A),
                            fontSize: context.resClamp(12, 11, 13),
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // MARK: - UI Helper Methods

  Widget _buildUserInfo() {
    return ValueListenableBuilder<String>(
      valueListenable: SessionManager.sTenKhNotifier,
      builder: (context, name, _) {
        return Column(
          children: [
            Image.asset(
              'assets/images/logo_profile.png',
              height: context.resH(80),
              fit: BoxFit.contain,
            ),
            SizedBox(height: context.resH(12)),
            Text(
              name,
              style: TextStyle(
                color: Colors.white,
                fontSize: context.resClamp(16, 14, 18),
                fontFamily: 'Mulish',
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        context.resW(20),
        context.resH(12),
        context.resW(20),
        context.resH(8),
      ),
      child: Text(
        title,
        style: TextStyle(
          color: const Color(0xFF9A9A9A),
          fontSize: context.resClamp(14, 12, 15),
          fontFamily: 'Inter',
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // Widget _buildMenuItem(String iconPath, String label) {
  //   return InkWell(
  //     onTap: () {},
  //     child: Container(
  //       height: context.resH(48),
  //       padding: EdgeInsets.symmetric(horizontal: context.resW(20)),
  //       child: Row(
  //         children: [
  //           // Icon Placeholder (Sử dụng icon hệ thống nếu không có SVG)
  //           SizedBox(
  //             width: context.resW(20), // Kích thước responsive
  //             height: context.resW(20),
  //             child: SvgPicture.asset(
  //               iconPath,
  //               // Đổi màu SVG sang trắng để đồng bộ với thiết kế
  //               colorFilter: const ColorFilter.mode(
  //                 Colors.white,
  //                 BlendMode.srcIn,
  //               ),
  //               fit: BoxFit.contain,
  //             ),
  //           ),
  //           SizedBox(width: context.resW(12)),
  //           Expanded(
  //             child: Text(
  //               label,
  //               style: TextStyle(
  //                 color: Colors.white,
  //                 fontSize: context.resClamp(14, 13, 15),
  //                 fontFamily: 'Inter',
  //               ),
  //             ),
  //           ),
  //           const Icon(Icons.chevron_right, color: Color(0xFF9A9A9A), size: 16),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget _buildMenuItem(String iconPath, String label, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap ?? () {},
      child: Container(
        height: context.resH(48),
        padding: EdgeInsets.symmetric(horizontal: context.resW(20)),
        child: Row(
          children: [
            SizedBox(
              width: context.resW(20),
              height: context.resW(20),
              child: SvgPicture.asset(
                iconPath,
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(width: context.resW(12)),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: context.resClamp(14, 13, 15),
                  fontFamily: 'Inter',
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFF9A9A9A), size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchItem(String iconPath, String label) {
    return Container(
      height: context.resH(48),
      padding: EdgeInsets.symmetric(horizontal: context.resW(20)),
      child: Row(
        children: [
          SizedBox(
            width: context.resW(20), // Kích thước responsive
            height: context.resW(20),
            child: SvgPicture.asset(
              iconPath,
              // Đổi màu SVG sang trắng để đồng bộ với thiết kế
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
              fit: BoxFit.contain,
            ),
          ),
          SizedBox(width: context.resW(12)),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: context.resClamp(14, 13, 15),
                fontFamily: 'Inter',
              ),
            ),
          ),
          // iOS-style Toggle
          Switch(
            value: _isNotificationEnabled,
            onChanged: (val) => setState(() => _isNotificationEnabled = val),
            activeThumbColor: Colors.white,
            activeTrackColor: const Color(0xFFE04A50),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: const Color(0xFF3E3E3E),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageItem(String iconPath, String label) {
    // 1. Lấy thông tin ngôn ngữ hiện tại để đổi cờ và text động
    final currentCode = context.locale.languageCode;
    final String langText = currentCode == 'vi' ? 'VI' : 'EN';
    final String flagAsset = currentCode == 'vi'
        ? 'assets/images/vietnam.svg'
        : 'assets/images/kingdom.svg';

    return InkWell(
      onTap: () => LanguageBottomSheet.show(context: context),
      child: Container(
        height: context.resH(48),
        padding: EdgeInsets.symmetric(horizontal: context.resW(20)),
        child: Row(
          children: [
            // 2. Icon quả địa cầu bên trái
            SizedBox(
              width: context.resW(20),
              height: context.resW(20),
              child: SvgPicture.asset(
                iconPath,
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(width: context.resW(12)),

            // 3. Nhãn "Ngôn ngữ"
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: context.resClamp(14, 13, 15),
                  fontFamily: 'Inter',
                ),
              ),
            ),

            // 4. Khung chọn ngôn ngữ dạng Pill
            Container(
              padding: const EdgeInsets.only(
                top: 2,
                left: 2,
                right: 10,
                bottom: 2,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF3E3E3E), // Màu nền xám của pill
                borderRadius: BorderRadius.circular(32),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Hình tròn chứa cờ quốc gia
                  Container(
                    width: 24,
                    height: 24,
                    clipBehavior: Clip.antiAlias,
                    decoration: const BoxDecoration(shape: BoxShape.circle),
                    child: SvgPicture.asset(flagAsset, fit: BoxFit.cover),
                  ),
                  const SizedBox(width: 8),
                  // Chữ hiển thị mã (VI/EN)
                  Text(
                    langText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLinkItem(String iconPath, String label, String url) {
    return InkWell(
      onTap: () async {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      child: Container(
        height: context.resH(48),
        padding: EdgeInsets.symmetric(horizontal: context.resW(20)),
        child: Row(
          children: [
            SizedBox(
              width: context.resW(20),
              height: context.resW(20),
              child: SvgPicture.asset(
                iconPath,
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(width: context.resW(12)),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: context.resClamp(14, 13, 15),
                  fontFamily: 'Inter',
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFF9A9A9A), size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return InkWell(
      onTap: () async {
        await _handleLogout();
      },
      child: Container(
        height: context.resH(48),
        padding: EdgeInsets.symmetric(horizontal: context.resW(20)),
        child: Row(
          children: [
            const Icon(Icons.logout, color: Color(0xFFFF707A), size: 20),
            SizedBox(width: context.resW(12)),
            Text(
              'profile.btn_logout'.tr(),
              style: TextStyle(
                color: const Color(0xFFFF707A), // Màu đỏ lỗi theo snippet
                fontSize: context.resClamp(14, 13, 15),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogout() async {
    // 1. Sử dụng handleApi để hiển thị loading
    await handleApi(
      context,
      Future.delayed(const Duration(milliseconds: 500), () async {
        // 2. Clear dữ liệu dưới Disk (SharedPreferences)
        // Đảm bảo SessionManager đã có hàm logout() hoặc clear()
        await SessionManager.logout();
        await MemberCacheManager().clearMemberCache();

        // 3. Clear dữ liệu trên RAM (AppSession)
        AppSession().clear();
      }),
    );

    if (!mounted) return;

    // 4. Move ra màn hình Welcome/Login và xóa sạch lịch sử stack
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false, // Không cho phép nhấn Back quay lại trang cá nhân
    );
  }
}
