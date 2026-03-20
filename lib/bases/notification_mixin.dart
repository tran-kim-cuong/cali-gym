import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';

mixin NotificationMixin<T extends StatefulWidget> on State<T> {
  void showTopNotification(String message, {bool isError = false}) {
    BotToast.showCustomText(
      toastBuilder: (_) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: isError ? Colors.red : Colors.green,
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
      align: const Alignment(0, -0.85),
      duration: const Duration(seconds: 3),
    );
  }

  /// No longer needed; kept for backward compatibility with existing Stack layouts.
  Widget buildNotificationWidget() => const SizedBox.shrink();
}
