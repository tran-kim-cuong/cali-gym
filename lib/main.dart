// import 'package:californiaflutter/pages/layouts/home.dart';
import 'package:californiaflutter/bases/app_session.dart';
import 'package:californiaflutter/pages/layouts/welcome.dart';
import 'package:californiaflutter/pages/master.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// 1. Khai báo Global Key ở ngoài cùng
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  // Đảm bảo các dịch vụ hệ thống đã sẵn sàng
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Khởi tạo Localization
  // GOM CHUNG CÁC TÁC VỤ CHỜ LOADING TẠI ĐÂY
  await Future.wait([
    EasyLocalization.ensureInitialized(), // Khởi tạo đa ngôn ngữ
    dotenv.load(fileName: ".env"), // Load cấu hình môi trường
    AppSession().load(), // Nạp dữ liệu phiên đăng nhập vào RAM
  ]);

  runApp(
    // 3. Bọc App bằng EasyLocalization
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('vi')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      startLocale: const Locale('vi'),
      child: MyApp(isLoggedIn: AppSession().isLoggedIn),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey, // 2. Gán Key vào MaterialApp

      debugShowCheckedModeBanner: false, // Tắt banner debug góc phải
      // 4. Cấu hình đa ngôn ngữ cho MaterialApp
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,

      title: 'California Fitness', // Tên App
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        fontFamily: 'Inter', // Font mặc định cho toàn bộ text trong app
      ),

      // Nếu isLoggedIn là true thì vào thẳng Home, ngược lại hiện Login
      home: isLoggedIn == true ? const MasterScreen() : const WelcomeScreen(),
    );
  }
}
