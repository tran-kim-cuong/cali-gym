import 'dart:async';
import 'package:californiaflutter/pages/layouts/home.dart';
import 'package:californiaflutter/pages/shared/number_key.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OtpScreen extends StatefulWidget {
  final String phoneNumber; // Nhận số điện thoại từ màn hình Login

  const OtpScreen({super.key, required this.phoneNumber});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<String> _otpCode = ["", "", "", ""]; // Lưu trữ 4 số OTP
  int _counter = 119; // 01:59s = 119 giây
  Timer? _timer;

  // --- CẬP NHẬT 1: CÁC BIẾN QUẢN LÝ THÔNG BÁO ---
  Timer? _notificationTimer;
  bool _showNotification = false;
  String _notificationMessage = ""; // Nội dung thông báo
  bool _isErrorNotification = false; // Trạng thái lỗi (True = Đỏ, False = Xanh)

  // Controller dùng cho bàn phím hệ thống trên Mobile
  final TextEditingController _invisibleController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    // Nếu không phải web, tự động mở bàn phím hệ thống
    if (!kIsWeb) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode.requestFocus();
      });
    }

    _invisibleController.addListener(() {
      _updateOtpFromController();
    });

    _startTimer();
  }

  // Cập nhật mảng _otpCode khi nhập từ bàn phím thật
  void _updateOtpFromController() {
    String text = _invisibleController.text;
    setState(() {
      for (int i = 0; i < 4; i++) {
        _otpCode[i] = i < text.length ? text[i] : "";
      }
    });

    // YÊU CẦU 3: NHẬP ĐỦ OTP THÌ ẨN BÀN PHÍM
    if (text.length == 4) {
      _focusNode.unfocus(); // Đóng bàn phím hệ thống
      // Tùy chọn: Gọi luôn hàm xác thực nếu muốn
      // _verifyOtp();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_counter > 0) {
        setState(() => _counter--);
      } else {
        _timer?.cancel();
      }
    });
  }

  // --- CẬP NHẬT 2: HÀM HIỂN THỊ THÔNG BÁO CHUNG ---
  void _showTopNotification(String message, {bool isError = false}) {
    setState(() {
      _notificationMessage = message;
      _isErrorNotification = isError;
      _showNotification = true;
    });

    _notificationTimer?.cancel();
    _notificationTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showNotification = false;
        });
      }
    });
  }

  String _formatTime(int seconds) {
    int mins = seconds ~/ 60;
    int secs = seconds % 60;
    return "${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}s";
  }

  // Hàm xử lý khi nhấn nút Xác nhận (Rap API ở đây)
  void _verifyOtp() {
    String code = _otpCode.join();
    // Giả lập logic: Nếu mã là "1234" thì thành công, ngược lại thì báo lỗi
    if (code == "1234") {
      // Thành công -> Chuyển màn hình hoặc báo thành công
      _showTopNotification("otp.verify_success".tr(), isError: false);

      // Sau khi thành công, chuyển trang:
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
        (route) => false, // Xóa hết các route cũ
      );
    } else {
      // Thất bại -> Hiện thông báo lỗi như hình
      _showTopNotification("otp.verify_error".tr(), isError: true);
    }
  }

  // Sự kiện nút Zalo
  void _onZaloPressed() {
    _showTopNotification(
      "otp.zalo_sent".tr(),
      isError: false,
    );
  }

  // 2. Trong _OtpScreenState, thêm hàm xử lý:
  void _onKeyboardTap(String key) {
    if (key == "delete") {
      // Xóa từ phải qua trái
      for (int i = 3; i >= 0; i--) {
        if (_otpCode[i] != "") {
          setState(() => _otpCode[i] = "");
          break;
        }
      }
    } else if (key.isNotEmpty) {
      // Điền vào ô trống đầu tiên
      for (int i = 0; i < 4; i++) {
        if (_otpCode[i] == "") {
          setState(() {
            _otpCode[i] = key;

            // YÊU CẦU 3 (CHO WEB): ẨN BÀN PHÍM CUSTOM NẾU CẦN
            // Ở đây vì là bàn phím custom nên ta có thể để nguyên hoặc ẩn widget đi
            // Nếu muốn ẩn widget NumericKeyboard, bạn cần thêm biến bool showKeyboard vào state
          });
          break;
        }
      }

      // Kiểm tra lại sau khi điền xong
      if (!_otpCode.contains("")) {
        // Đã nhập đủ 4 số
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _notificationTimer?.cancel();
    _invisibleController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF4A0D0D), Color(0xFF1A1D22)],
          ),
        ),
        child: Stack(
          children: [
            SafeArea(
              child: Stack(
                // Dùng Stack để giấu TextField ẩn
                children: [
                  // TextField ẩn để hứng sự kiện từ bàn phím hệ thống (Mobile)
                  if (!kIsWeb)
                    SizedBox(
                      width: 0,
                      height: 0,
                      child: TextField(
                        controller: _invisibleController,
                        focusNode: _focusNode,
                        keyboardType: TextInputType.number,
                        maxLength: 4,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        autofocus: true,
                      ),
                    ),

                  Column(
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 40),
                      _buildTitleSection(),
                      const SizedBox(height: 32),

                      // Khi click vào vùng này trên mobile sẽ mở lại bàn phím
                      GestureDetector(
                        onTap: () => _focusNode.requestFocus(),
                        child: _buildOtpInputs(),
                      ),
                      const SizedBox(height: 20), // Thêm khoảng cách
                      _buildTimerText(),
                      const Spacer(),
                      _buildActionButtons(),

                      // CHỈ HIỆN BÀN PHÍM TÙY CHỈNH TRÊN WEB
                      if (kIsWeb) NumericKeyboard(onKeyTap: _onKeyboardTap),
                    ],
                  ),
                ],
              ),
            ),

            // --- CẬP NHẬT 4: ANIMATED NOTIFICATION ---
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              top: _showNotification ? 60 : -150,
              left: 20,
              right: 20,
              child: _buildTopNotification(),
            ),
          ],
        ),
      ),
    );
  }

  // --- CẬP NHẬT 5: WIDGET THÔNG BÁO LINH HOẠT ---
  Widget _buildTopNotification() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon thay đổi tùy trạng thái
          _isErrorNotification
              ? Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF4B4B), // Màu đỏ nền icon lỗi
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, color: Colors.black, size: 14),
                )
              : const Icon(
                  Icons.check_circle_outline,
                  color: Color(0xFF26CE55), // Màu xanh thành công
                  size: 24,
                ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _notificationMessage, // Nội dung động
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontFamily: 'Inter',
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'otp.title'.tr(),
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text.rich(
            TextSpan(
              style: const TextStyle(
                color: Color(0xFFC7C7C7),
                fontSize: 14,
                height: 1.5,
              ),
              children: [
                TextSpan(
                  text: 'otp.subtitle_prefix'.tr(),
                ),
                TextSpan(
                  text: widget.phoneNumber, // Hiển thị số điện thoại từ Login
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpInputs() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(4, (index) {
        return Container(
          width: 60,
          height: 70,
          decoration: BoxDecoration(
            color: const Color(0xFF141414),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF6B6B6B)),
          ),
          child: Center(
            child: Text(
              _otpCode[index],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTimerText() {
    if (_counter > 0) {
      return Center(
        child: Text.rich(
          TextSpan(
            style: const TextStyle(color: Color(0xFFE8E8E8), fontSize: 14),
            children: [
              TextSpan(text: 'otp.resend_in'.tr()),
              TextSpan(
                text: _formatTime(_counter),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      // Khi đã về 00:00: Hiển thị dạng link "Gửi lại mã"
      return GestureDetector(
        onTap: () {
          // Logic gửi lại mã OTP mới ở đây
          _resendOtp();
        },
        child: Text(
          'otp.resend_link'.tr(),
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            decoration:
                TextDecoration.underline, // Tạo gạch chân giống dạng link
          ),
        ),
      );
    }
  }

  void _resendOtp() {
    // 1. Gọi API gửi lại mã ở đây (nếu có)
    print("Đang gửi lại mã OTP mới đến ${widget.phoneNumber}...");

    // 2. Reset lại đồng hồ đếm ngược
    setState(() {
      _counter = 119; // Reset về 01:59
    });

    // 3. Chạy lại Timer
    _startTimer();

    // 4. (Tùy chọn) Xóa mã OTP cũ đã nhập
    _invisibleController.clear();
    setState(() {
      for (int i = 0; i < 4; i++) _otpCode[i] = "";
    });
  }

  // Cập nhật phần Action Buttons giống hình thiết kế
  Widget _buildActionButtons() {
    bool isComplete = !_otpCode.contains("");

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: Column(
        children: [
          // Nút Xác nhận
          _customButton(
            text: 'common.accept'.tr(),
            color: isComplete
                ? const Color(0xFFDA212D)
                : const Color(0xFF333333),
            textColor: isComplete ? Colors.white : Colors.white24,
            onPressed: isComplete ? _verifyOtp : null,
          ),

          // Dòng "hoặc"
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: Divider(color: Colors.white.withValues(alpha: 0.2)),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    'common.or'.tr(),
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
                Expanded(
                  child: Divider(color: Colors.white.withValues(alpha: 0.2)),
                ),
              ],
            ),
          ),

          // Nút Xác thực qua Zalo
          _customButton(
            text: 'login.verify_zalo'.tr(),
            color: const Color(0xFF2A2A2A), // Màu tối theo thiết kế
            textColor: const Color(0xFFE04A50), // Chữ màu đỏ Zalo
            onPressed: _onZaloPressed,
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _customButton({
    required String text,
    required Color color,
    required Color textColor,
    VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 48,
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
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
