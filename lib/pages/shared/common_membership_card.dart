import 'dart:async';
// import 'package:californiaflutter/bases/app_session.dart';
import 'package:californiaflutter/helpers/image_helper.dart';
import 'package:californiaflutter/helpers/session_manager.dart';
import 'package:californiaflutter/helpers/size_utils.dart';
import 'package:californiaflutter/services/api_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
    this.onClickToShare,
  });

  // --- THÊM DÒNG NÀY ---
  // Hàm này sẽ bắn chuỗi mã QR ra ngoài cho cha xử lý
  final Function(String qrData)? onQrClick;
  final Function? onClickToShare;

  @override
  State<CommonMembershipCard> createState() => _CommonMembershipCardState();
}

class _CommonMembershipCardState extends State<CommonMembershipCard> {
  Timer? _timer; // Dùng ? để có thể null
  static const int _cycleTime = 60;
  int _timeLeft = _cycleTime;
  String _qrData = "";

  bool isShareCard = false;
  String defaultSupplementary = "Supplementary Card";

  // Dữ liệu thẻ từ JSON
  String _cardImageUrl =
      'https://booking.cali.vn/storage/app/media/Cards/Default.png';
  Color _textColor = Colors.white;

  Color get _textColorDim => _textColor.withValues(alpha: 0.7);

  @override
  void initState() {
    super.initState();
    debugPrint("isOwner ${widget.data['isOwner']}");
    if (widget.data['isOwner'] == true &&
        defaultSupplementary == widget.data['mbClassificationName']) {
      isShareCard = true;
    }
    _loadCardData();

    // Nếu khởi tạo mà đã mở sẵn thì chạy luôn (trường hợp hiếm)
    if (widget.isExpanded) {
      _startQrSession();
    }
  }

  Future<void> _loadCardData() async {
    await ImageHelper.initMembershipCards();
    final cardData = ImageHelper.getMembershipCardData(
      membershipType: widget.data['membershipType'] as String?,
      membershipNameCard: widget.data['mbMembershipNameCard'] as String?,
    );
    if (!mounted || cardData == null) return;
    final colorHex = (cardData['color'] as String).replaceAll('#', '');
    final fullHex = colorHex.length == 6 ? 'FF$colorHex' : colorHex;
    setState(() {
      _cardImageUrl = cardData['img'] as String;
      _textColor = Color(int.parse(fullHex, radix: 16));
    });
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
      //Tạo QR Code
      // print(widget.data);
      _qrData = createQRCheckIn(
        widget.data['mbMembershipNumber'],
        SessionManager.sKeyCode,
      );
      //print(_qrData);
      // _qrData = "${widget.data['id']}_${DateTime.now().millisecondsSinceEpoch}";
      _timeLeft = _cycleTime;
    });
  }

  @override
  Widget build(BuildContext context) {
    final _ = context
        .locale; // THÊM DÒNG NÀY: Ép widget lắng nghe sự thay đổi của locale
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300), // Hiệu ứng co giãn mượt mà
      width: double.infinity,
      height: 220,
      margin:
          widget.margin ??
          const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(
          image: CachedNetworkImageProvider(_cardImageUrl),
          fit: BoxFit.cover,
        ),
        // gradient: LinearGradient(
        //   begin: const Alignment(0.95, 0.86),
        //   end: const Alignment(0.04, -0.04),
        //   colors:
        //       widget.data['colors'] ??
        //       [const Color(0xFF574E4C), const Color(0xFF231E1D)],
        // ),
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
          // Positioned(
          //   right: -30,
          //   bottom: -30,
          //   child: Opacity(
          //     opacity: 0.05,
          //     child: const Icon(
          //       Icons.fitness_center,
          //       size: 200,
          //       color: Colors.white,
          //     ),
          //   ),
          // ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Logo
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SvgPicture.asset(
                      "assets/images/CWG-Logo-White.svg",
                      height: 20,
                      fit: BoxFit.contain,
                      errorBuilder: (c, e, s) => const SizedBox(),
                    ),
                    // Nút đóng nhanh nếu đang mở (Optional)
                    if (widget.isExpanded)
                      GestureDetector(
                        onTap: widget.onToggle,
                        child: Icon(
                          Icons.close,
                          color: _textColorDim,
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
          onTap: () {
            if (isShareCard) {
              // GỌI HÀM CHIA SẺ Ở MÀN HÌNH CHA
              widget.onClickToShare?.call();
            } else {
              // GỌI HÀM MỞ QR
              widget.onToggle();
            }
          }, // Gọi hàm toggle của cha
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: _textColor),
              borderRadius: BorderRadius.circular(6),
              color: _textColor.withValues(alpha: 0.1),
            ),
            child: Text(
              !isShareCard
                  ? "member_card.btn_show_qr".tr()
                  : "member_card.btn_share_card_title".tr(),
              style: TextStyle(
                color: _textColor,
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
              style: TextStyle(
                color: _textColor,
                fontSize: context.resClamp(16, 14, 18),
                fontWeight: FontWeight.bold,
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
          style: TextStyle(
            color: _textColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          widget.data['id'] ?? '',
          style: TextStyle(color: _textColor, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Text(
          widget.data['mbMembershipNameCard'] ?? '',
          style: TextStyle(color: _textColorDim, fontSize: 12),
        ),
        const SizedBox(height: 8),
        Text(
          '${'member_card.expire_date'.tr()}${widget.data['expiry']}',
          style: TextStyle(color: _textColorDim, fontSize: 12),
        ),
      ],
    );
  }
}
