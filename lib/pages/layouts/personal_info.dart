import 'package:californiaflutter/bases/app_session.dart';
import 'package:californiaflutter/helpers/size_utils.dart';
import 'package:californiaflutter/pages/shared/common_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PersonalInfoScreen extends StatelessWidget {
  const PersonalInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = AppSession();

    return Scaffold(
      backgroundColor: const Color(0xFF151515),
      body: Stack(
        children: [
          // 1. BACKGROUND LAYER
          CommonBackgroundWidget.buildBackgroundImage(
            context,
            dotenv.get('IMAGES_BG_HOME_V3_LAYER'),
          ),

          // 2. CONTENT LAYER
          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── HEADER ──────────────────────────────────────────────
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.resW(8),
                    vertical: context.resH(8),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: context.resW(20),
                        ),
                      ),
                      Text(
                        'Thông tin cá nhân',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: context.resClamp(20, 18, 24),
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Mulish',
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: context.resH(8)),

                // ── INFO ROWS ────────────────────────────────────────────
                _buildInfoRow(
                  context,
                  label: 'Mã hội viên',
                  value: session.clientId.isNotEmpty ? session.clientId : '-',
                ),
                _buildInfoRow(
                  context,
                  label: 'Họ và tên',
                  value: session.member?.firstName?.isNotEmpty == true
                      ? session.member!.firstName!
                      : '-',
                ),
                _buildInfoRow(
                  context,
                  label: 'Số điện thoại',
                  value: session.phoneNumber.isNotEmpty
                      ? session.phoneNumber
                      : '-',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required String label,
    required String value,
  }) {
    return GestureDetector(
      onLongPress: () {
        Clipboard.setData(ClipboardData(text: value));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã sao chép: $value'),
            backgroundColor: const Color(0xFF3E3E3E),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: context.resW(20),
              vertical: context.resH(18),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: context.resClamp(15, 13, 17),
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Flexible(
                  child: Text(
                    value,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: context.resClamp(15, 13, 17),
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
