import 'package:californiaflutter/helpers/session_manager.dart';
import 'package:californiaflutter/pages/shared/language_bottom_sheet.dart';
import 'package:californiaflutter/pages/shared/number_key.dart';
import 'package:californiaflutter/pages/layouts/otp.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:californiaflutter/services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controller để lấy số điện thoại sau này rap API
  final TextEditingController _phoneController = TextEditingController();
  bool _isAgreed = false;
  bool _isPhoneValid = false; // Biến kiểm tra số điện thoại

  // String _currentLanguage = 'vi';

  final FocusNode _focusNode = FocusNode();

  // Hàm xử lý Login (nơi bạn sẽ rap API)
  Future<void> _handleLogin(String method) async {
    String phoneNumber = _phoneController.text;

    // int otp = gen4Digits();
    // SessionManager.otp = otp.toString();
    // SessionManager.sSdt = phoneNumber;
    // await snedSms(otp.toString(), phoneNumber);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OtpScreen(phoneNumber: phoneNumber),
      ),
    );
    // print('Calling API with Phone: $phoneNumber via $method');
    // Implement API logic here
  }

  // 2. Trong _LoginScreenState, thêm hàm xử lý phím:
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
  }

  @override
  void initState() {
    super.initState();
    // Lắng nghe thay đổi của ô nhập liệu
    _phoneController.addListener(() {
      setState(() {
        // Ví dụ: số điện thoại hợp lệ khi có từ 10 chữ số trở lên
        _isPhoneValid = _phoneController.text.length >= 10;
      });
    });

    _phoneController.addListener(_onPhoneChanged);

    // 2. THÊM ĐOẠN NÀY: Tự động Focus khi màn hình khởi động xong
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _phoneController.removeListener(_onPhoneChanged);
    _focusNode.dispose();
    super.dispose();
  }

  // Hàm xử lý khi nhập liệu thay đổi
  void _onPhoneChanged() {
    setState(() {
      _isPhoneValid = _phoneController.text.length >= 10;
    });

    // LOGIC ẨN BÀN PHÍM TỰ ĐỘNG
    if (_phoneController.text.length == 10) {
      _focusNode.unfocus(); // Ẩn bàn phím hệ thống (Mobile)
      // Đối với bàn phím Custom trên Web, ta có thể dùng biến bool để ẩn nếu cần
    }
  }

  // Điều kiện để kích hoạt nút bấm
  bool _canEnableButton() {
    return _isAgreed && _isPhoneValid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Sử dụng resizeToAvoidBottomInset để khi hiện bàn phím không bị lỗi layout
      resizeToAvoidBottomInset: false,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            // Màu sắc dựa trên hình ảnh bạn gửi
            colors: [Color(0xFF4A0D0D), Color(0xFF1A1D22)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(), // Phần Tiếng Việt sát trên cùng
              const SizedBox(height: 60), // Tạo khoảng cách từ đỉnh xuống Logo

              _buildMainContent(), // Logo + Input + Agreement

              const Spacer(), // Đẩy tất cả phần dưới xuống đáy màn hình

              _buildActionButtons(), // 2 Nút xác thực nằm ở dưới cùng
              const SizedBox(height: 20), // Padding đáy theo hình thiết kế

              if (kIsWeb) NumericKeyboard(onKeyTap: _onKeyboardTap),
            ],
          ),
        ),
      ),
    );
  }

  // 1. Phần Header: Ngôn ngữ và Logo
  Widget _buildHeader() {
    // 2. LẤY MÃ NGÔN NGỮ HIỆN TẠI ĐỂ HIỂN THỊ CỜ
    // context.locale là biến toàn cục của thư viện
    final String currentCode = context.locale.languageCode;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          GestureDetector(
            // GỌI HÀM TỪ FILE RIÊNG TẠI ĐÂY
            onTap: () {
              LanguageBottomSheet.show(context: context);
            },
            child: Container(
              color: Colors.transparent,
              child: Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: SvgPicture.asset(
                      currentCode == 'vi'
                          ? 'assets/images/vietnam.svg'
                          : 'assets/images/kingdom.svg',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    currentCode == 'vi'
                        ? 'common.lang_vi'.tr()
                        : 'common.lang_en'.tr(),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Cập nhật lại MainContent để căn chỉnh sát hơn
  Widget _buildMainContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Image.asset(
            "assets/images/logo.png",
            width: 280, // Tăng chiều rộng để giống hình mẫu
            fit: BoxFit.fill,
          ),
          const SizedBox(height: 48), // Khoảng cách từ Logo đến ô nhập
          // TextField Số điện thoại
          TextField(
            controller: _phoneController,
            // THÊM DÒNG NÀY ĐỂ LIÊN KẾT FOCUS NODE
            focusNode: _focusNode,
            keyboardType: TextInputType.phone,
            readOnly: kIsWeb,
            // 1. Set độ dài tối đa là 10
            maxLength: 10,
            // 2. Chỉ cho phép nhập số (0-9)
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              // 3. Ẩn dòng đếm số (ví dụ 0/10) ở dưới góc phải nếu bạn muốn giao diện sạch hơn
              counterText: "",
              hintText: 'login.phone_hint'.tr(),
              hintStyle: const TextStyle(color: Color(0xFFC7C7C7)),
              prefixIcon: const Padding(
                padding: EdgeInsets.all(12),
                child: Icon(
                  Icons.smartphone,
                  color: Color(0xFFC7C7C7),
                ), // Icon giống hình hơn
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Color(0xFF6B6B6B)),
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Colors.black.withValues(alpha: 0.3),
            ),
          ),
          const SizedBox(height: 16),

          _buildAgreementText(),
        ],
      ),
    );
  }

  // 3. Phần RichText cho điều khoản
  Widget _buildAgreementText() {
    return Row(
      children: [
        Checkbox(
          value: _isAgreed,
          onChanged: (val) => setState(() => _isAgreed = val!),
          side: const BorderSide(color: Color(0xFFF6CACC)),
        ),
        Expanded(
          child: Text.rich(
            TextSpan(
              style: const TextStyle(
                color: Color(0xFFC7C7C7),
                fontSize: 12,
                height: 1.5,
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

  // 4. Các nút bấm xác thực
  Widget _buildActionButtons() {
    bool isEnabled = _canEnableButton();

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _customButton(
            text: 'login.verify_sms'.tr(),
            // Nếu enable thì dùng màu xám sáng, disable dùng màu tối hơn
            color: isEnabled
                ? const Color(0xFFDA212D)
                : const Color(0xFF454545),
            textColor: isEnabled ? Colors.white : Colors.white38,
            onPressed: isEnabled
                ? () => _handleLogin('SMS')
                : null, // null sẽ disable button
          ),
          const SizedBox(height: 16),
          _customButton(
            text: 'login.verify_zalo'.tr(),
            color: isEnabled
                ? const Color(0xFF3E3E3E)
                : const Color(0xFF2A2A2A),
            textColor: isEnabled
                ? const Color(0xFFE04A50)
                : const Color(0xFF6B6B6B),
            onPressed: isEnabled ? () => _handleLogin('Zalo') : null,
          ),
        ],
      ),
    );
  }

  // Widget dùng chung cho Button
  // Cập nhật Widget Button để nhận giá trị null cho onPressed
  Widget _customButton({
    required String text,
    required Color color,
    required Color textColor,
    required VoidCallback? onPressed, // Cho phép nhận null
  }) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          disabledBackgroundColor: color, // Giữ nguyên màu khi bị disable
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          elevation: 0,
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
