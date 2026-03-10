import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:californiaflutter/helpers/size_utils.dart';
// import 'package:flutter_svg/svg.dart';

class CommonBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CommonBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  // final Color _activeColor = const Color(0xFFE1494F);
  // final Color _inactiveColor = const Color(0xFF9A9A9A);

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
        color: Color(0xFF1A1A1A),
        border: Border(top: BorderSide(color: Colors.white10, width: 0.5)),
      ),
      padding: EdgeInsets.only(bottom: customBottomPadding), // Đẩy nội dung lên
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _navItem(
            context,
            'assets/images/vuesax/v5/home.png',
            'navbar.btn_home'.tr(),
            0,
          ),
          _navItem(
            context,
            'assets/images/vuesax/v5/teacher.png',
            "navbar.btn_class".tr(),
            1,
          ),
          // _navItem(
          //   context,
          //   'assets/images/vuesax/v5/ticket-discount.png',
          //   "navbar.btn_loyalty".tr(),
          //   2,
          //   isEnabled: false,
          // ),
          _navItem(
            context,
            'assets/images/vuesax/v5/profile-circle.png',
            "navbar.btn_profile".tr(),
            2,
            isEnabled: true,
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
    // final Color currentColor = isSelected ? _activeColor : _inactiveColor;

    return Expanded(
      child: InkWell(
        onTap: isEnabled ? () => onTap(index) : null,
        child: Stack(
          // Sử dụng Stack để chồng các đường kẻ Gradient lên trên
          children: [
            // 1. NỀN VÀ NỘI DUNG CHÍNH
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: double.infinity,
              height: double.infinity,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withValues(alpha: 0.04),
                          Colors.transparent,
                          Colors.white.withValues(alpha: 0.04),
                        ],
                      )
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    svgPath,
                    width: context.resW(24),
                    height: context.resW(24),
                  ),
                  // SvgPicture.asset(
                  //   isSelected
                  //       ? svgPath.replaceAll('.svg', '-bold.svg')
                  //       : svgPath,
                  //   colorFilter: ColorFilter.mode(
                  //     currentColor,
                  //     BlendMode.srcIn,
                  //   ),
                  //   width: context.resW(24),
                  //   height: context.resW(24),
                  // ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: context.resClamp(11, 10, 12),
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // 2. ĐƯỜNG KẺ GRADIENT TRÊN VÀ DƯỚI (CHỈ HIỂN THỊ KHI ĐƯỢC CHỌN)
            if (isSelected) ...[
              // ĐƯỜNG KẺ TRÊN
              Positioned(
                top:
                    1, // Đẩy xuống 1px để không bị cắt mất phần bóng đổ phía trên
                left: 0,
                right: 0,
                child: Center(
                  child: SizedBox(
                    width: context.resW(
                      55,
                    ), // Tăng nhẹ chiều rộng để dải mờ trông trải dài hơn
                    height: 1.5, // Làm đường kẻ mảnh lại để thanh lịch hơn
                    child: _buildGradientLine(),
                  ),
                ),
              ),
              // ĐƯỜNG KẺ DƯỚI
              Positioned(
                bottom: 1, // Đẩy lên 1px
                left: 0,
                right: 0,
                child: Center(
                  child: SizedBox(
                    width: context.resW(55),
                    height: 1.5,
                    child: _buildGradientLine(),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Hàm bổ trợ để tạo đường kẻ với mã màu Gradient bạn cung cấp
  Widget _buildGradientLine() {
    return Container(
      decoration: BoxDecoration(
        // 1. TẠO ĐỘ MỜ (GLOW) BẰNG BOXSHADOW
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF4D4D).withValues(alpha: 0.5),
            blurRadius: 8, // Độ nhòe càng cao thì đường kẻ càng mờ
            spreadRadius: 1,
            offset: const Offset(0, 0),
          ),
        ],
        // 2. GRADIENT VỚI ĐẦU TRONG SUỐT ĐỂ HÒA VÀO NỀN
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.transparent, // Mờ dần ra hai bên
            Color(0xA8A92828), // Đỏ nhạt
            Color(0xFFFF4D4D), // Đỏ rực ở tâm
            Color(0xFFFF4C4C), // Đỏ rực ở tâm
            Color(0xA8A92828), // Đỏ nhạt
            Colors.transparent, // Mờ dần ra hai bên
          ],
        ),
      ),
    );
  }
}
