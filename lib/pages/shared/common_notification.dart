import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:californiaflutter/helpers/size_utils.dart';

class CommonNotification {
  static void show(
    // ignore: avoid_unused_parameters
    BuildContext context, {
    required String message,
    bool isError = false,
    Duration duration = const Duration(seconds: 3),
  }) {
    BotToast.showCustomText(
      toastBuilder: (_) =>
          _NotificationToast(message: message, isError: isError),
      align: const Alignment(0, -0.85),
      duration: duration,
    );
  }
}

class _NotificationToast extends StatelessWidget {
  final String message;
  final bool isError;

  const _NotificationToast({required this.message, required this.isError});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.resW(335),
      padding: const EdgeInsets.all(8),
      decoration: ShapeDecoration(
        color: const Color(0xFF3E3E3E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        shadows: const [
          BoxShadow(
            color: Color(0x28A8ACB4),
            blurRadius: 12,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isError ? Icons.error : Icons.check_circle,
            color: isError ? const Color(0xFFD92229) : const Color(0xFF2DC26D),
            size: 24,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              message,
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
    );
  }
}
