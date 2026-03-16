import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:qr_flutter/qr_flutter.dart'; // Cần thêm thư viện này
import 'package:screen_brightness/screen_brightness.dart'; // Cần thêm thư viện này
import 'package:californiaflutter/helpers/size_utils.dart';

class CommonModalWidget {
  /// Hàm hiển thị Modal QR lớn với khả năng tự động tăng độ sáng màn hình
  static Future<void> showBigQrModal({
    required BuildContext context,
    required String qrData,
    String? instructionText,
    String? closeButtonText,
  }) async {
    double? originalBrightness;

    // final String text = instructionText ?? 'msg_reception_checkin'.tr();

    try {
      // 1. Lưu lại mức độ sáng hiện tại của máy
      originalBrightness = await ScreenBrightness().application;

      // 2. Đẩy độ sáng lên tối đa (1.0) để máy quét dễ đọc
      await ScreenBrightness().setApplicationScreenBrightness(1.0);
    } catch (e) {
      debugPrint("Không thể điều chỉnh độ sáng: $e");
    }

    // 3. Hiển thị Modal Bottom Sheet
    // ignore: use_build_context_synchronously
    await showModalBottomSheet(
      // ignore: use_build_context_synchronously
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF3E3E3E), // Màu nền Dark Mode
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.only(top: context.resH(24)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Thanh kéo (Handle bar) phía trên modal
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: context.resW(20),
                  vertical: context.resH(12),
                ),
                child: Column(
                  children: [
                    // TEXT HƯỚNG DẪN phía trên QR
                    if (instructionText != null) ...[
                      SizedBox(
                        width: context.resW(335),
                        child: Text(
                          instructionText,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: context.resClamp(14, 12, 16),
                            fontWeight: FontWeight.w400,
                            height: 1.50,
                          ),
                        ),
                      ),
                      SizedBox(height: context.resH(16)),
                    ],

                    // KHUNG QR TRẮNG CÓ ĐỘ BO GÓC
                    Container(
                      padding: EdgeInsets.all(context.resW(12)),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE8E8E8)),
                      ),
                      child: QrImageView(
                        data: qrData,
                        version: QrVersions.auto,
                        size: context.resW(173), // Kích thước QR Responsive
                        gapless: false,
                      ),
                    ),

                    SizedBox(height: context.resH(16)),

                    // NÚT ĐÓNG
                    if (closeButtonText != null)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD92229),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            closeButtonText,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: context.resClamp(16, 14, 18),
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                    // Khoảng đệm dưới cùng né thanh tác vụ (Home Indicator)
                    SizedBox(
                      height:
                          MediaQuery.of(context).padding.bottom +
                          context.resH(20),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );

    // 4. KHI MODAL ĐÓNG: Trả lại độ sáng ban đầu cho máy người dùng
    try {
      if (originalBrightness != null) {
        await ScreenBrightness().setApplicationScreenBrightness(
          originalBrightness,
        );
      }
    } catch (e) {
      debugPrint("Không thể trả lại độ sáng: $e");
    }
  }

  static Future<void> showWarningModal({
    required BuildContext context,
    required String imagePath,
    required String title,
    required String description,
    required String buttonText,
    VoidCallback? onConfirm,
  }) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF151515), // Nền Dark Mode chuẩn
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        // Lấy thông số padding đáy để né Home Indicator
        final double bottomPadding = MediaQuery.of(context).padding.bottom;

        return Container(
          width: double.infinity,
          // Sử dụng Padding responsive để nội dung không bị dính sát mép
          padding: EdgeInsets.only(top: context.resH(24)),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Modal tự co giãn theo nội dung
            children: [
              // 1. Thanh kéo (Handle bar) dẹt và bo góc chuẩn UI hiện đại
              Container(
                width: context.resW(40).clamp(30.0, 50.0),
                height: 4,
                margin: EdgeInsets.only(bottom: context.resH(20)),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: context.resH(12)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 2. HÌNH ẢNH MINH HỌA RESPONSIVE
                    // Dùng resW để scale tỷ lệ và clamp để giới hạn kích thước trên máy quá lớn/nhỏ
                    SizedBox(
                      width: context.resW(120).clamp(100.0, 160.0),
                      height: context.resW(120).clamp(100.0, 160.0),
                      child: SvgPicture.asset(imagePath, fit: BoxFit.contain),
                    ),

                    SizedBox(height: context.resH(24)),

                    // 3. CỤM VĂN BẢN (Title & Description)
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.resW(30),
                      ),
                      child: Column(
                        children: [
                          Text(
                            title,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              // Font size co giãn thông minh theo màn hình
                              fontSize: context.resClamp(18, 16, 20),
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                              height: 1.4,
                            ),
                          ),
                          SizedBox(height: context.resH(12)),
                          Text(
                            description,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: const Color(0xFFC7C7C7),
                              // Font nhỏ hơn tiêu đề và co giãn theo tỷ lệ
                              fontSize: context.resClamp(14, 13, 16),
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: context.resH(32)),

                    // 4. NÚT HÀNH ĐỘNG RESPONSIVE
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.resW(20),
                      ),
                      child: ElevatedButton(
                        onPressed: onConfirm ?? () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(
                            0xFFD92229,
                          ), // Màu đỏ thương hiệu
                          // Chiều cao nút scale theo resH, tối thiểu 48px cho trải nghiệm chạm tốt
                          minimumSize: Size(
                            double.infinity,
                            context.resH(48).clamp(44.0, 56.0),
                          ),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        child: Text(
                          buttonText,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: context.resClamp(16, 15, 18),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    // KHOẢNG ĐỆM ĐÁY: Tự động nhận diện Home Indicator
                    SizedBox(
                      height: bottomPadding > 0
                          ? bottomPadding + 10
                          : context.resH(24),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Hàm hiển thị Modal xác nhận (Question Modal)
  static Future<void> showQuestionModal({
    required BuildContext context,
    required String imagePath,
    required String title,
    required VoidCallback onConfirm,
    VoidCallback? onCancel,
    String? opacityImage = 'assets/images/v5/image 1517.png',
  }) async {
    String confirmButton = 'common.btn_agree'.tr();
    String cancelButton = 'common.btn_cancel'.tr();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF3E3E3E), // Màu xám đậm nổi khối
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) {
        // Lấy thông số padding đáy hệ thống để xử lý Home Indicator
        final double bottomPadding = MediaQuery.of(context).padding.bottom;

        return Container(
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          // padding: EdgeInsets.only(top: context.resH(24)),
          child: Stack(
            children: [
              if (opacityImage != null)
                Positioned.fill(
                  child: Center(
                    child: Opacity(
                      opacity: 0.35, // Độ mờ của hình nền chìm
                      child: Image.asset(
                        opacityImage,
                        width: context.resW(280),
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                ),

              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 1. Thanh kéo (Handle bar)
                  Container(
                    width: 40,
                    height: 4,
                    margin: EdgeInsets.only(bottom: context.resH(20)),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: context.resH(12)),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 2. HÌNH ẢNH MINH HỌA RESPONSIVE
                        SizedBox(
                          width: context.resW(120).clamp(100.0, 140.0),
                          height: context.resW(120).clamp(100.0, 140.0),
                          child: SvgPicture.asset(
                            imagePath,
                            fit: BoxFit.contain,
                          ),
                        ),

                        SizedBox(height: context.resH(24)),

                        // 3. TIÊU ĐỀ CÂU HỎI RESPONSIVE
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: context.resW(30),
                          ),
                          child: Text(
                            title,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              // Co giãn font chữ thông minh
                              fontSize: context.resClamp(16, 14, 18),
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500,
                              height: 1.50,
                            ),
                          ),
                        ),

                        SizedBox(height: context.resH(32)),

                        // 4. CỤM NÚT HÀNH ĐỘNG (Cancel & Confirm)
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: context.resW(20),
                          ),
                          child: Row(
                            children: [
                              // Nút Hủy
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    if (onCancel != null) {
                                      onCancel(); // Gọi callback hủy
                                    }
                                  },
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(
                                      color: Color(0xFF6B6B6B),
                                    ),
                                    minimumSize: Size(
                                      double.infinity,
                                      context.resH(48),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  child: Text(
                                    cancelButton,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: context.resW(12)),
                              // Nút Xác nhận
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    onConfirm(); // Gọi callback xác nhận xử lý ở màn hình gọi
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(
                                      0xFFD92229,
                                    ), // Màu đỏ thương hiệu
                                    minimumSize: Size(
                                      double.infinity,
                                      context.resH(48),
                                    ),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  child: Text(
                                    confirmButton,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // KHOẢNG ĐỆM ĐÁY: Tự động né Home Indicator
                        SizedBox(
                          height: bottomPadding > 0 ? bottomPadding + 10 : 30,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
