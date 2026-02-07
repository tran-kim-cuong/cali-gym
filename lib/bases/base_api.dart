import 'package:dio/dio.dart';
import '../../main.dart'; // Import navigatorKey
import '../helpers/loading_manager.dart';

class BaseApi {
  late Dio _dio;

  // Singleton cho API
  static final BaseApi _instance = BaseApi._internal();
  factory BaseApi() => _instance;

  BaseApi._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: "https://your-api-url.com/api/",
        connectTimeout: const Duration(seconds: 30),
      ),
    );

    // Thêm Interceptor để tự động hiện/ẩn Loading
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Lấy context từ navigatorKey
          final context = navigatorKey.currentContext;
          if (context != null) {
            LoadingManager().show(context); // HIỆN LOADING
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          LoadingManager().hide(); // ẨN LOADING KHI THÀNH CÔNG
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          LoadingManager().hide(); // ẨN LOADING KHI LỖI
          // Có thể xử lý hiện dialog lỗi chung ở đây
          return handler.next(e);
        },
      ),
    );
  }

  // Hàm get public để dùng
  Dio get client => _dio;
}
