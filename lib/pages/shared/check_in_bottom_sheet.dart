import 'package:californiaflutter/helpers/size_utils.dart';
import 'package:californiaflutter/models/booking_class_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class CheckInBottomSheet extends StatefulWidget {
  final BookingData schedule;
  final Function(String qrCode)? onScanned;

  const CheckInBottomSheet({super.key, required this.schedule, this.onScanned});

  // Hàm static để gọi hiển thị nhanh từ bất kỳ đâu
  static void show(
    BuildContext context,
    BookingData schedule, {
    Function(String)? onScanned,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          CheckInBottomSheet(schedule: schedule, onScanned: onScanned),
    );
  }

  @override
  State<CheckInBottomSheet> createState() => _CheckInBottomSheetState();
}

class _CheckInBottomSheetState extends State<CheckInBottomSheet> {
  MobileScannerController cameraController = MobileScannerController();
  bool _hasScanned = false;
  bool _isScanReady = false;

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double systemBottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: context.resH(16),
        left: context.resW(20),
        right: context.resW(20),
        bottom: systemBottomPadding + context.resH(24),
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF3E3E3E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          SizedBox(height: context.resH(20)),

          // Camera QR scanner
          Stack(
            alignment: Alignment.center,
            children: [
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
                    if (_hasScanned || !_isScanReady) return;
                    final List<Barcode> barcodes = capture.barcodes;
                    if (barcodes.isNotEmpty) {
                      final String? code = barcodes.first.rawValue;
                      if (code != null && code.isNotEmpty) {
                        _hasScanned = true;
                        _isScanReady = false;
                        if (mounted) Navigator.pop(context);
                        if (widget.onScanned != null) {
                          widget.onScanned!(code);
                        }
                      }
                    }
                  },
                ),
              ),
              _buildScannerOverlay(),
            ],
          ),
          SizedBox(height: context.resH(20)),
          _buildCaptureButton(),
          SizedBox(height: context.resH(4)),
        ],
      ),
    );
  }

  Widget _buildCaptureButton() {
    return GestureDetector(
      onTap: (_hasScanned || _isScanReady)
          ? null
          : () {
              setState(() => _isScanReady = true);
              Future.delayed(const Duration(seconds: 3), () {
                if (mounted && !_hasScanned) {
                  setState(() => _isScanReady = false);
                }
              });
            },
      child: Container(
        width: context.resW(240).clamp(200.0, 300.0),
        height: context.resH(50),
        decoration: BoxDecoration(
          color: _isScanReady
              ? const Color(0xFFD92229).withValues(alpha: 0.6)
              : const Color(0xFFD92229),
          borderRadius: BorderRadius.circular(24),
        ),
        alignment: Alignment.center,
        child: _isScanReady
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Text(
                'common.tap_to_scan'.tr(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: context.resClamp(15, 13, 17),
                  fontWeight: FontWeight.w600,
                ),
              ),
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
          'common.scan_qr_to_checkin'.tr(),
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
}
