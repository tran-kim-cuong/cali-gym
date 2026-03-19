import 'dart:async';

import 'package:californiaflutter/helpers/image_helper.dart';
import 'package:californiaflutter/helpers/session_manager.dart';
import 'package:californiaflutter/helpers/size_utils.dart';
import 'package:californiaflutter/pages/shared/common_notification.dart';
import 'package:californiaflutter/services/api_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:qr_flutter/qr_flutter.dart';

class CommonMembershipCard extends StatefulWidget {
  final Map<String, dynamic> data;
  final EdgeInsetsGeometry? margin;
  final Map<String, dynamic>? visualOverride;

  // Thêm 2 tham số này để quản lý trạng thái từ bên ngoài
  final bool isExpanded; // Thẻ này có đang mở QR không?
  final VoidCallback onToggle; // Hàm gọi khi bấm nút

  const CommonMembershipCard({
    super.key,
    required this.data,
    this.margin,
    this.visualOverride,
    required this.isExpanded,
    required this.onToggle,
    this.onQrClick,
    this.onClickToShare,
  });

  // Hàm này sẽ bắn chuỗi mã QR ra ngoài cho cha xử lý
  final Function(String qrData)? onQrClick;
  final Function? onClickToShare;

  @override
  State<CommonMembershipCard> createState() => _CommonMembershipCardState();
}

class _CommonMembershipCardState extends State<CommonMembershipCard> {
  Timer? _timer;
  static const int _cycleTime = 60;

  int _timeLeft = _cycleTime;
  String _qrData = "";

  bool _isShareCardOwnerSup = false;
  bool _isFloatingCard = false;
  bool _isCheckingFloatingTap = false;

  // Dữ liệu thẻ từ JSON
  String _cardImageUrl =
      'https://booking.cali.vn/storage/app/media/Cards/Default.png';
  Color _textColor = Colors.white;

  Color get _textColorDim => _textColor.withValues(alpha: 0.7);

  bool get _canShowQrByCardType {
    return !_isShareCardOwnerSup;
  }

  bool get _shouldShowActionButton {
    if (_isShareCardOwnerSup) return true;
    return _canShowQrByCardType;
  }

  @override
  void initState() {
    super.initState();
    _syncCardTypeFlags();
    _loadCardData();

    // Nếu khởi tạo mà đã mở sẵn thì chạy luôn (trường hợp hiếm)
    if (widget.isExpanded && _canShowQrByCardType) {
      _startQrSession();
    }
  }

  String _normalizedClassification() {
    return (widget.data['mbClassificationName'] ?? '')
        .toString()
        .trim()
        .toLowerCase();
  }

  void _syncCardTypeFlags() {
    final String classification = _normalizedClassification();
    final bool isOwner = widget.data['isOwner'] == true;

    _isShareCardOwnerSup = isOwner && classification.contains('supplementary');
    _isFloatingCard = classification.contains('floating');
  }

  Future<void> _loadCardData() async {
    await ImageHelper.initMembershipCards();
    final cardData =
        widget.visualOverride ??
        ImageHelper.getMembershipCardData(
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
    final hasVisualDataChanged =
        oldWidget.data['membershipType'] != widget.data['membershipType'] ||
        oldWidget.data['mbMembershipNameCard'] !=
            widget.data['mbMembershipNameCard'] ||
        oldWidget.visualOverride?['img'] != widget.visualOverride?['img'] ||
        oldWidget.visualOverride?['color'] != widget.visualOverride?['color'];
    final hasCardRuleChanged =
        oldWidget.data['mbClassificationName'] !=
            widget.data['mbClassificationName'] ||
        oldWidget.data['isOwner'] != widget.data['isOwner'];

    if (hasVisualDataChanged) {
      _loadCardData();
    }

    if (hasCardRuleChanged) {
      _syncCardTypeFlags();
      if (widget.isExpanded && !_canShowQrByCardType) {
        _stopQrSession();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && widget.isExpanded) {
            widget.onToggle();
          }
        });
      }
    }

    if (widget.isExpanded != oldWidget.isExpanded) {
      if (widget.isExpanded && _canShowQrByCardType) {
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
    if (!_canShowQrByCardType) return;

    _generateNewCode();
    _timer?.cancel();
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
      _qrData = createQRCheckIn(
        (widget.data['mbMembershipNumber'] ?? '').toString(),
        SessionManager.sKeyCode,
      );
      _timeLeft = _cycleTime;
    });
  }

  Future<void> _handleActionTap() async {
    if (_isShareCardOwnerSup) {
      widget.onClickToShare?.call();
      return;
    }

    if (!_isFloatingCard) {
      widget.onToggle();
      return;
    }

    if (_isCheckingFloatingTap) return;

    setState(() {
      _isCheckingFloatingTap = true;
    });

    final String membershipId =
        (widget.data['mbMembershipId'] ??
                widget.data['mbMembershipNumber'] ??
                '')
            .toString()
            .trim();
    final FloatingMembershipCheckResult checkResult =
        await checkFloatingMembershipForQr(membershipId);
    if (!mounted) return;

    setState(() {
      _isCheckingFloatingTap = false;
    });

    if (checkResult.canShowQr) {
      widget.onToggle();
      return;
    }

    final String displayName =
        (checkResult.fullName ?? widget.data['name'] ?? '')
            .toString()
            .trim()
            .isNotEmpty
        ? (checkResult.fullName ?? widget.data['name']).toString().trim()
        : 'member_card.msg_member_default_name'.tr();
    final String displayMembershipNumber =
        (checkResult.membershipNumber ??
                widget.data['mbMembershipNumber'] ??
                '')
            .toString()
            .trim();

    final String message = displayMembershipNumber.isNotEmpty
        ? 'member_card.msg_member_checked_in_with_code'.tr(
            args: [displayName, displayMembershipNumber],
          )
        : 'member_card.msg_member_checked_in'.tr(args: [displayName]);

    CommonNotification.show(context, message: message, isError: true);
  }

  @override
  Widget build(BuildContext context) {
    final _ = context.locale;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SvgPicture.asset(
                      "assets/images/CWG-Logo-White.svg",
                      height: 20,
                      fit: BoxFit.contain,
                      errorBuilder: (c, e, s) => const SizedBox(),
                    ),
                    if (widget.isExpanded && _canShowQrByCardType)
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

                widget.isExpanded && _canShowQrByCardType
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
        if (_shouldShowActionButton)
          InkWell(
            onTap: _isCheckingFloatingTap ? null : _handleActionTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: _textColor),
                borderRadius: BorderRadius.circular(6),
                color: _textColor.withValues(alpha: 0.1),
              ),
              child: _isCheckingFloatingTap
                  ? SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(_textColor),
                      ),
                    )
                  : Text(
                      !_isShareCardOwnerSup
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
