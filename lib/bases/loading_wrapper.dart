import 'package:californiaflutter/helpers/loading_manager.dart';
import 'package:flutter/material.dart';

mixin LoadingWrapper {
  Future<T?> handleApi<T>(BuildContext context, Future<T> task) async {
    LoadingManager().show(context);
    try {
      return await task;
    } finally {
      LoadingManager().hide();
    }
  }
}
