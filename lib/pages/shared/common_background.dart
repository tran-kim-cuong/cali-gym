import 'package:flutter/material.dart';

class CommonBackgroundWidget {
  /// Hàm dựng hình nền mờ phủ toàn màn hình
  /// [assetPath]: Đường dẫn đến file ảnh trong assets
  /// [opacity]: Độ mờ của ảnh (mặc định là 0.12 theo thiết kế)
  static Widget buildBackgroundImage(
    BuildContext context,
    String assetPath, {
    double opacity = 0.12,
  }) {
    return Positioned.fill(
      child: Align(
        alignment: Alignment.center, // Đảm bảo luôn nằm giữa màn hình
        child: Opacity(
          opacity: opacity,
          child: Image.asset(
            assetPath,
            // Lấy kích thước thực tế của màn hình thiết bị
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,

            // BoxFit.contain để thấy trọn vẹn hình thể nhân vật không bị cắt
            fit: BoxFit.contain,

            errorBuilder: (context, error, stackTrace) => const SizedBox(),
          ),
        ),
      ),
    );
  }
}
