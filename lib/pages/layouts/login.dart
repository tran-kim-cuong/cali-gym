import 'dart:ui';
import 'package:californiaflutter/bases/app_session.dart';
import 'package:californiaflutter/bases/base_api.dart';
import 'package:californiaflutter/bases/loading_wrapper.dart';
import 'package:californiaflutter/helpers/loading_manager.dart';
import 'package:californiaflutter/bases/notification_mixin.dart';
import 'package:californiaflutter/helpers/session_manager.dart';
import 'package:californiaflutter/pages/shared/common_background.dart';
import 'package:californiaflutter/pages/shared/language_bottom_sheet.dart';
import 'package:californiaflutter/pages/layouts/otp.dart';
import 'package:californiaflutter/services/api_service.dart';
import 'package:dio/dio.dart' as dio_form;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:californiaflutter/helpers/size_utils.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with LoadingWrapper, NotificationMixin {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _clientIdController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final FocusNode _clientIdFocusNode = FocusNode();
  bool _isAgreed = false;
  bool _isPhoneValid = false;

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_onPhoneChanged);
  }

  @override
  void dispose() {
    _phoneController.removeListener(_onPhoneChanged);
    _phoneController.dispose();
    _clientIdController.dispose();
    _focusNode.dispose();
    _clientIdFocusNode.dispose();
    super.dispose();
  }

  void _onPhoneChanged() {
    setState(() {
      _isPhoneValid = _phoneController.text.length >= 10;
    });
    // Tự động ẩn phím khi đủ số và đã đồng ý
    if (_phoneController.text.length == 10 && _isAgreed) {
      _focusNode.unfocus();
    }
  }

  bool _canEnableButton() => _isAgreed && _isPhoneValid;

  Future<void> _handleLogin(String method) async {
    String phoneNumber = _phoneController.text;
    if (phoneNumber.isEmpty || phoneNumber.length < 10) {
      showTopNotification("login.error_invalid_phone".tr(), isError: true);
      return;
    }

    if (!_isAgreed) {
      showTopNotification("login.error_agreement".tr(), isError: true);
      return;
    }

    String otpCode = gen4Digits().toString();
    dio_form.FormData formData = dio_form.FormData.fromMap({
      "api_key": dotenv.env["SMS_API_KEY"],
      "message": "${dotenv.env["SMS_MESSAGE"]} $otpCode",
      "phone_number": phoneNumber,
      "brand_name": dotenv.env["SMS_BRAND_NAME"],
      "sender": dotenv.env["SMS_SENDER"],
    });

    final String clientId = _clientIdController.text.trim();
    if (clientId.isNotEmpty) {
      LoadingManager().show(context);
      try {
        final loginResponse = await BaseApi().client.post(
          '/api/login',
          data: {
            "email": dotenv.env["CALIFORNIA_USER_NAME"],
            "password": dotenv.env["CALIFORNIA_PASSWORD"],
          },
        );
        if (loginResponse.statusCode != 200) {
          showTopNotification(
            "login.error_client_verify_failed".tr(),
            isError: true,
          );
          return;
        }
        final String token = loginResponse.data['token'];
        await getMember(token, clientId, phoneNumber);
      } catch (e) {
        final msg = e.toString().replaceFirst('Exception: ', '');
        showTopNotification(
          msg.isNotEmpty ? msg : "login.error_member_not_found".tr(),
          isError: true,
        );
        return;
      } finally {
        LoadingManager().hide();
      }
    }

    if (method == 'SMS') {
      try {
        final response = await handleApi(
          context,
          BaseApi().smsClient.post('/api/sms/send', data: formData),
        );

        if (response?.statusCode == 200) {
          SessionManager.otp = otpCode;

          AppSession().phoneNumber = phoneNumber;
          await SessionManager.setPhoneNumber(phoneNumber);

          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OtpScreen(
                  phoneNumber: phoneNumber,
                  clientId: _clientIdController.text.trim(),
                ),
              ),
            );
          }
        }
      } catch (e) {
        showTopNotification("login.error_sms_failed".tr(), isError: true);
      }
    } else if (method == 'Zalo') {
      showTopNotification("login.feature_developing".tr());
    }
  }

  @override
  Widget build(BuildContext context) {
    // final double screenHeight = MediaQuery.of(context).size.height;
    final double bottomPadding = MediaQuery.of(context).padding.bottom;
    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final bool isKeyboardOpen = keyboardHeight > 0;

    debugPrint('$bottomPadding');

    return Scaffold(
      backgroundColor: const Color(0xFF151515),
      // Quan trọng: Để hệ thống tự động đẩy nội dung khi có bàn phím
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // 1. Background Image (Cố định phía sau)
          CommonBackgroundWidget.buildBackgroundImage(
            context,
            dotenv.get('IMAGES_BG_LOGIN_V3_LAYER'),
          ),

          // 2. Blur Overlay khi bật bàn phím
          if (isKeyboardOpen)
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(color: Colors.black.withValues(alpha: 0.3)),
              ),
            ),

          // 3. Nội dung chính
          GestureDetector(
            /// Quang Huy: Thêm GestureDetector để ẩn bàn phím khi bấm ra ngoài
            onTap: () =>
                _focusNode.unfocus(), // Quang Huy: Bấm ra ngoài để ẩn bàn phím
            child: SafeArea(
              bottom: false,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        // Đảm bảo Column ít nhất bằng chiều cao màn hình để Spacer hoạt động
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: Column(
                          children: [
                            // Nút chuyển ngôn ngữ
                            Align(
                              alignment: Alignment.topRight,
                              child: Padding(
                                padding: EdgeInsets.all(context.resW(16)),
                                child: _buildLanguageSelector(),
                              ),
                            ),

                            // NẾU KHÔNG CÓ BÀN PHÍM, ĐẨY TOÀN BỘ XUỐNG DƯỚI
                            if (!isKeyboardOpen) const Spacer(),

                            // Khoảng cách nhỏ khi bật bàn phím để không dính sát logo
                            if (isKeyboardOpen)
                              SizedBox(height: context.resH(20)),

                            // KHU VỰC FORM NHẬP LIỆU
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.only(
                                left: context.resW(24),
                                right: context.resW(24),
                                top: context.resH(30),
                                // CHỈ CHỪA KHOẢNG TRỐNG CHO HOME INDICATOR, KHÔNG THÊM GÌ KHÁC
                                bottom: bottomPadding > 0
                                    ? bottomPadding
                                    : context.resH(20),
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF151515),
                                borderRadius: isKeyboardOpen
                                    ? const BorderRadius.vertical(
                                        top: Radius.circular(24),
                                      )
                                    : BorderRadius.zero,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize
                                    .min, // Bo sát nội dung bên trong
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'login.phone_input_title'.tr(),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: context.resClamp(18, 16, 22),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: context.resH(20)),
                                  _buildPhoneTextField(),
                                  SizedBox(height: context.resH(12)),
                                  _buildClientIdTextField(),
                                  SizedBox(height: context.resH(16)),
                                  _buildAgreementText(),
                                  SizedBox(height: context.resH(30)),
                                  _buildActionButtons(),
                                  // ĐÃ LOẠI BỎ SIZEDBOX THỪA TẠI ĐÂY
                                  // Xử lý sát Home Indicator hoặc sát mép
                                  SizedBox(
                                    height: bottomPadding > 0
                                        ? bottomPadding
                                        : context.resH(20),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // 4. Lớp thông báo
          buildNotificationWidget(),
        ],
      ),
    );
  }

  Widget _buildLanguageSelector() {
    final String currentCode = context.locale.languageCode;
    return GestureDetector(
      onTap: () => LanguageBottomSheet.show(context: context),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: context.resW(10),
          vertical: context.resH(6),
        ),
        decoration: BoxDecoration(
          color: Colors.black45,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: context.resW(20),
              height: context.resW(20),
              child: SvgPicture.asset(
                currentCode == 'vi'
                    ? 'assets/images/vietnam.svg'
                    : 'assets/images/kingdom.svg',
              ),
            ),
            SizedBox(width: context.resW(8)),
            Text(
              currentCode == 'vi' ? 'Tiếng Việt' : 'English',
              style: TextStyle(
                color: Colors.white,
                fontSize: context.resClamp(12, 11, 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneTextField() {
    return TextField(
      controller: _phoneController,
      focusNode: _focusNode,
      keyboardType: TextInputType.number, // iPad ổn định hơn với number
      maxLength: 10,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        counterText: "",
        hintText: 'login.phone_hint'.tr(),
        hintStyle: const TextStyle(color: Color(0xFF6B6B6B)),
        prefixIcon: const Icon(Icons.smartphone, color: Color(0xFFC7C7C7)),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF333333)),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFFDA212D)),
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        contentPadding: EdgeInsets.symmetric(vertical: context.resH(16)),
      ),
    );
  }

  Widget _buildClientIdTextField() {
    return TextField(
      controller: _clientIdController,
      focusNode: _clientIdFocusNode,
      keyboardType: TextInputType.text,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: 'login.client_id_hint'.tr(),
        hintStyle: const TextStyle(color: Color(0xFF6B6B6B)),
        prefixIcon: const Icon(Icons.badge_outlined, color: Color(0xFFC7C7C7)),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF333333)),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFFDA212D)),
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        contentPadding: EdgeInsets.symmetric(vertical: context.resH(16)),
      ),
    );
  }

  Widget _buildAgreementText() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: context.resW(24),
          height: context.resW(24),
          child: Checkbox(
            value: _isAgreed,
            activeColor: const Color(0xFFDA212D),
            onChanged: (val) {
              setState(() => _isAgreed = val!);
              if (_isPhoneValid && _isAgreed) _focusNode.unfocus();
            },
            side: const BorderSide(color: Color(0xFF6B6B6B)),
          ),
        ),
        SizedBox(width: context.resW(12)),
        Expanded(
          child: Text.rich(
            TextSpan(
              style: TextStyle(
                color: const Color(0xFFC7C7C7),
                fontSize: context.resClamp(12, 11, 14),
                height: 1.4,
              ),
              children: [
                TextSpan(text: 'login.agree_prefix'.tr()),
                TextSpan(
                  text: 'login.terms'.tr(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(text: 'login.and'.tr()),
                TextSpan(
                  text: 'login.privacy'.tr(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(text: 'login.agree_suffix'.tr()),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    bool isEnabled = _canEnableButton();
    return Column(
      children: [
        _customButton(
          text: 'login.verify_sms'.tr(),
          color: isEnabled ? const Color(0xFFDA212D) : const Color(0xFF454545),
          textColor: isEnabled ? Colors.white : Colors.white38,
          onPressed: isEnabled ? () => _handleLogin('SMS') : null,
        ),
        SizedBox(height: context.resH(16)),
        _customButton(
          text: 'login.verify_zalo'.tr(),
          color: const Color(0xFF2A2A2A),
          textColor: isEnabled
              ? const Color(0xFFE04A50)
              : const Color(0xFF6B6B6B),
          onPressed: isEnabled ? () => _handleLogin('Zalo') : null,
        ),
      ],
    );
  }

  Widget _customButton({
    required String text,
    required Color color,
    required Color textColor,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: context
          .resH(50)
          .clamp(48.0, 60.0), // Responsive height với giới hạn
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          disabledBackgroundColor: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          elevation: 0,
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w600,
            fontSize: context.resClamp(16, 15, 18),
          ),
        ),
      ),
    );
  }
}
