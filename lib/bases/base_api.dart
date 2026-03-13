import 'dart:convert';

import 'package:californiaflutter/helpers/session_manager.dart';
import 'package:californiaflutter/helpers/app_debug_logger.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class BaseApi {
  late Dio _dioMain; // Dùng cho API hệ thống (Cần Token)
  late Dio _dioSms; // Dùng cho API SMS (Không cần Token)
  late Dio _dioCrm;

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

    final String crmUser = dotenv.get('CRM_USER_NAME');
    final String crmPass = dotenv.get('CRM_PASSWORD');

    final String credentials = "$crmUser:$crmPass";
    final String base64Token = base64Encode(utf8.encode(credentials));
    final String basicAuth = 'Basic $base64Token';
    // 3. CRM API - Tích hợp mới
    _dioCrm = Dio(
      BaseOptions(
        baseUrl: dotenv.get('CRM_URI'), // URL từ curl của bạn
        connectTimeout: const Duration(seconds: 30),
        headers: {
          'accept': 'text/plain',
          // Token Basic Auth từ curl của bạn
          // 'authorization': basicAuth,
        },
      ),
    );

    // Thêm Interceptor cho Main API (Có gắn Token)
    _dioMain.interceptors.add(_createInterceptor(useToken: true));

    // Thêm Interceptor cho SMS API (KHÔNG gắn Token)
    _dioSms.interceptors.add(_createInterceptor(useToken: false));

    _dioCrm.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (!options.headers.containsKey('Authorization') &&
              !options.headers.containsKey('authorization')) {
            options.headers['Authorization'] = basicAuth;
          }
          AppDebugLogger.apiRequest(options, scope: 'CRM REQUEST');
          return handler.next(options);
        },
        onResponse: (r, h) {
          AppDebugLogger.apiResponse(r, scope: 'CRM RESPONSE');
          return h.next(r);
        },
        onError: (e, h) {
          AppDebugLogger.apiError(e, scope: 'CRM ERROR');
          return h.next(e);
        },
      ),
    );
  }

  Future<String?> _performReLogin() async {
    try {
      // Sử dụng một instance Dio mới hoàn toàn để tránh bị dính Interceptor cũ (gây lặp vô tận)
      final refreshDio = Dio(
        BaseOptions(baseUrl: dotenv.env["CALIFORNIA_URI"] ?? ""),
      );

      final response = await refreshDio.post(
        '/api/login',
        data: {
          "email": dotenv.env["CALIFORNIA_USER_NAME"],
          "password": dotenv.env["CALIFORNIA_PASSWORD"],
        },
      );

      if (response.statusCode == 200) {
        String newToken = response.data['token'];
        // Cập nhật token mới vào Session
        await SessionManager.setLoggedIn(true, newToken);
        return newToken;
      }
    } catch (e) {
      AppDebugLogger.log('⚡ [AUTH] Lỗi khi tự động Login lại', data: e);
    }
    return null;
  }

  Interceptor _createInterceptor({required bool useToken}) {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        if (useToken) {
          String? token = await SessionManager.getToken();
          if (token != null) {
            options.headers["Authorization"] = "Bearer $token";
            options.headers["Content-Type"] = "application/json";
          }
        }

        AppDebugLogger.apiRequest(options);

        return handler.next(options);
      },
      onResponse: (r, h) {
        AppDebugLogger.apiResponse(r);
        return h.next(r);
      },
      onError: (e, h) async {
        AppDebugLogger.apiError(e);

        if (useToken && e.response?.statusCode == 401) {
          AppDebugLogger.log('⚡ [AUTH] Token expired. Re-logging in...');
          String? newToken = await _performReLogin();

          if (newToken != null) {
            e.requestOptions.headers["Authorization"] = "Bearer $newToken";
            final retryResponse = await _dioMain.fetch(e.requestOptions);
            return h.resolve(retryResponse);
          }
        }

        return h.next(e);
      },
    );
  }

  // Trả về instance riêng biệt, không còn ghi đè baseUrl của nhau
  Dio get client => _dioMain;
  Dio get smsClient => _dioSms;
  Dio get crmClient => _dioCrm;
}
