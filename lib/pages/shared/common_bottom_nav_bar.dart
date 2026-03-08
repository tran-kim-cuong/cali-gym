import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:californiaflutter/helpers/size_utils.dart';
import 'package:flutter_svg/svg.dart';

class CommonBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CommonBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final Color _activeColor = const Color(0xFFE1494F);
  final Color _inactiveColor = const Color(0xFF9A9A9A);

  @override
  Widget build(BuildContext context) {
    final _ = context
        .locale; // THÊM DÒNG NÀY: Ép widget lắng nghe sự thay đổi của locale

    // 1. Lấy thông số Padding đáy của hệ thống
    final double systemPaddingBottom = MediaQuery.of(context).padding.bottom;

    // 2. Logic điều chỉnh:
    // Nếu có dải 3 nút (padding = 0) -> Thêm khoảng đệm 12px để Icon không dính sát nút
    // Nếu dùng cử chỉ (padding > 0) -> Dùng chính padding đó để né dải gạch ngang
    final double customBottomPadding = systemPaddingBottom > 0
        ? systemPaddingBottom
        : context.resH(12);

    return Container(
      width: double.infinity,
      // Tổng chiều cao = Chiều cao nội dung + Khoảng đệm thông minh
      height: context.resH(60).clamp(55, 75) + customBottomPadding,
      decoration: const BoxDecoration(
        color: Color(0xFF242424),
        border: Border(top: BorderSide(color: Colors.white10, width: 0.5)),
      ),
      padding: EdgeInsets.only(bottom: customBottomPadding), // Đẩy nội dung lên
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _navItem(
            context,
            'assets/images/vuesax/home.svg',
            'navbar.btn_home'.tr(),
            0,
          ),
          _navItem(
            context,
            'assets/images/vuesax/teacher.svg',
            "navbar.btn_class".tr(),
            1,
          ),
          _navItem(
            context,
            'assets/images/vuesax/ticket-discount.svg',
            "navbar.btn_loyalty".tr(),
            2,
            isEnabled: false,
          ),
          _navItem(
            context,
            'assets/images/vuesax/profile-circle.svg',
            "navbar.btn_profile".tr(),
            3,
            isEnabled: false,
          ),
        ],
      ),
    );
  }

  Widget _navItem(
    BuildContext context,
    String svgPath,
    String label,
    int index, {
    bool isEnabled = true,
  }) {
    bool isSelected = currentIndex == index;

    // Xác định màu sắc dựa trên trạng thái chọn
    final Color currentColor = isSelected ? _activeColor : _inactiveColor;

    return Expanded(
      child: InkWell(
        onTap: isEnabled ? () => onTap(index) : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // SỬ DỤNG SVGPicture THAY CHO ICON
            SvgPicture.asset(
              isSelected ? svgPath.replaceAll('.svg', '-bold.svg') : svgPath,
              // Áp dụng màu sắc cho SVG
              colorFilter: ColorFilter.mode(currentColor, BlendMode.srcIn),
              // Kích thước Responsive
              width: context.resW(24).clamp(22.0, 26.0),
              height: context.resW(24).clamp(22.0, 26.0),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: currentColor,
                // Font size Responsive
                fontSize: context.resClamp(10, 9, 12),
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
                height: 1.50,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
