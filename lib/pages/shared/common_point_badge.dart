import 'package:californiaflutter/helpers/size_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';

class CommonPointBadge extends StatelessWidget {
  final String value;
  final String? svgPath; // Đường dẫn đến file icon .svg
  final bool showIcon;
  final bool useGradient; // THÊM: Điều khiển việc hiện nền vàng
  final bool hasBorder; // THÊM: Điều khiển việc vẽ khung ngoài (decoration)

  const CommonPointBadge({
    super.key,
    required this.value,
    this.svgPath,
    this.showIcon = true,
    this.useGradient = true, // Mặc định là có hiện
    this.hasBorder = true, // Mặc định là có vẽ khung
  });

  @override
  Widget build(BuildContext context) {
    // 1. Kiểm tra xem có phải là icon ranking hay không
    final bool isRankingIcon = svgPath?.contains('ranking.svg') ?? false;

    return Container(
      padding: hasBorder
          ? EdgeInsets.symmetric(
              horizontal: context.resW(8),
              vertical: context.resH(4),
            )
          : EdgeInsets.zero,
      decoration: hasBorder
          ? ShapeDecoration(
              color: Colors.transparent,
              shape: RoundedRectangleBorder(
                side: const BorderSide(width: 1, color: Color(0xFFEF4822)),
                borderRadius: BorderRadius.circular(4),
              ),
            )
          : null, // TÙY BIẾN: Nếu false thì không vẽ bất cứ thứ gì (border/color),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // TRƯỜNG HỢP: Icon bên trái (Nếu KHÔNG PHẢI ranking.svg)
          if (showIcon && svgPath != null && !isRankingIcon) ...[
            _buildIconContainer(context, isRankingIcon),
            const SizedBox(width: 4),
          ],

          // PHẦN TEXT
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: context.resClamp(12, 10, 14),
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
              height: 1.50,
            ),
          ),

          // TRƯỜNG HỢP: Icon bên phải (Nếu LÀ ranking.svg)
          if (showIcon && svgPath != null && isRankingIcon) ...[
            const SizedBox(width: 4),
            _buildIconContainer(context, isRankingIcon),
          ],
        ],
      ),
    );
  }

  // Hàm build Icon linh hoạt theo điều kiện màu sắc
  Widget _buildIconContainer(BuildContext context, bool isRanking) {
    return Container(
      width: context.resW(16).clamp(14.0, 18.0),
      height: context.resW(16).clamp(14.0, 18.0),
      padding: useGradient ? const EdgeInsets.all(3) : EdgeInsets.zero,
      decoration: useGradient
          ? ShapeDecoration(
              gradient: const LinearGradient(
                begin: Alignment(0.62, 0.02),
                end: Alignment(0.20, 0.89),
                colors: [Colors.transparent, Colors.transparent],
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(35),
              ),
            )
          : null, // BỎ BORDER NẾU useGradient = false
      child: SvgPicture.asset(svgPath!),
    );
  }
}
