import 'package:flutter/material.dart';

extension ResponsiveSize on BuildContext {
  // Lấy chiều rộng màn hình hiện tại
  double get screenWidth => MediaQuery.of(this).size.width;

  // Hàm scale giá trị theo chiều rộng thiết kế chuẩn (375)
  // Cách dùng: context.res(14)
  double res(double value) => (value * screenWidth / 375);

  // Hàm scale kèm theo giới hạn (clamp) để an toàn hơn
  // Cách dùng: context.resClamp(14, 12, 18)
  double resClamp(double value, double min, double max) {
    return (value * screenWidth / 375).clamp(min, max);
  }
}
