// import 'package:californiaflutter/helpers/session_manager.dart';
import 'package:californiaflutter/helpers/convert_model.dart';
import 'package:californiaflutter/helpers/session_manager.dart';
import 'package:californiaflutter/helpers/size_utils.dart';
import 'package:californiaflutter/pages/shared/common_membership_card.dart';
// import 'package:californiaflutter/pages/shared/language_bottom_sheet.dart';
// import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
// import 'package:flutter_svg/svg.dart';

class MemberListScreen extends StatefulWidget {
  final List<Map<String, dynamic>> cards;
  const MemberListScreen({super.key, required this.cards});

  @override
  State<MemberListScreen> createState() => _MemberListScreenState();
}

class _MemberListScreenState extends State<MemberListScreen> {
  String? _activeCardId;

  List<Map<String, dynamic>> _memberCards = [];

  @override
  void initState() {
    super.initState();
    _memberCards = buildMemberCards(SessionManager.member);
  }

  @override
  Widget build(BuildContext context) {
    final double systemBottomPadding = MediaQuery.of(context).padding.bottom;
    // Chiều cao Navbar từ MasterScreen để tránh che khuất nội dung
    final double navBarHeight = context.resH(80);

    return Scaffold(
      backgroundColor: const Color(0xFF151515), // Color-Base-gray
      body: Stack(
        children: [
          // LỚP 1: BACKGROUND MỜ
          _buildBackground(context),

          // LỚP 2: NỘI DUNG CHÍNH
          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // _buildHeader(context),

                // Tiêu đề màn hình
                Padding(
                  padding: EdgeInsets.only(
                    left: context.resW(8), // Giảm lề trái để Icon sát lề hơn
                    right: context.resW(20),
                    top: context.resH(12),
                    bottom: context.resH(12),
                  ),
                  child: Row(
                    children: [
                      // Nút mũi tên quay lại
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons
                              .arrow_back_ios_new, // Sử dụng icon ios cho đồng bộ thiết kế
                          color: Colors.white,
                          size: context.resW(20), // Responsive kích thước icon
                        ),
                      ),
                      // Tiêu đề văn bản
                      Text(
                        'Thẻ hội viên',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: context.resClamp(
                            18,
                            16,
                            22,
                          ), // Giữ nguyên font responsive của bạn
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.fromLTRB(
                      context.resW(20),
                      0,
                      context.resW(20),
                      navBarHeight + systemBottomPadding + 20,
                    ),
                    itemCount: _memberCards.length,
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          // CHỈ HIỂN THỊ GHIM THẺ Ở PHẦN TỬ ĐẦU TIÊN (Index 0)
                          if (index == 0) ...[
                            _buildPinSection(context),
                            SizedBox(height: context.resH(8)),
                          ],

                          // Hiển thị thẻ hội viên cho mọi index
                          _buildSingleMembershipCard(
                            context,
                            _memberCards[index],
                            index,
                          ),

                          // Khoảng cách giữa các thẻ
                          SizedBox(height: context.resH(24)),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- CÁC HÀM UI HELPER THEO CODE MỚI ---

  Widget _buildBackground(BuildContext context) {
    return Positioned(
      left: -47,
      top: -33,
      child: Opacity(
        opacity: 0.12,
        child: Container(
          width: context.resW(813),
          height: context.resH(789),
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/backgound_benefit_v3_layer.png"),
              fit: BoxFit.fill,
            ),
          ),
        ),
      ),
    );
  }

  // Widget _buildHeader(BuildContext context) {
  //   return Container(
  //     width: double.infinity,
  //     height: context.resH(57),
  //     padding: EdgeInsets.only(left: context.resW(20), right: context.resW(8)),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //       children: [
  //         // Logo
  //         SizedBox(
  //           width: context.resW(141),
  //           height: context.resH(24),
  //           child: SvgPicture.asset(
  //             'assets/images/CWG-Logo-White.svg',
  //             fit: BoxFit.contain,
  //           ),
  //         ),
  //         // Cụm Icons
  //         Row(
  //           children: [
  //             _buildLanguageButton(context),
  //             SizedBox(width: context.resW(10)),
  //             _buildIconButton(
  //               context,
  //               'assets/images/vuesax/document-text.svg',
  //             ),
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildPinSection(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(
              Icons.push_pin_outlined,
              color: Color(0xFFD1D5DB),
              size: 18,
            ),
            SizedBox(width: context.resW(8)),
            Text(
              'Ghim thẻ',
              style: TextStyle(
                color: const Color(0xFFD1D5DB),
                fontSize: context.resClamp(14, 12, 16),
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
        const Icon(Icons.arrow_forward_ios, color: Color(0xFFD1D5DB), size: 14),
      ],
    );
  }

  // Sửa lại hàm này: Chỉ nhận 1 dữ liệu thẻ và trả về 1 Widget CommonMembershipCard
  Widget _buildSingleMembershipCard(
    BuildContext context,
    Map<String, dynamic> data,
    int index,
  ) {
    final String uniqueKey = "${index}_${data['id']}";
    debugPrint(data.toString());
    return CommonMembershipCard(
      data: data,
      // Quản lý trạng thái mở mã QR từ biến _activeCardId của màn hình
      isExpanded: _activeCardId == uniqueKey,
      onToggle: () => setState(() {
        _activeCardId = (_activeCardId == uniqueKey ? null : uniqueKey);
      }),
      onQrClick: (qrData) {
        // Logic hiển thị QR lớn nếu cần
        _showBigQrModal(context, qrData);
      },
    );
  }

  // --- CÁC WIDGET NHỎ HỖ TRỢ ---

  // TextStyle _cardTextStyle(BuildContext context, {bool isBold = false}) {
  //   return TextStyle(
  //     color: Colors.white,
  //     fontSize: context.resClamp(12, 10, 14),
  //     fontWeight: isBold ? FontWeight.bold : FontWeight.w400,
  //     height: 1.5,
  //     shadows: const [
  //       Shadow(color: Colors.black45, blurRadius: 2, offset: Offset(1, 1)),
  //     ],
  //   );
  // }

  // Widget _buildCardAction(
  //   BuildContext context,
  //   String title, {
  //   required bool isPrimary,
  // }) {
  //   return GestureDetector(
  //     onTap: onTap,
  //     child: Container(
  //       height: context.resH(34), // Thu nhỏ chiều cao để vừa vặn trong thẻ
  //       alignment: Alignment.center,
  //       decoration: BoxDecoration(
  //         color: isPrimary
  //             ? const Color(0xFFDA2128)
  //             : Colors.black.withValues(alpha: 0.3), // Nền mờ cho nút QR
  //         borderRadius: BorderRadius.circular(4),
  //         border: Border.all(
  //           color: Colors.white.withValues(alpha: 0.5),
  //           width: 0.5,
  //         ), // Viền mảnh cho sang trọng
  //       ),
  //       child: Text(
  //         title,
  //         style: TextStyle(
  //           color: Colors.white,
  //           fontSize: context.resClamp(11, 10, 13),
  //           fontWeight: FontWeight.w500,
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildIconButton(BuildContext context, String svgPath) {
  //   return Container(
  //     padding: EdgeInsets.all(context.resW(8)),
  //     decoration: const BoxDecoration(shape: BoxShape.circle),
  //     child: SvgPicture.asset(
  //       svgPath,
  //       width: 24,
  //       colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
  //     ),
  //   );
  // }

  // Widget _buildLanguageButton(BuildContext context) {
  //   return GestureDetector(
  //     onTap: () => LanguageBottomSheet.show(context: context),
  //     child: Row(
  //       children: [
  //         SvgPicture.asset(
  //           context.locale.languageCode == 'vi'
  //               ? 'assets/images/vietnam.svg'
  //               : 'assets/images/kingdom.svg',
  //           width: 20,
  //         ),
  //         SizedBox(width: context.resW(8)),
  //         Text(
  //           context.locale.languageCode == 'vi' ? 'Tiếng Việt' : 'English',
  //           style: const TextStyle(color: Colors.white, fontSize: 12),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  void _showBigQrModal(BuildContext context, String qrData) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Cho phép modal tự co giãn theo nội dung
      backgroundColor: const Color(0xFF151515), // Màu nền tối đồng bộ thiết kế
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.only(top: context.resH(24)),
          clipBehavior: Clip.antiAlias,
          decoration: const BoxDecoration(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thanh gạt (Handle bar) giúp người dùng biết có thể vuốt xuống để đóng
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              Container(
                width: double.infinity, // Thay thế 375 cố định để responsive
                padding: EdgeInsets.symmetric(
                  horizontal: context.resW(20),
                  vertical: context.resH(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 1. KHUNG TRẮNG CHỨA MÃ QR
                    Container(
                      padding: EdgeInsets.all(
                        context.resW(12),
                      ), // Đệm xung quanh QR
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(
                            width: 1,
                            color: Color(0xFFE8E8E8),
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Kích thước QR 173x173 responsive
                          QrImageView(
                            data: qrData,
                            version: QrVersions.auto,
                            size: context.resW(173),
                            padding: EdgeInsets.zero,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: context.resH(16)), // Khoảng cách 16px
                    // 2. TEXT HƯỚNG DẪN
                    SizedBox(
                      width: context.resW(335),
                      child: Text(
                        'Vui lòng đưa mã này cho lễ tân để check-in',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: context.resClamp(
                            16,
                            14,
                            18,
                          ), // Responsive font
                          fontWeight: FontWeight.w500,
                          height: 1.50,
                        ),
                      ),
                    ),

                    // Thêm khoảng đệm dưới cùng cho đẹp
                    SizedBox(height: context.resH(40)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
