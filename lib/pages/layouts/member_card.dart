// import 'package:californiaflutter/helpers/session_manager.dart';
import 'package:californiaflutter/bases/app_session.dart';
import 'package:californiaflutter/bases/base_api.dart';
import 'package:californiaflutter/bases/loading_wrapper.dart';
import 'package:californiaflutter/bases/notification_mixin.dart';
import 'package:californiaflutter/helpers/convert_model.dart';
import 'package:californiaflutter/helpers/member_cache_manager.dart';
import 'package:californiaflutter/helpers/session_manager.dart';
import 'package:californiaflutter/models/member_model.dart';
import 'package:californiaflutter/helpers/size_utils.dart';
import 'package:californiaflutter/pages/shared/common_background.dart';
import 'package:californiaflutter/pages/shared/common_membership_card.dart';
import 'package:californiaflutter/pages/shared/common_modal.dart';
import 'package:californiaflutter/pages/widgets/common_user_share_card.dart';
import 'package:californiaflutter/providers/pinned_card_provider.dart';
import 'package:easy_localization/easy_localization.dart';
// import 'package:californiaflutter/pages/shared/language_bottom_sheet.dart';
// import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
// import 'package:qr_flutter/qr_flutter.dart';
// import 'package:screen_brightness/screen_brightness.dart';
// import 'package:flutter_svg/svg.dart';

class MemberListScreen extends StatefulWidget {
  final List<Map<String, dynamic>> cards;
  const MemberListScreen({super.key, required this.cards});

  @override
  State<MemberListScreen> createState() => _MemberListScreenState();
}

class _MemberListScreenState extends State<MemberListScreen>
    with LoadingWrapper, NotificationMixin {
  static const List<Map<String, String>> _leadingCardVisuals = [
    {
      'img': 'https://booking.cali.vn/storage/app/media/Cards/Gold Premium.png',
      'color': '#FDFDFD',
    },
    {
      'img':
          'https://booking.cali.vn/storage/app/media/Cards/Diamond X VIP Plus.png',
      'color': '#000000',
    },
    {
      'img':
          'https://booking.cali.vn/storage/app/media/Cards/Diamond X VIP.png',
      'color': '#FDFDFD',
    },
    {
      'img': 'https://booking.cali.vn/storage/app/media/Cards/Excelsior.png',
      'color': '#000000',
    },
    {
      'img':
          'https://booking.cali.vn/storage/app/media/Cards/Centuryon Charter.png',
      'color': '#FDFDFD',
    },
  ];

  String? _activeCardId;

  List<Map<String, dynamic>> _memberCards = [];
  Map<String, dynamic>? _latestMemberRaw;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _memberCards = buildMemberCards(SessionManager.member);
  }

  Future<void> _refreshMemberCards() async {
    if (_isRefreshing) return;
    _isRefreshing = true;
    try {
      final response = await BaseApi().client.post(
        '/api/booking/check/member',
        data: {
          'clientcode': AppSession().clientId,
          'phone_number': AppSession().phoneNumber,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final dynamic rawData = response.data['data'];
        if (rawData is Map) {
          _latestMemberRaw = Map<String, dynamic>.from(rawData);
          final member = MemberModel.fromJson(_latestMemberRaw!);
          if (mounted) {
            setState(() {
              AppSession().member = member;
              SessionManager.member = member;
              SessionManager.sTenKh = member.firstName ?? '';
              SessionManager.sMembershipNumber = member.membershipNumber ?? '';
              _memberCards = buildMemberCards(member);
            });
            await MemberCacheManager().saveMemberRaw(_latestMemberRaw!);
          }
          return;
        }
      }
      if (mounted) {
        showTopNotification('home.msg_refresh_use_cached'.tr(), isError: true);
      }
    } catch (e) {
      debugPrint('Lỗi làm mới thẻ hội viên: $e');
      if (mounted) {
        showTopNotification('home.msg_refresh_use_cached'.tr(), isError: true);
      }
    } finally {
      _isRefreshing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final double systemBottomPadding = MediaQuery.of(context).padding.bottom;
    // Chiều cao Navbar từ MasterScreen để tránh che khuất nội dung
    final double navBarHeight = context.resH(80);

    final _ = context.locale;

    // Sắp xếp thẻ theo pinned card
    final pinnedProvider = context.watch<PinnedCardProvider>();
    final sortedCards = pinnedProvider.sortCards(_memberCards);

    return Scaffold(
      backgroundColor: const Color(0xFF151515), // Color-Base-gray
      body: Stack(
        children: [
          // LỚP 1: BACKGROUND MỜ
          CommonBackgroundWidget.buildBackgroundImage(
            context,
            dotenv.get('IMAGES_BG_BENEFIT_V3_LAYER'),
          ),

          // LỚP 2: NỘI DUNG CHÍNH
          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // _buildHeader(context),

                // Tiêu đề màn hình
                Padding(
                  padding: EdgeInsets.only(
                    left: context.resW(8), // Giảm lề trái để Icon sát lề hơn
                    right: context.resW(20),
                    top: context.resH(12),
                    bottom: context.resH(12),
                  ),
                  child: Row(
                    children: [
                      // Nút mũi tên quay lại
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons
                              .arrow_back_ios_new, // Sử dụng icon ios cho đồng bộ thiết kế
                          color: Colors.white,
                          size: context.resW(20), // Responsive kích thước icon
                        ),
                      ),
                      // Tiêu đề văn bản
                      Text(
                        'member_card.title_member_card'.tr(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: context.resClamp(
                            18,
                            16,
                            22,
                          ), // Giữ nguyên font responsive của bạn
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: RefreshIndicator(
                    color: const Color(0xFFD92229),
                    backgroundColor: const Color(0xFF242424),
                    onRefresh: _refreshMemberCards,
                    child: ListView.builder(
                      padding: EdgeInsets.fromLTRB(
                        context.resW(20),
                        0,
                        context.resW(20),
                        navBarHeight + systemBottomPadding + 20,
                      ),
                      physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      ),
                      itemCount: sortedCards.length,
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            // CHỈ HIỂN THỊ GHIM THẺ Ở PHẦN TỬ ĐẦU TIÊN (Index 0)
                            if (index == 0) ...[
                              _buildPinSection(context),
                              SizedBox(height: context.resH(8)),
                            ],

                            // Hiển thị thẻ hội viên cho mọi index
                            _buildSingleMembershipCard(
                              context,
                              sortedCards[index],
                              index,
                            ),

                            // Khoảng cách giữa các thẻ
                            SizedBox(height: context.resH(24)),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPinSection(BuildContext context) {
    final pinnedProvider = context.watch<PinnedCardProvider>();
    final pinnedNumber = pinnedProvider.pinnedMembershipNumber;
    // Tìm tên thẻ đang ghim
    String? pinnedLabel;
    if (pinnedNumber != null) {
      final card = _memberCards.cast<Map<String, dynamic>?>().firstWhere(
        (c) => c!['membershipNumber'] == pinnedNumber,
        orElse: () => null,
      );
      if (card != null) {
        pinnedLabel = card['membershipType'] as String?;
      }
    }

    return GestureDetector(
      onTap: () => _showPinCardBottomSheet(context),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Icon(
                  pinnedProvider.hasPinnedCard
                      ? Icons.push_pin
                      : Icons.push_pin_outlined,
                  color: pinnedProvider.hasPinnedCard
                      ? const Color(0xFFE04A50)
                      : const Color(0xFFD1D5DB),
                  size: 18,
                ),
                SizedBox(width: context.resW(8)),
                Flexible(
                  child: Text(
                    pinnedLabel != null
                        ? '${'member_card.pinned'.tr()}: $pinnedLabel'
                        : 'member_card.pick_member_card'.tr(),
                    style: TextStyle(
                      color: pinnedProvider.hasPinnedCard
                          ? const Color(0xFFE04A50)
                          : const Color(0xFFD1D5DB),
                      fontSize: context.resClamp(14, 12, 16),
                      fontFamily: 'Inter',
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios,
            color: Color(0xFFD1D5DB),
            size: 14,
          ),
        ],
      ),
    );
  }

  void _showPinCardBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF151515),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        final pinnedProvider = context.read<PinnedCardProvider>();
        return _PinCardBottomSheetContent(
          memberCards: _memberCards,
          pinnedProvider: pinnedProvider,
        );
      },
    );
  }

  // Sửa lại hàm này: Chỉ nhận 1 dữ liệu thẻ và trả về 1 Widget CommonMembershipCard
  Widget _buildSingleMembershipCard(
    BuildContext context,
    Map<String, dynamic> data,
    int index,
  ) {
    final String uniqueKey = "${index}_${data['id']}";
    // debugPrint(data.toString());
    return CommonMembershipCard(
      data: data,
      visualOverride: index < _leadingCardVisuals.length
          ? _leadingCardVisuals[index]
          : null,
      // Quản lý trạng thái mở mã QR từ biến _activeCardId của màn hình
      isExpanded: _activeCardId == uniqueKey,
      onToggle: () => setState(() {
        _activeCardId = (_activeCardId == uniqueKey ? null : uniqueKey);
      }),
      onQrClick: (qrData) {
        // Logic hiển thị QR lớn nếu cần
        // _showBigQrModal(context, qrData);
        CommonModalWidget.showBigQrModal(context: context, qrData: qrData);
      },
      onClickToShare: () {
        CommonUserShareCardWidget.show(
          context: context,
          membershipNumber: data['membershipNumber'],
        );
      },
    );
  }
}

/// Bottom sheet widget cho chọn thẻ ghim - tách riêng để quản lý state cục bộ
class _PinCardBottomSheetContent extends StatefulWidget {
  final List<Map<String, dynamic>> memberCards;
  final PinnedCardProvider pinnedProvider;

  const _PinCardBottomSheetContent({
    required this.memberCards,
    required this.pinnedProvider,
  });

  @override
  State<_PinCardBottomSheetContent> createState() =>
      _PinCardBottomSheetContentState();
}

class _PinCardBottomSheetContentState
    extends State<_PinCardBottomSheetContent> {
  String? _selectedNumber;

  @override
  void initState() {
    super.initState();
    _selectedNumber = widget.pinnedProvider.pinnedMembershipNumber;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: context.resH(8), bottom: context.resH(20)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: context.resW(20),
              vertical: context.resH(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'member_card.select_pin_card'.tr(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: context.resClamp(16, 14, 18),
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, color: Colors.white, size: 24),
                ),
              ],
            ),
          ),
          // Danh sách thẻ
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: widget.memberCards.length,
              itemBuilder: (context, index) {
                final card = widget.memberCards[index];
                final membershipNumber =
                    card['membershipNumber'] as String? ?? '';
                final isPinned = _selectedNumber == membershipNumber;

                return InkWell(
                  onTap: () {
                    setState(() {
                      // Toggle: nếu đang chọn thì bỏ ghim, ngược lại ghim thẻ mới
                      if (isPinned) {
                        _selectedNumber = null;
                        widget.pinnedProvider.unpinCard();
                      } else {
                        _selectedNumber = membershipNumber;
                        widget.pinnedProvider.pinCard(membershipNumber);
                      }
                    });
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: context.resW(20),
                      vertical: context.resH(12),
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.white.withValues(alpha: 0.05),
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              card['membershipType'] ?? '',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: context.resClamp(14, 12, 16),
                                fontFamily: 'Inter',
                              ),
                            ),
                            Text(
                              membershipNumber,
                              style: TextStyle(
                                color: const Color(0xFF9A9A9A),
                                fontSize: context.resClamp(12, 10, 14),
                                fontFamily: 'Inter',
                              ),
                            ),
                          ],
                        ),
                        // Icon ghim
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFF6B6B6B)),
                            color: isPinned
                                ? const Color(0xFFE04A50)
                                : Colors.transparent,
                          ),
                          child: isPinned
                              ? const Icon(
                                  Icons.push_pin,
                                  size: 14,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
