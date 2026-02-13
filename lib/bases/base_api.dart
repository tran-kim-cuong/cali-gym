import 'package:californiaflutter/helpers/loading_manager.dart';
import 'package:californiaflutter/helpers/session_manager.dart';
import 'package:californiaflutter/main.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class BaseApi {
  late Dio _dioMain; // Dùng cho API hệ thống (Cần Token)
  late Dio _dioSms; // Dùng cho API SMS (Không cần Token)

  static final BaseApi _instance = BaseApi._internal();
  factory BaseApi() => _instance;

  BaseApi._internal() {
    // 1. Instance cho California API
    _dioMain = Dio(
      BaseOptions(
        baseUrl: dotenv.env["CALIFORNIA_URI"] ?? "",
        connectTimeout: const Duration(seconds: 30),
      ),
    );

    // 2. Instance cho SMS API
    _dioSms = Dio(
      BaseOptions(
        baseUrl: dotenv.env["SMS_URI"] ?? "",
        connectTimeout: const Duration(seconds: 30),
      ),
    );

    // Thêm Interceptor cho Main API (Có gắn Token)
    _dioMain.interceptors.add(_createInterceptor(useToken: true));

    // Thêm Interceptor cho SMS API (KHÔNG gắn Token)
    _dioSms.interceptors.add(_createInterceptor(useToken: false));
  }

  Interceptor _createInterceptor({required bool useToken}) {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        if (useToken) {
          String? token = await SessionManager.getToken();
          if (token != null) options.headers["Authorization"] = "Bearer $token";
        }

        // FIX LỖI OVERLAY: Kiểm tra Overlay trước khi hiện Loading
        final context = navigatorKey.currentContext; //
        if (context != null && context.mounted) {
          // Kiểm tra xem context có Overlay không để tránh lỗi '_overlay != null'
          if (Overlay.maybeOf(context) != null) {
            LoadingManager().show(context); //
          }
        }
        return handler.next(options);
      },
      onResponse: (r, h) {
        LoadingManager().hide();
        return h.next(r);
      },
      onError: (e, h) {
        LoadingManager().hide();
        return h.next(e);
      },
    );
  }

  // Trả về instance riêng biệt, không còn ghi đè baseUrl của nhau
  Dio get client => _dioMain;
  Dio get smsClient => _dioSms;
}
