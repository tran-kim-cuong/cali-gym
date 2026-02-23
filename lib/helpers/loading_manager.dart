import 'package:californiaflutter/helpers/loading_widget.dart';
import 'package:flutter/material.dart';

class LoadingManager {
  static final LoadingManager _instance = LoadingManager._internal();
  factory LoadingManager() => _instance;
  LoadingManager._internal();

  OverlayEntry? _overlayEntry;

  void show(BuildContext context) {
    if (_overlayEntry != null) return;

    // Đã có thể gọi mà không cần tham số nhờ thay đổi ở bước 1
    _overlayEntry = OverlayEntry(builder: (context) => const LoadingWidget());

    Overlay.of(context).insert(_overlayEntry!);
  }

  void hide() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
  }
}
