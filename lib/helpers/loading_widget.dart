import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class LoadingWidget extends StatelessWidget {
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
            SizedBox(width: 70, height: 70, child: _buildIndicator()),
            // 2. Logo bo tròn nằm chính giữa (Bỏ khung nền bao quanh)
            ClipOval(
              child: Image.asset(
                'assets/images/new_logo.png', // Đảm bảo đúng đường dẫn ảnh
                width: 35,
                height: 35,
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
    if (kIsWeb) {
      return const CircularProgressIndicator(
        strokeWidth: 3,
        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFDA212D)),
      );
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return const CupertinoActivityIndicator(radius: 15, color: Colors.white);
    }
    return const CircularProgressIndicator(
      strokeWidth: 3,
      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFDA212D)),
    );
  }
}
