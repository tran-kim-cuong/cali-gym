import 'dart:async';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class CommonMembershipCard extends StatefulWidget {
  final Map<String, dynamic> data;
  final EdgeInsetsGeometry? margin;

  // Thêm 2 tham số này để quản lý trạng thái từ bên ngoài
  final bool isExpanded; // Thẻ này có đang mở QR không?
  final VoidCallback onToggle; // Hàm gọi khi bấm nút

  const CommonMembershipCard({
    super.key,
    required this.data,
    this.margin,
    required this.isExpanded,
    required this.onToggle,
    this.onQrClick, // --- THÊM DÒNG NÀY ---
  });

  // --- THÊM DÒNG NÀY ---
  // Hàm này sẽ bắn chuỗi mã QR ra ngoài cho cha xử lý
  final Function(String qrData)? onQrClick;

  @override
  State<CommonMembershipCard> createState() => _CommonMembershipCardState();
}

class _CommonMembershipCardState extends State<CommonMembershipCard> {
  Timer? _timer; // Dùng ? để có thể null
  static const int _cycleTime = 60;
  int _timeLeft = _cycleTime;
  String _qrData = "";

  @override
  void initState() {
    super.initState();
    // Nếu khởi tạo mà đã mở sẵn thì chạy luôn (trường hợp hiếm)
    if (widget.isExpanded) {
      _startQrSession();
    }
  }

  // Hàm này quan trọng: Lắng nghe khi cha thay đổi trạng thái isExpanded
  @override
  void didUpdateWidget(covariant CommonMembershipCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded != oldWidget.isExpanded) {
      if (widget.isExpanded) {
        _startQrSession(); // Mở -> Bắt đầu tạo mã và đếm
      } else {
        _stopQrSession(); // Đóng -> Dừng đếm
      }
    }
  }

  @override
  void dispose() {
    _stopQrSession();
    super.dispose();
  }

  void _startQrSession() {
    _generateNewCode();
    _timer?.cancel(); // Hủy timer cũ nếu có
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_timeLeft > 0) {
        setState(() => _timeLeft--);
      } else {
        _generateNewCode();
      }
    });
  }

  void _stopQrSession() {
    _timer?.cancel();
    _timer = null;
  }

  void _generateNewCode() {
    if (!mounted) return;
    setState(() {
      _qrData = "${widget.data['id']}_${DateTime.now().millisecondsSinceEpoch}";
      _timeLeft = _cycleTime;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300), // Hiệu ứng co giãn mượt mà
      width: double.infinity,
      height: 220,
      margin:
          widget.margin ??
          const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: const Alignment(0.95, 0.86),
          end: const Alignment(0.04, -0.04),
          colors:
              widget.data['colors'] ??
              [const Color(0xFF574E4C), const Color(0xFF231E1D)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Watermark icon
          Positioned(
            right: -30,
            bottom: -30,
            child: Opacity(
              opacity: 0.1,
              child: const Icon(
                Icons.fitness_center,
                size: 200,
                color: Colors.white,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Logo
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset(
                      "assets/images/logo.png",
                      height: 20,
                      fit: BoxFit.contain,
                      color: Colors.white,
                      errorBuilder: (c, e, s) => const SizedBox(),
                    ),
                    // Nút đóng nhanh nếu đang mở (Optional)
                    if (widget.isExpanded)
                      GestureDetector(
                        onTap: widget.onToggle,
                        child: const Icon(
                          Icons.close,
                          color: Colors.white70,
                          size: 20,
                        ),
                      ),
                  ],
                ),

                const Spacer(),

                // === PHẦN LOGIC GIAO DIỆN ===
                // Nếu đang MỞ -> Layout Hàng Ngang (Info + QR)
                // Nếu đang ĐÓNG -> Layout Cột (Info + Nút Bấm)
                widget.isExpanded
                    ? _buildExpandedLayout()
                    : _buildCollapsedLayout(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Giao diện khi chưa bấm (Hiện nút)
  Widget _buildCollapsedLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(child: _buildInfoColumn()),
        InkWell(
          onTap: widget.onToggle, // Gọi hàm toggle của cha
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white),
              borderRadius: BorderRadius.circular(6),
              color: Colors.white.withValues(alpha: 0.1),
            ),
            child: const Text(
              "Hiển thị mã QR",
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Giao diện khi đã bấm (Hiện QR + Timer)
  Widget _buildExpandedLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(child: _buildInfoColumn()),
        const SizedBox(width: 10),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "00:${_timeLeft.toString().padLeft(2, '0')}s",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 8),

            // --- SỬA ĐOẠN NÀY ---
            GestureDetector(
              onTap: () {
                // Nếu cha có truyền hàm xử lý thì gọi hàm đó và gửi kèm mã QR hiện tại
                if (widget.onQrClick != null) {
                  widget.onQrClick!(_qrData);
                }
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: QrImageView(
                  data: _qrData,
                  version: QrVersions.auto,
                  size: 80.0,
                  padding: EdgeInsets.zero,
                  backgroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Widget hiển thị thông tin text (Dùng chung cho cả 2 trạng thái)
  Widget _buildInfoColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.data['name']?.toString().toUpperCase() ?? '',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          widget.data['id'] ?? '',
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Text(
          'Ngày hết hạn: ${widget.data['expiry']}',
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }
}
