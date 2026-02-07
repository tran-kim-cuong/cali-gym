import 'package:californiaflutter/helpers/loading_widget.dart';
import 'package:flutter/material.dart';

class LoadingManager {
  // Singleton pattern
  static final LoadingManager _instance = LoadingManager._internal();
  factory LoadingManager() => _instance;
  LoadingManager._internal();

  OverlayEntry? _overlayEntry;

  // Hàm hiển thị Loading
  void show(BuildContext context) {
    // Nếu đang hiện rồi thì không hiện thêm nữa
    if (_overlayEntry != null) return;

    _overlayEntry = OverlayEntry(builder: (context) => const LoadingWidget());

    // Chèn vào Overlay của app
    Overlay.of(context).insert(_overlayEntry!);
  }

  // Hàm ẩn Loading
  void hide() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
  }
}
