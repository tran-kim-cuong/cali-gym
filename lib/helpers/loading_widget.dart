import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  static const double _indicatorSize = 36;
  static const double _logoSize = 34;

  final Widget? child; // Chuyển thành tùy chọn (nullable)
  final bool isLoading; // Mặc định là true

  const LoadingWidget({
    super.key,
    this.child, // Bỏ required
    this.isLoading = true, // Gán giá trị mặc định
  });

  @override
  Widget build(BuildContext context) {
    // Khối UI nội dung Loading (Vòng quay + Logo)
    Widget loadingContent = Container(
      color: Colors.black.withValues(alpha: 0.5), // Lớp phủ mờ toàn màn hình
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 1. Vòng quay loading (Tự thích ứng nền tảng)
            SizedBox(
              width: _indicatorSize,
              height: _indicatorSize,
              child: _buildIndicator(),
            ),
            // 2. Logo bo tròn nằm chính giữa (Bỏ khung nền bao quanh)
            ClipOval(
              child: Image.asset(
                'assets/images/new_logo.png', // Đảm bảo đúng đường dẫn ảnh
                width: _logoSize,
                height: _logoSize,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
      ),
    );

    // KIỂM TRA: Nếu không có child (dùng qua Manager) thì hiện thẳng loadingContent
    if (child == null) return loadingContent;

    // Nếu có child (dùng làm wrapper) thì dùng Stack
    return Material(
      child: Stack(children: [child!, if (isLoading) loadingContent]),
    );
  }

  Widget _buildIndicator() {
    return const CircularProgressIndicator(
      strokeWidth: 3,
      backgroundColor: Colors.white24,
      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFDA212D)),
    );
  }
}
