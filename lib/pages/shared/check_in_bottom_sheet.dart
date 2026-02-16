import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../models/schedule_model.dart';

class CheckInBottomSheet extends StatefulWidget {
  final ScheduleModel schedule;
  final Function(String clubCode)? onConfirm;

  const CheckInBottomSheet({super.key, required this.schedule, this.onConfirm});

  // Hàm static để gọi hiển thị nhanh từ bất kỳ đâu
  static void show(BuildContext context, ScheduleModel schedule) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor:
          Colors.transparent, // Để lộ bo góc của Container bên trong
      builder: (context) => CheckInBottomSheet(schedule: schedule),
    );
  }

  @override
  State<CheckInBottomSheet> createState() => _CheckInBottomSheetState();
}

class _CheckInBottomSheetState extends State<CheckInBottomSheet> {
  late TextEditingController _clubCodeController;
  MobileScannerController cameraController =
      MobileScannerController(); // Quản lý camera

  @override
  void initState() {
    super.initState();
    // Tự động điền mã câu lạc bộ từ dữ liệu lớp học
    _clubCodeController = TextEditingController(text: widget.schedule.clubCode);
  }

  @override
  void dispose() {
    _clubCodeController.dispose();
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: 24,
        bottom:
            MediaQuery.of(context).viewInsets.bottom +
            24, // Tránh bị bàn phím che
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1616), // Nền tối theo thiết kế
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Tiêu đề
          Text(
            'Quét mã QR để checkin',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),

          // 2. Vùng quét QR (Placeholder)
          Container(
            width: 180,
            height: 180,
            clipBehavior: Clip.antiAlias, //
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFD92229),
                width: 2,
              ), // Viền đỏ nổi bật
            ),
            child: MobileScanner(
              controller: cameraController,
              onDetect: (capture) {
                final List<Barcode> barcodes = capture.barcodes;
                if (barcodes.isNotEmpty) {
                  final String code = barcodes.first.rawValue ?? "";
                  debugPrint('Tìm thấy mã: $code');

                  setState(() {
                    _clubCodeController.text =
                        code; // Tự động điền mã quét được vào ô
                  });

                  // Có thể rung nhẹ để báo hiệu quét thành công (cần thêm plugin vibration)
                }
              },
            ),
          ),
          const SizedBox(height: 24),

          // 3. Input Mã câu lạc bộ
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _clubCodeController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Mã câu lạc bộ',
                labelStyle: const TextStyle(color: Color(0xFF9A9A9A)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFE8E8E8)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFD92229)),
                ),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 4. Nút Gửi hồ sơ (Check-in)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  if (widget.onConfirm != null) {
                    widget.onConfirm!(_clubCodeController.text);
                  }
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD92229), // Màu đỏ chủ đạo
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: const Text(
                  'Gửi hồ sơ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
