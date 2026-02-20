import 'package:californiaflutter/bases/base_api.dart';
import 'package:californiaflutter/bases/loading_wrapper.dart';
import 'package:californiaflutter/bases/notification_mixin.dart';
import 'package:californiaflutter/helpers/session_manager.dart';
import 'package:californiaflutter/pages/shared/language_bottom_sheet.dart';
import 'package:californiaflutter/pages/shared/number_key.dart';
import 'package:californiaflutter/pages/layouts/otp.dart';
import 'package:californiaflutter/services/api_service.dart';
import 'package:dio/dio.dart' as dio_form;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:californiaflutter/helpers/size_utils.dart'; // Đảm bảo import đúng đường dẫn

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with LoadingWrapper, NotificationMixin {
  final TextEditingController _phoneController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isAgreed = false;
  bool _isPhoneValid = false;

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_onPhoneChanged);
    // Tự động focus khi vào màn hình (tuỳ chọn)
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   _focusNode.requestFocus();
    // });
  }

  @override
  void dispose() {
    _phoneController.removeListener(_onPhoneChanged);
    _phoneController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onPhoneChanged() {
    setState(() {
      _isPhoneValid = _phoneController.text.length >= 10;
    });
    if (_phoneController.text.length == 10 && _isAgreed) {
      // TỰ ĐỘNG ẨN BÀN PHÍM: Nếu đủ 10 số và đã tích chọn đồng ý
      _focusNode.unfocus();
      // Tự động ẩn bàn phím khi đủ 10 số (tuỳ chọn)
      // _focusNode.unfocus();
    }
  }

  bool _canEnableButton() => _isAgreed && _isPhoneValid;

  // --- LOGIC API GIỮ NGUYÊN ---
  Future<void> _handleLogin(String method) async {
    String phoneNumber = _phoneController.text;
    // Validate cơ bản trước khi gọi API
    if (phoneNumber.isEmpty || phoneNumber.length < 10) {
      showTopNotification("Vui lòng nhập số điện thoại hợp lệ", isError: true);
      return;
    }

    if (!_isAgreed) {
      showTopNotification("Vui lòng đồng ý với điều khoản", isError: true);
      return;
    }

    String otpCode = gen4Digits().toString();
    // ... (Phần code API giữ nguyên như cũ của bạn)
    dio_form.FormData formData = dio_form.FormData.fromMap({
      "api_key": dotenv.env["SMS_API_KEY"],
      "message": "${dotenv.env["SMS_MESSAGE"]} $otpCode",
      "phone_number": phoneNumber,
      "brand_name": dotenv.env["SMS_BRAND_NAME"],
      "sender": dotenv.env["SMS_SENDER"],
    });

    if (method == 'SMS') {
      try {
        final response = await handleApi(
          context,
          BaseApi().smsClient.post('/api/sms/send', data: formData),
        );

        if (response?.statusCode == 200) {
          SessionManager.otp = otpCode;
          SessionManager.setPersonalInfo(phoneNumber);
          SessionManager.sSdt = phoneNumber;

          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OtpScreen(phoneNumber: phoneNumber),
              ),
            );
          }
        }
      } catch (e) {
        debugPrint("Lỗi gửi SMS: $e");
        showTopNotification("Có lỗi xảy ra khi gửi SMS", isError: true);
      }
    } else if (method == 'Zalo') {
      showTopNotification("Tính năng đăng nhập qua Zalo đang phát triển");
    }
  }

  void _onKeyboardTap(String key) {
    String currentText = _phoneController.text;
    if (key == "delete") {
      if (currentText.isNotEmpty) {
        _phoneController.text = currentText.substring(
          0,
          currentText.length - 1,
        );
      }
    } else if (key.isNotEmpty && currentText.length < 10) {
      _phoneController.text = currentText + key;
    }
    // Cần kích hoạt listener thủ công khi thay đổi text bằng code
    _onPhoneChanged();
  }

  @override
  Widget build(BuildContext context) {
    // 1. Lấy kích thước tổng thể màn hình (không thay đổi khi có bàn phím)
    final double screenHeight = MediaQuery.of(context).size.height;
    final double viewPaddingTop = MediaQuery.of(context).padding.top;
    final double viewPaddingBottom = MediaQuery.of(context).padding.bottom;

    // Tính toán 50% màn hình dựa trên kích thước thật của máy
    final double halfHeight =
        (screenHeight - viewPaddingTop - viewPaddingBottom) / 2;

    return Scaffold(
      backgroundColor: const Color(0xFF151515),
      // Giữ nguyên thuộc tính này để scaffold biết tự tránh bàn phím
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // 2. FIX LỖI BÀN PHÍM: Bọc toàn bộ nội dung chính trong SingleChildScrollView
          SingleChildScrollView(
            // Thêm physics để cuộn mượt mà hơn khi bàn phím xuất hiện
            physics: const ClampingScrollPhysics(),
            child: Column(
              children: [
                // 3. PHẦN TRÊN: HÌNH ẢNH + LANGUAGE
                // Thay Expanded bằng SizedBox với chiều cao cố định (50% màn hình)
                SizedBox(
                  height: halfHeight,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.asset(
                          'assets/images/background_login_v3_layer.png', // Đảm bảo đường dẫn ảnh đúng
                          fit: BoxFit.cover,
                          alignment: const Alignment(0.3, 0),
                        ),
                      ),
                      // Lớp phủ gradient
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.1),
                                const Color(0xFF151515),
                              ],
                              stops: const [
                                0.6,
                                1.0,
                              ], // Điều chỉnh điểm chuyển màu
                            ),
                          ),
                        ),
                      ),
                      // Language Selector
                      SafeArea(
                        child: Padding(
                          // Sử dụng helper context.resW/H cho padding
                          padding: EdgeInsets.only(
                            right: context.resW(20),
                            top: context.resH(10),
                          ),
                          child: Align(
                            alignment: Alignment.topRight,
                            child: _buildLanguageSelector(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 4. PHẦN DƯỚI: FORM ĐĂNG NHẬP
                // Thay Expanded bằng Container với chiều cao cố định (50% còn lại)
                Container(
                  constraints: BoxConstraints(minHeight: halfHeight),
                  width: double.infinity,
                  color: const Color(0xFF151515),
                  padding: EdgeInsets.symmetric(horizontal: context.resW(24)),
                  // 5. QUAN TRỌNG: Bỏ SingleChildScrollView bên trong này đi
                  // vì đã có cái bao bọc bên ngoài rồi.
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    // Dùng MainAxisAlignment.center nếu muốn nội dung căn giữa khi không có phím
                    // Hoặc start và thêm padding top nếu muốn nó nằm cố định phía trên.
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'login.phone_input_title'.tr(),
                        style: TextStyle(
                          color: Colors.white,
                          // Sử dụng context.resClamp cho font chữ
                          fontSize: context.resClamp(18, 16, 22),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: context.resH(20)),

                      // TextField
                      _buildPhoneTextField(),

                      SizedBox(height: context.resH(16)),

                      // Điều khoản
                      _buildAgreementText(),

                      SizedBox(height: context.resH(30)),

                      // Nút bấm
                      _buildActionButtons(),

                      // Bàn phím số ảo (chỉ hiện trên Web)
                      if (kIsWeb) ...[
                        SizedBox(height: context.resH(20)),
                        NumericKeyboard(onKeyTap: _onKeyboardTap),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          buildNotificationWidget(),
        ],
      ),
    );
  }

  // ... (Các widget con: _buildLanguageSelector, _buildPhoneTextField,
  //      _buildAgreementText, _buildActionButtons, _customButton GIỮ NGUYÊN)
  Widget _buildLanguageSelector() {
    final String currentCode = context.locale.languageCode;
    return GestureDetector(
      onTap: () => LanguageBottomSheet.show(context: context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black26,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              // Đảm bảo bạn đã có file svg này
              child: SvgPicture.asset(
                currentCode == 'vi'
                    ? 'assets/images/vietnam.svg'
                    : 'assets/images/kingdom.svg',
                // Fallback icon nếu chưa có svg (xoá dòng này khi đã có icon)
                // placeholderBuilder: (context) =>
                //     const Icon(Icons.flag, color: Colors.white, size: 20),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              currentCode == 'vi' ? 'Tiếng Việt' : 'English',
              style: const TextStyle(color: Colors.white, fontSize: 12),
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
      keyboardType: TextInputType.phone,
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

  Widget _buildAgreementText() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: _isAgreed,
            activeColor: const Color(0xFFDA212D),
            onChanged: (val) => setState(() => _isAgreed = val!),
            side: const BorderSide(color: Color(0xFF6B6B6B)),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        const SizedBox(width: 12),
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
      // Scale chiều cao nút bấm
      height: context.resH(48).clamp(44.0, 55.0),
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
            fontSize: context.resClamp(16, 14, 18),
          ),
        ),
      ),
    );
  }
}
