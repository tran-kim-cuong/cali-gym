import 'dart:async';

import 'package:flutter/material.dart';

mixin NotificationMixin<T extends StatefulWidget> on State<T> {
  String _message = "";
  bool _isError = false;
  bool _show = false;
  Timer? _timer;

  void showTopNotification(String message, {bool isError = false}) {
    if (!mounted) return;
    setState(() {
      _message = message;
      _isError = isError;
      _show = true;
    });

    _timer?.cancel();
    _timer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _show = false);
    });
  }

  // Widget để bạn chèn vào Stack
  Widget buildNotificationWidget() {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      top: _show ? 60 : -100,
      left: 20,
      right: 20,
      child: Material( // Cần Material để tránh lỗi render text
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                _isError ? Icons.error_outline : Icons.check_circle_outline,
                color: _isError ? Colors.red : Colors.green,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(_message, style: const TextStyle(color: Colors.white, fontSize: 13)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}