import 'package:californiaflutter/helpers/size_utils.dart';
import 'package:californiaflutter/models/booking_class_model.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class CheckInBottomSheet extends StatefulWidget {
  final BookingData schedule;
  final Function(String clubCode)? onConfirm;
  final Function(String qrCode)? onScanned;

  const CheckInBottomSheet({
    super.key,
    required this.schedule,
    this.onConfirm,
    this.onScanned,
  });

  // Hàm static để gọi hiển thị nhanh từ bất kỳ đâu
  static void show(
    BuildContext context,
    BookingData schedule, {
    Function(String)? onConfirm,
    Function(String)? onScanned,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor:
          Colors.transparent, // Để lộ bo góc của Container bên trong
      builder: (context) => CheckInBottomSheet(
        schedule: schedule,
        onConfirm: onConfirm,
        onScanned: onScanned,
      ), // Truyền function vào widget),
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
    final double systemBottomPadding = MediaQuery.of(context).padding.bottom;
    final bool isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: context.resH(16),
        left: context.resW(20),
        right: context.resW(20),
        bottom: isKeyboardOpen
            ? MediaQuery.of(context).viewInsets.bottom + context.resH(16)
            : systemBottomPadding + context.resH(24),
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF3E3E3E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header (Tiêu đề + Nút X)
          _buildHeader(),
          SizedBox(height: context.resH(20)),

          // PHẦN QUÉT QR: SỬ DỤNG STACK ĐỂ KHUNG KHÔNG BỊ CẮT
          Stack(
            alignment: Alignment.center,
            children: [
              // 1. Lớp Camera (Bọc trong Container bo góc nhưng KHÔNG để border ở đây)
              Container(
                width: context.resW(240).clamp(200.0, 300.0),
                height: context.resW(200).clamp(160.0, 260.0),
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: MobileScanner(
                  controller: cameraController,
                  onDetect: (capture) {
                    final List<Barcode> barcodes = capture.barcodes;
                    if (barcodes.isNotEmpty) {
                      final String? code = barcodes.first.rawValue;
                      if (code != null && code.isNotEmpty) {
                        // 1. Cập nhật UI input
                        _clubCodeController.text = code;

                        // 2. KÍCH HOẠT FUNCTION XỬ LÝ API NGAY LẬP TỨC
                        if (widget.onScanned != null) {
                          widget.onScanned!(code);
                        }
                      }
                    }
                  },
                ),
              ),

              // 2. Lớp Khung Viền Đỏ (Nằm đè lên trên, đảm bảo không bị Clip)
              _buildScannerOverlay(),
            ],
          ),

          SizedBox(height: context.resH(24)),

          // Row Input + Button
          _buildInputRow(),
        ],
      ),
    );
  }

  // Hàm vẽ khung quét (Viewfinder) với các góc Brackets
  Widget _buildScannerOverlay() {
    return SizedBox(
      width: context.resW(200), // Nhỏ hơn vùng camera một chút
      height: context.resW(160),
      child: Stack(
        children: [
          // Vẽ 4 góc khung đỏ/trắng theo thiết kế
          Positioned(
            top: 0,
            left: 0,
            child: _cornerBracket(top: true, left: true),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: _cornerBracket(top: true, left: false),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            child: _cornerBracket(top: false, left: true),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: _cornerBracket(top: false, left: false),
          ),
        ],
      ),
    );
  }

  // Widget tạo hình góc bracket
  Widget _cornerBracket({required bool top, required bool left}) {
    const double size = 20.0;
    const double thickness = 3.0;
    const Color bracketColor = Color(0xFFD92229); // Màu đỏ brand

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        border: Border(
          top: top
              ? const BorderSide(color: bracketColor, width: thickness)
              : BorderSide.none,
          bottom: !top
              ? const BorderSide(color: bracketColor, width: thickness)
              : BorderSide.none,
          left: left
              ? const BorderSide(color: bracketColor, width: thickness)
              : BorderSide.none,
          right: !left
              ? const BorderSide(color: bracketColor, width: thickness)
              : BorderSide.none,
        ),
      ),
    );
  }

  // --- Các hàm phụ trợ giúp code sạch hơn ---
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const SizedBox(width: 32),
        Text(
          'Quét mã QR để checkin',
          style: TextStyle(
            color: Colors.white,
            fontSize: context.resClamp(16, 14, 18),
            fontWeight: FontWeight.w600,
          ),
        ),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close, color: Color(0xFF9A9A9A), size: 24),
        ),
      ],
    );
  }

  Widget _buildInputRow() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              controller: _clubCodeController,
              style: const TextStyle(color: Colors.black),
              decoration: const InputDecoration(
                hintText: 'Mã câu lạc bộ',
                hintStyle: TextStyle(color: Color(0xFF9A9A9A)),
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
                border: InputBorder.none,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          height: 48,
          child: ElevatedButton(
            onPressed: () {
              if (widget.onConfirm != null) {
                widget.onConfirm!(_clubCodeController.text);
              }
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD92229),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            child: const Text(
              'Gửi hồ sơ',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
