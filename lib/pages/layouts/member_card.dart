// import 'package:californiaflutter/helpers/session_manager.dart';
import 'package:californiaflutter/bases/loading_wrapper.dart';
import 'package:californiaflutter/helpers/convert_model.dart';
import 'package:californiaflutter/helpers/session_manager.dart';
import 'package:californiaflutter/helpers/size_utils.dart';
import 'package:californiaflutter/pages/shared/common_background.dart';
import 'package:californiaflutter/pages/shared/common_membership_card.dart';
import 'package:californiaflutter/pages/shared/common_modal.dart';
import 'package:californiaflutter/pages/widgets/common_user_share_card.dart';
import 'package:easy_localization/easy_localization.dart';
// import 'package:californiaflutter/pages/shared/language_bottom_sheet.dart';
// import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:qr_flutter/qr_flutter.dart';
// import 'package:screen_brightness/screen_brightness.dart';
// import 'package:flutter_svg/svg.dart';

class MemberListScreen extends StatefulWidget {
  final List<Map<String, dynamic>> cards;
  const MemberListScreen({super.key, required this.cards});

  @override
  State<MemberListScreen> createState() => _MemberListScreenState();
}

class _MemberListScreenState extends State<MemberListScreen>
    with LoadingWrapper {
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

    final _ = context.locale;

    return Scaffold(
      backgroundColor: const Color(0xFF151515), // Color-Base-gray
      body: Stack(
        children: [
          // LỚP 1: BACKGROUND MỜ
          CommonBackgroundWidget.buildBackgroundImage(
            context,
            dotenv.get('IMAGES_BG_BENEFIT_V3_LAYER'),
          ),

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
                        'member_card.title_member_card'.tr(),
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
              'member_card.pick_member_card'.tr(),
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
    // debugPrint(data.toString());
    return CommonMembershipCard(
      data: data,
      // Quản lý trạng thái mở mã QR từ biến _activeCardId của màn hình
      isExpanded: _activeCardId == uniqueKey,
      onToggle: () => setState(() {
        _activeCardId = (_activeCardId == uniqueKey ? null : uniqueKey);
      }),
      onQrClick: (qrData) {
        // Logic hiển thị QR lớn nếu cần
        // _showBigQrModal(context, qrData);
        CommonModalWidget.showBigQrModal(context: context, qrData: qrData);
      },
      onClickToShare: () {
        CommonUserShareCardWidget.show(
          context: context,
          membershipNumber: data['membershipNumber'],
        );
      },
    );
  }
}
