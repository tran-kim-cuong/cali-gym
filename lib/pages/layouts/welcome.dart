import 'package:californiaflutter/helpers/size_utils.dart';
import 'package:californiaflutter/pages/layouts/login.dart';
import 'package:californiaflutter/pages/shared/common_background.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Lấy padding đáy của hệ thống (Home Indicator)
    final double bottomPadding = MediaQuery.of(context).padding.bottom;

    final _ = context.locale;

    return Scaffold(
      backgroundColor: const Color(0xFF151515),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            // Đảm bảo không bị vỡ khi font chữ to hoặc màn hình cực ngắn
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    // 1. PHẦN TRÊN: HÌNH ẢNH (Responsive Image)
                    Expanded(
                      flex: 6,
                      child: Stack(
                        children: [
                          CommonBackgroundWidget.buildBackgroundImage(
                            context,
                            dotenv.get('IMAGES_BG_V3_LAYER'),
                          ),
                          Positioned.fill(
                            child: Container(
                              color: Colors.black.withValues(alpha: 0.2),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 2. PHẦN DƯỚI: NỘI DUNG
                    Expanded(
                      flex: 4,
                      child: Container(
                        width: double.infinity,
                        color: const Color(0xFF151515),
                        padding: EdgeInsets.symmetric(
                          horizontal: context.res(24),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'welcome.lbl_title'.tr(),
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Oswald',
                                // Co giãn theo chiều rộng màn hình
                                fontSize: context.resClamp(52, 40, 65),
                                fontWeight: FontWeight.w700,
                                height: 1.1,
                              ),
                            ),
                            SizedBox(height: context.res(12)),
                            Text(
                              'welcome.lbl_sub_title'.tr(),
                              style: TextStyle(
                                color: const Color(0xFFC7C7C7),
                                fontFamily: 'Inter',
                                fontSize: context.resClamp(14, 12, 16),
                                fontWeight: FontWeight.w400,
                                height: 1.4,
                              ),
                            ),
                            SizedBox(height: context.res(32)),

                            // Nút Đăng nhập (Responsive Button)
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const LoginScreen(),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFDA2128),
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                    vertical: context.resClamp(16, 14, 20),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  elevation: 0,
                                ),
                                child: Text(
                                  'welcome.lbl_login_text'.tr(),
                                  style: TextStyle(
                                    fontSize: context.resClamp(16, 14, 18),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),

                            // Khoảng cách an toàn dưới cùng (Sát Home Indicator)
                            SizedBox(
                              height: bottomPadding > 0
                                  ? bottomPadding
                                  : context.res(20),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
