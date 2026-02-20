import 'dart:math';
import 'package:flutter/material.dart';

extension ResponsiveSize on BuildContext {
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;

  // 1. Scale dựa trên chiều rộng (Dùng cho padding ngang, width)
  double resW(double value) => (value * screenWidth / 375);

  // 2. Scale dựa trên chiều cao (Dùng cho SizedBox, padding dọc)
  double resH(double value) => (value * screenHeight / 812);

  // 3. Scale an toàn nhất (Dùng cho Font chữ)
  // Lấy tỉ lệ scale nhỏ hơn để tránh tràn khi xoay ngang màn hình
  double res(double value) {
    double scaleW = screenWidth / 375;
    double scaleH = screenHeight / 812;
    return value * min(scaleW, scaleH);
  }

  // 4. Hàm Clamp an toàn
  double resClamp(double value, double minVal, double maxVal) {
    return res(value).clamp(minVal, maxVal);
  }
}
