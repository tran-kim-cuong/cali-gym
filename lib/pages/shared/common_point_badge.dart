import 'package:flutter/material.dart';

class CommonPointBadge extends StatelessWidget {
  final double size;
  final double fontSize;

  const CommonPointBadge({
    super.key,
    this.size = 16.0, // Kích thước vòng tròn mặc định
    this.fontSize = 8.0, // Kích thước chữ mặc định
  });

  // Sử dụng màu đỏ thương hiệu thống nhất
  static const Color brandRed = Color(0xFFE04A50);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: const BoxDecoration(color: brandRed, shape: BoxShape.circle),
      child: Text(
        "C",
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
