import 'dart:async';
import 'package:flutter/material.dart';
import 'package:californiaflutter/helpers/size_utils.dart';

class CommonNotification {
  static OverlayEntry? _overlayEntry;
  static Timer? _timer;

  static void show(
    BuildContext context, {
    required String message,
    bool isError = false,
    Duration duration = const Duration(seconds: 3),
  }) {
    _timer?.cancel();
    _overlayEntry?.remove();
    _overlayEntry = null;

    _overlayEntry = OverlayEntry(
      builder: (context) => _NotificationWidget(
        message: message,
        isError: isError,
        onDismiss: () {
          _overlayEntry?.remove();
          _overlayEntry = null;
        },
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);

    _timer = Timer(duration, () {
      _overlayEntry?.remove();
      _overlayEntry = null;
    });
  }
}

class _NotificationWidget extends StatelessWidget {
  final String message;
  final bool isError;
  final VoidCallback onDismiss;

  const _NotificationWidget({
    required this.message,
    required this.isError,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final double topPadding = MediaQuery.of(context).padding.top;

    return Positioned(
      top: topPadding + 10,
      left: 20,
      right: 20,
      child: Material(
        color: Colors.transparent,
        child: GestureDetector(
          onTap: onDismiss,
          child: Container(
            // 1. KÍCH THƯỚC VÀ PADDING THEO SNIPPET
            width: context.resW(335),
            padding: const EdgeInsets.all(8),
            decoration: ShapeDecoration(
              // 2. MÀU NỀN XÁM ĐẬM (0xFF3E3E3E)
              color: const Color(0xFF3E3E3E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              // 3. ĐỔ BÓNG THEO MÃ MÀU 0x28A8ACB4
              shadows: const [
                BoxShadow(
                  color: Color(0x28A8ACB4),
                  blurRadius: 12,
                  offset: Offset(0, 1),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 4. ICON CÙNG MÀU VỚI LOẠI THÔNG BÁO
                Icon(
                  isError ? Icons.error : Icons.check_circle,
                  // Dùng màu đỏ cho lỗi, xanh dương cho thành công để phân biệt trên nền xám
                  color: isError
                      ? const Color(0xFFD92229)
                      : const Color(0xFF2DC26D),
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    message,
                    style: TextStyle(
                      color: Colors.white,
                      // 5. FONT SIZE 12 VÀ CHIỀU CAO DÒNG 1.5
                      fontSize: context.resClamp(12, 11, 13),
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                      height: 1.50,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
