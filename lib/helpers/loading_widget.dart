import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Màu chủ đạo của App (Lấy màu đỏ California hoặc Trắng)
    // const Color loadingColor = Color(0xFFDA212D); // Màu đỏ brand
    // const Color loadingColor = Colors.white; // Hoặc dùng màu trắng nếu thích

    return Material(
      // Nền đen mờ 50% để chặn thao tác click bên dưới
      color: Colors.black.withValues(alpha: 0.5),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E), // Hộp nền nhỏ màu xám đậm
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Vòng tròn xoay
              // Dùng Platform check để hiện đúng kiểu Android hoặc iOS
              SizedBox(width: 32, height: 32, child: _buildIndicator()),

              // 2. Dòng chữ Loading (Tùy chọn, có thể xóa nếu muốn chỉ có vòng tròn)
              const SizedBox(height: 16),
              const Text(
                "Vui lòng chờ...",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.none, // Bỏ gạch chân xấu xí
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Hàm kiểm tra platform an toàn cho Web
  Widget _buildIndicator() {
    // Nếu là Web, mặc định dùng CircularProgressIndicator hoặc check targetPlatform
    if (kIsWeb) {
      return const CircularProgressIndicator(
        strokeWidth: 3,
        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFDA212D)),
      );
    }

    // Nếu là Mobile, mới được phép check TargetPlatform
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return const CupertinoActivityIndicator(radius: 14, color: Colors.white);
    }

    return const CircularProgressIndicator(
      strokeWidth: 3,
      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFDA212D)),
    );
  }
}
