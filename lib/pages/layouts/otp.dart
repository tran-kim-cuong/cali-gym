import 'dart:async';
import 'dart:ui';
import 'package:californiaflutter/bases/base_api.dart';
import 'package:californiaflutter/bases/loading_wrapper.dart';
// import 'package:californiaflutter/pages/layouts/home.dart';
import 'package:californiaflutter/pages/master.dart';
import 'package:californiaflutter/pages/shared/common_background.dart';
import 'package:californiaflutter/pages/shared/language_bottom_sheet.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:californiaflutter/helpers/session_manager.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:californiaflutter/helpers/size_utils.dart';
import 'package:flutter_svg/svg.dart';

class OtpScreen extends StatefulWidget {
  final String phoneNumber;

  const OtpScreen({super.key, required this.phoneNumber});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> with LoadingWrapper {
  final List<String> _otpCode = ["", "", "", ""];
  int _counter = 119;
  Timer? _timer;

  // Quản lý thông báo
  Timer? _notificationTimer;
  bool _showNotification = false;
  String _notificationMessage = "";
  bool _isErrorNotification = false;

  // Controller ẩn để quản lý nhập liệu tập trung
  final TextEditingController _invisibleController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Tự động mở bàn phím khi vào màn hình (trừ Web)
    // if (!kIsWeb) {
    //   Future.delayed(const Duration(milliseconds: 300), () {
    //     if (mounted) _focusNode.requestFocus();
    //   });
    // }
    _invisibleController.addListener(_updateOtpFromController);
    _focusNode.addListener(() {
      if (mounted) setState(() {});
    });
    _startTimer();
  }

  void _updateOtpFromController() {
    String text = _invisibleController.text;
    setState(() {
      for (int i = 0; i < 4; i++) {
        _otpCode[i] = i < text.length ? text[i] : "";
      }
    });

    // TỰ ĐỘNG ẨN BÀN PHÍM KHI NHẬP ĐỦ 4 SỐ
    if (text.length == 4) {
      _focusNode.unfocus(); // Trả giao diện về vị trí cũ (50/50)
    }
  }

  // --- GIỮ NGUYÊN LOGIC TIMER & API ---
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_counter > 0) {
        setState(() => _counter--);
      } else {
        _timer?.cancel();
      }
    });
  }

  void _showTopNotification(String message, {bool isError = false}) {
    setState(() {
      _notificationMessage = message;
      _isErrorNotification = isError;
      _showNotification = true;
    });
    _notificationTimer?.cancel();
    _notificationTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showNotification = false);
    });
  }

  Future<void> getClientInfo(String phone) async {
    String clientId = dotenv.get('CLIENT_ID');

    try {
      final response = await BaseApi().crmClient.get(
        '/api/v1/Web/clientinfo',
        queryParameters: {'phoneNumber': phone},
      );

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> dataList = response.data['Data'] ?? [];
        // Giả sử API trả về ClientId trong data
        if (dataList.isNotEmpty) {
          // 2. Lấy phần tử đầu tiên [0] và truy cập key 'clientNumber'
          clientId = dataList[0]['clientNumber'];
        }
      }
    } catch (e) {
      debugPrint("Lỗi lấy thông tin khách hàng từ CRM: $e");
    }

    // 3. Lưu vào Session để các màn hình khác (như Home) có thể dùng
    SessionManager.sClientId = clientId;
    await SessionManager.setClientId(clientId);
  }

  Future<void> _verifyOtp() async {
    String code = _otpCode.join();
    if (code == SessionManager.otp) {
      try {
        final response = await handleApi(
          context,
          BaseApi().client.post(
            '/api/login',
            data: {
              "email": dotenv.env["CALIFORNIA_USER_NAME"],
              "password": dotenv.env["CALIFORNIA_PASSWORD"],
            },
          ),
        );

        if (!mounted) return;

        if (response != null && response.statusCode == 200) {
          SessionManager.setLoggedIn(true, response.data['token']);

          String? phoneNr = await SessionManager.getPhoneNumber();
          if (phoneNr != null && phoneNr != '') {
            await getClientInfo(phoneNr);
          } else {
            await SessionManager.setClientId(dotenv.get('CLIENT_ID'));
          }

          // SessionManager.sClientId = dotenv.env["CLIENT_ID"]!;
          if (mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const MasterScreen()),
              (route) => false,
            );
          }
        }
      } catch (e) {
        _showTopNotification("otp.verify_error".tr(), isError: true);
      }
    } else {
      _showTopNotification("otp.verify_error".tr(), isError: true);
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
    final double screenHeight = MediaQuery.of(context).size.height;
    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final bool isKeyboardOpen = keyboardHeight > 0;

    final double topPadding = MediaQuery.of(context).padding.top;
    final double bottomPadding = MediaQuery.of(context).padding.bottom;

    // 1. CHIA TỈ LỆ 50-50 CHUẨN
    // Tính toán chiều cao khả dụng sau khi trừ đi các khoảng padding hệ thống
    final double availableHeight = screenHeight - topPadding - bottomPadding;
    final double halfHeight = availableHeight / 2;

    return Scaffold(
      backgroundColor: const Color(0xFF151515),
      resizeToAvoidBottomInset:
          false, // Tự xử lý đẩy nội dung để hiệu ứng mượt hơn
      body: Stack(
        children: [
          // LỚP 1: BACKGROUND CỐ ĐỊNH (Nằm trọn trong 50% phía trên)
          CommonBackgroundWidget.buildBackgroundImage(
            context,
            dotenv.get('IMAGES_BG_LOGIN_V3_LAYER'),
          ),

          // LỚP 2: LÀM MỜ NỀN KHI NHẬP OTP
          if (isKeyboardOpen)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: halfHeight + topPadding,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(color: Colors.black.withValues(alpha: 0.3)),
              ),
            ),

          // LỚP 3: NỘI DUNG CUỘN
          SingleChildScrollView(
            physics:
                const ClampingScrollPhysics(), // Luôn cho phép cuộn nhẹ nếu nội dung dài hơn 50%
            child: Column(
              children: [
                // KHOẢNG TRỐNG TRÊN (Chứa nút Back và Ngôn ngữ)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  // Khi có phím, co lại để đẩy Form lên, lộ 30% ảnh mờ phía sau
                  height: isKeyboardOpen
                      ? (halfHeight + topPadding) * 0.3
                      : halfHeight + topPadding,
                  width: double.infinity,
                  color: Colors.transparent,
                  child: SafeArea(
                    child: Stack(
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: IconButton(
                            icon: const Icon(
                              Icons.arrow_back_ios,
                              color: Colors.white,
                              size: 20,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        Align(
                          alignment: Alignment.topRight,
                          child: Padding(
                            padding: EdgeInsets.only(
                              right: context.resW(20),
                              top: context.resH(10),
                            ),
                            child: _buildLanguageSelector(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // VÙNG FORM (Chiếm 50% chiều cao còn lại)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  constraints: BoxConstraints(
                    // Đảm bảo Form luôn chiếm ít nhất 50% màn hình khi không có phím
                    minHeight: isKeyboardOpen
                        ? screenHeight * 0.85
                        : halfHeight + bottomPadding,
                  ),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF151515),
                    borderRadius: isKeyboardOpen
                        ? const BorderRadius.vertical(top: Radius.circular(24))
                        : BorderRadius.zero,
                  ),
                  padding: EdgeInsets.symmetric(horizontal: context.resW(24)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: context.resH(20)),
                      Text(
                        'otp.title'.tr(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: context.resClamp(24, 20, 28),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: context.resH(6)),
                      _buildSubtitle(),

                      SizedBox(height: context.resH(20)),

                      GestureDetector(
                        onTap: () {
                          // Reset focus triệt để để ép bàn phím hiện lại
                          _focusNode.unfocus();
                          Future.delayed(const Duration(milliseconds: 50), () {
                            if (mounted) _focusNode.requestFocus();
                          });
                        },
                        child: _buildOtpInputs(isKeyboardOpen),
                      ),

                      // TextField ẩn điều khiển bàn phím
                      Opacity(
                        opacity: 0,
                        child: SizedBox(
                          width: 1,
                          height: 1,
                          child: TextField(
                            controller: _invisibleController,
                            focusNode: _focusNode,
                            autofocus: false,
                            keyboardType: TextInputType.number,
                            maxLength: 4,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: context.resH(12)),
                      _buildTimerText(),
                      SizedBox(height: context.resH(20)),
                      _buildActionButtons(bottomPadding),

                      // Khoảng cách an toàn cuối cùng
                      SizedBox(
                        height: isKeyboardOpen
                            ? keyboardHeight + 20
                            : (bottomPadding > 0
                                  ? bottomPadding
                                  : context.resH(30)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Thông báo
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            top: _showNotification ? 60 : -150,
            left: 20,
            right: 20,
            child: _buildTopNotification(),
          ),
        ],
      ),
    );
  }

  // Gắn hàm build ngôn ngữ từ login.dart
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
              child: SvgPicture.asset(
                currentCode == 'vi'
                    ? 'assets/images/vietnam.svg'
                    : 'assets/images/kingdom.svg',
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

  Widget _buildSubtitle() {
    return Text.rich(
      TextSpan(
        style: const TextStyle(
          color: Color(0xFFC7C7C7),
          fontSize: 14,
          height: 1.4,
        ),
        children: [
          TextSpan(text: 'otp.subtitle_prefix'.tr()),
          const TextSpan(text: ' '),
          TextSpan(
            text: widget.phoneNumber,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Đồng bộ giao diện ô OTP với hình mẫu
  Widget _buildOtpInputs(bool isKeyboardOpen) {
    int currentIndex = _invisibleController.text.length;
    bool hasFocus = _focusNode.hasFocus;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(4, (index) {
        // ĐIỀU KIỆN MỚI: Chỉ hiện viền trắng khi bàn phím đang mở
        bool isFocused =
            isKeyboardOpen &&
            hasFocus &&
            (index == currentIndex || (index == 3 && currentIndex == 4));

        return Container(
          width: context.resW(75),
          height: context.resH(85),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              // Viền sẽ tự động chuyển về màu xám (#333333) khi isKeyboardOpen = false
              color: isFocused ? Colors.white : const Color(0xFF333333),
              width: isFocused ? 2 : 1,
            ),
          ),
          child: Center(
            child: Text(
              _otpCode[index],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }),
    );
  }

  // --- CÁC WIDGET PHỤ TRỢ (GIỮ LOGIC CŨ) ---
  Widget _buildTimerText() {
    if (_counter > 0) {
      return Center(
        child: Text.rich(
          TextSpan(
            style: const TextStyle(color: Color(0xFFE8E8E8), fontSize: 14),
            children: [
              TextSpan(text: 'otp.resend_in'.tr()),
              TextSpan(
                text: " ${_formatTime(_counter)}",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Center(
      child: GestureDetector(
        onTap: _resendOtp,
        child: Text(
          'otp.resend_link'.tr(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }

  String _formatTime(int seconds) {
    int mins = seconds ~/ 60;
    int secs = seconds % 60;
    return "${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}s";
  }

  void _resendOtp() {
    setState(() => _counter = 119);
    _startTimer();
    _invisibleController.clear();
  }

  Widget _buildActionButtons(double systemPadding) {
    bool isComplete = !_otpCode.contains("");
    return Column(
      children: [
        _customButton(
          text: 'common.accept'.tr(),
          color: isComplete ? const Color(0xFFDA212D) : const Color(0xFF333333),
          textColor: isComplete ? Colors.white : Colors.white24,
          onPressed: isComplete ? _verifyOtp : null,
        ),
        _buildOrDivider(),
        _customButton(
          text: 'login.verify_zalo'.tr(),
          color: const Color(0xFF2A2A2A),
          textColor: const Color(0xFFE04A50),
          onPressed: () => _showTopNotification("otp.zalo_sent".tr()),
        ),
        // Dịch chuyển button xích lên nếu có dải nút tác vụ (3 nút hoặc gesture bar)
        if (systemPadding > 0)
          SizedBox(height: systemPadding)
        else
          const SizedBox(height: 0),
      ],
    );
  }

  Widget _buildOrDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 8,
      ), // Giảm padding từ 16 xuống 12
      child: Row(
        children: [
          Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.1))),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              'common.or'.tr(),
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
          Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.1))),
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
      height: context.resH(48).clamp(44, 55),
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

  Widget _buildTopNotification() {
    /* Giữ nguyên widget thông báo của bạn */
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
        children: [
          _isErrorNotification
              ? const Icon(Icons.cancel, color: Color(0xFFFF4B4B), size: 24)
              : const Icon(
                  Icons.check_circle,
                  color: Color(0xFF26CE55),
                  size: 24,
                ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _notificationMessage,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
