import 'package:californiaflutter/pages/layouts/home.dart';
import 'package:californiaflutter/pages/layouts/login.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'helpers/session_manager.dart';

void main() async {
  // Đảm bảo các dịch vụ hệ thống đã sẵn sàng
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Khởi tạo Localization
  await EasyLocalization.ensureInitialized();

  // Kiểm tra trạng thái đăng nhập
  bool loggedIn = await SessionManager.isLoggedIn();

  runApp(
    // 3. Bọc App bằng EasyLocalization
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('vi')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      startLocale: const Locale('vi'),
      child: MyApp(isLoggedIn: loggedIn),
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
      debugShowCheckedModeBanner: false, // Tắt banner debug góc phải
      // 4. Cấu hình đa ngôn ngữ cho MaterialApp
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,

      title: 'California Fitness', // Tên App
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),

      // Nếu isLoggedIn là true thì vào thẳng Home, ngược lại hiện Login
      home: isLoggedIn ? const HomeScreen() : const LoginScreen(),
    );
  }
}
