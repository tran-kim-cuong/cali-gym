import 'package:californiaflutter/bases/loading_wrapper.dart';
import 'package:californiaflutter/helpers/size_utils.dart';
import 'package:californiaflutter/models/user_card_model.dart';
import 'package:californiaflutter/pages/shared/common_notification.dart';
import 'package:californiaflutter/services/common_user_share_card_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/svg.dart';

class CommonUserShareCardWidget extends StatefulWidget {
  final String membershipNumber; // Nhận từ member_card.dart
  final Function(CardUserModel)? onConfirm;

  const CommonUserShareCardWidget({
    super.key,
    required this.membershipNumber,
    required this.onConfirm,
  });

  static void show({
    required BuildContext context,
    required String membershipNumber,
    Function(CardUserModel)? onConfirm,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CommonUserShareCardWidget(
        membershipNumber: membershipNumber,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  State<StatefulWidget> createState() => _CommonUserShareCardWidgetState();
}

class _CommonUserShareCardWidgetState extends State<CommonUserShareCardWidget>
    with LoadingWrapper {
  List<CardUserModel> users = [];
  CardUserModel? _selectedUser;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadUsersSharedCard();
    });
  }

  Future<void> loadUsersSharedCard() async {
    await handleApi(context, () async {
      final result = await CommonUserShareCardService.loadUsersSharedCard(
        widget.membershipNumber,
        dotenv.get('CRM_BASIC_AUTHORIZATION'),
      );

      if (!mounted) return;

      setState(() {
        users = result;
      });

      await WidgetsBinding.instance.endOfFrame;
    }());
  }

  @override
  Widget build(BuildContext context) {
    final double bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      // Độ rộng responsive theo thiết bị
      width: double.infinity,
      decoration: ShapeDecoration(
        color: const Color(0xFF3E3E3E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(context.res(30)),
            topRight: Radius.circular(context.res(30)),
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Header: Tiêu đề và Nút đóng
          _buildHeader(context),

          // 2. Danh sách người dùng (Scrollable nếu quá dài)
          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: users
                    .map((user) => _buildUserItem(context, user))
                    .toList(),
              ),
            ),
          ),

          // 3. Action Buttons (Huỷ & Xác nhận)
          _buildActionRow(context, bottomPadding),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: context.resW(20),
        vertical: context.resH(12),
      ),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF4D4E4F), width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'common.lbl_title_common_user_share_card'
                .tr(), // Có thể dùng .tr() nếu có đa ngôn ngữ
            style: TextStyle(
              color: Colors.white,
              fontSize: context.resClamp(16, 15, 18),
              fontWeight: FontWeight.w600,
              fontFamily: 'Inter',
            ),
          ),
          // Nút đóng (X)
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Color(0xFF3E3E3E),
                // shape: BoxShape.circle,
              ),
              child: SvgPicture.asset(
                "assets/images/vuesax/close_small.svg",
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserItem(BuildContext context, CardUserModel user) {
    final bool isSelected = _selectedUser?.clientId == user.clientId;

    return InkWell(
      onTap: user.isActive
          ? null
          : () {
              setState(() {
                _selectedUser = user;
              });
            },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: context.resW(20),
          vertical: context.resH(12),
        ),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFF4D4E4F), width: 0.5),
          ),
        ),
        child: Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween, // Đẩy nhãn sang phải
          children: [
            // 1. Khối thông tin bên trái
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.fullName, //
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: context.resClamp(14, 13, 16),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.displayClientIdAndPhoneNo, //
                    style: TextStyle(
                      color: const Color(0xFF9A9A9A),
                      fontSize: context.resClamp(12, 11, 14),
                    ),
                  ),
                ],
              ),
            ),

            // 2. Nhãn trạng thái bên phải (Chỉ hiện khi isActive = true)
            if (isSelected)
              _buildSelectedTick(context)
            else if (user.isActive) //
              _buildStatusBadge(context),
          ],
        ),
      ),
    );
  }

  // Widget nhãn trạng thái màu xanh lá
  Widget _buildStatusBadge(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.resW(8),
        vertical: context.resH(4),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF27C36A), // Màu xanh lá từ thiết kế
        borderRadius: BorderRadius.circular(context.resW(6)),
      ),
      child: Text(
        'common.lbl_status_item_user_share_card'
            .tr(), // Bạn có thể dùng .tr() nếu cần đa ngôn ngữ
        style: TextStyle(
          color: Colors.white,
          fontSize: context.resClamp(12, 10, 13),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildActionRow(BuildContext context, double bottomPadding) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        context.resW(20),
        context.resH(12),
        context.resW(20),
        // XỬ LÝ HOME INDICATOR: Sát mép nếu có, đệm 20px nếu không
        bottomPadding > 0 ? bottomPadding + 10 : context.resH(20),
      ),
      child: Row(
        spacing: context.resW(16),
        children: [
          // Nút Huỷ
          Expanded(
            child: _customButton(
              context: context,
              text: 'common.btn_cancel'.tr(),
              color: const Color(0xFF6B6B6B),
              textColor: const Color(0xFFC7C7C7),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          // Nút Xác nhận
          Expanded(
            child: _customButton(
              context: context,
              text: 'common.accept'.tr(),
              color: const Color(0xFFD92229),
              textColor: Colors.white,
              onPressed: () async {
                if (_selectedUser == null) {
                  CommonNotification.show(
                    context,
                    message: "member_card.msg_select_one_user".tr(),
                    isError: true,
                  );
                  return;
                } else {
                  await handleApi(context, () async {
                    final result =
                        await CommonUserShareCardService.confirmUserShareCard(
                          widget.membershipNumber,
                          dotenv.get('CRM_BASIC_AUTHORIZATION'),
                          _selectedUser?.clientId ?? '',
                          languageCode: context.locale.languageCode,
                        );

                    final (message, code) = result;

                    if (code == 200) {
                      setState(() {});

                      await WidgetsBinding.instance.endOfFrame;

                      if (!context.mounted) return;

                      CommonNotification.show(
                        context,
                        message: message ?? 'N/A',
                      );
                      Navigator.pop(context);
                    } else if (code == 500) {
                      if (!context.mounted) return;
                      CommonNotification.show(
                        context,
                        message: "common.msg_error_500".tr(),
                        isError: true
                      );
                    } else {}
                  }());
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _customButton({
    required BuildContext context,
    required String text,
    required Color color,
    required Color textColor,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: context.resH(48).clamp(44.0, 52.0), // Button size responsive
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          elevation: 0,
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: TextStyle(
            color: textColor,
            fontSize: context.resClamp(16, 15, 17),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedTick(BuildContext context) {
    return SizedBox(
      width: context.resW(24),
      height: context.resW(24),
      child: SvgPicture.asset(
        "assets/images/vuesax/select-item.svg", // Đường dẫn file SVG tích đỏ của bạn
        // Nếu file SVG gốc chưa có màu đỏ, bạn có thể ép màu tại đây
        colorFilter: const ColorFilter.mode(Color(0xFFD92229), BlendMode.srcIn),
        fit: BoxFit.contain,
      ),
    );
  }
}
