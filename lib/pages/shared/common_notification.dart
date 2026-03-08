import 'dart:async';
import 'package:flutter/material.dart';
import 'package:californiaflutter/helpers/size_utils.dart';

class CommonNotification {
  static OverlayEntry? _overlayEntry;

  static void show(
    BuildContext context, {
    required String message,
    bool isError = false,
    Duration duration = const Duration(seconds: 3),
  }) {
    // Nếu đang có một thông báo cũ, xóa ngay để hiện cái mới
    _overlayEntry?.remove();
    _overlayEntry = null;

    _overlayEntry = OverlayEntry(
      builder: (context) => _NotificationWidget(
        message: message,
        isError: isError,
        displayDuration: duration,
        onRemove: () {
          _overlayEntry?.remove();
          _overlayEntry = null;
        },
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }
}

class _NotificationWidget extends StatefulWidget {
  final String message;
  final bool isError;
  final Duration displayDuration;
  final VoidCallback onRemove;

  const _NotificationWidget({
    required this.message,
    required this.isError,
    required this.displayDuration,
    required this.onRemove,
  });

  @override
  State<_NotificationWidget> createState() => _NotificationWidgetState();
}

class _NotificationWidgetState extends State<_NotificationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    // 1. Khởi tạo controller với thời gian hiệu ứng là 500ms
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    // BƯỚC 1: SÁNG LÊN (Fade In)
    _controller.forward();

    // BƯỚC 2: CHỜ THEO DURATION RỒI MỜ DẦN
    Future.delayed(widget.displayDuration, () {
      if (mounted) {
        // BƯỚC 3: MỜ DẦN (Fade Out)
        _controller.reverse().then((_) {
          // BƯỚC 4: BIẾN MẤT (Xóa khỏi Overlay)
          widget.onRemove();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double topPadding = MediaQuery.of(context).padding.top;

    return Positioned(
      top: topPadding + 10,
      left: 20,
      right: 20,
      child: FadeTransition(
        opacity: _fadeAnimation, // Gắn hiệu ứng mờ vào đây
        child: Material(
          color: Colors.transparent,
          child: GestureDetector(
            onTap: () {
              // Nếu người dùng click, cho mờ dần rồi xóa ngay
              _controller.reverse().then((_) => widget.onRemove());
            },
            child: Container(
              width: context.resW(335),
              padding: const EdgeInsets.all(8),
              decoration: ShapeDecoration(
                color: const Color(0xFF3E3E3E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                shadows: const [
                  BoxShadow(
                    color: Color(0x28A8ACB4),
                    blurRadius: 12,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    widget.isError ? Icons.error : Icons.check_circle,
                    color: widget.isError
                        ? const Color(0xFFD92229)
                        : const Color(0xFF2DC26D),
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.message,
                      style: TextStyle(
                        color: Colors.white,
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
      ),
    );
  }
}
