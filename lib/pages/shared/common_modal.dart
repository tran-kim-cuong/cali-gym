import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart'; // Cần thêm thư viện này
import 'package:screen_brightness/screen_brightness.dart'; // Cần thêm thư viện này
import 'package:californiaflutter/helpers/size_utils.dart';

class CommonModalWidget {
  /// Hàm hiển thị Modal QR lớn với khả năng tự động tăng độ sáng màn hình
  static Future<void> showBigQrModal({
    required BuildContext context,
    required String qrData,
    String instructionText = 'Vui lòng đưa mã này cho lễ tân để check-in',
  }) async {
    double? originalBrightness;

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
      backgroundColor: const Color(0xFF151515), // Màu nền Dark Mode
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

                    // TEXT HƯỚNG DẪN RESPONSIVE
                    SizedBox(
                      width: context.resW(335),
                      child: Text(
                        instructionText,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          // Sử dụng resClamp để chữ không bị vỡ trên máy nhỏ
                          fontSize: context.resClamp(16, 14, 18), 
                          fontWeight: FontWeight.w500,
                          height: 1.50,
                        ),
                      ),
                    ),
                    // Khoảng đệm dưới cùng né thanh tác vụ (Home Indicator)
                    SizedBox(height: MediaQuery.of(context).padding.bottom + context.resH(20)),
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
        await ScreenBrightness().setApplicationScreenBrightness(originalBrightness);
      }
    } catch (e) {
      debugPrint("Không thể trả lại độ sáng: $e");
    }
  }
}