import 'package:californiaflutter/helpers/convert_model.dart';
import 'package:californiaflutter/helpers/session_manager.dart';
import 'package:californiaflutter/helpers/size_utils.dart';
import 'package:californiaflutter/models/member_model.dart';
import 'package:californiaflutter/pages/layouts/towel_orders.dart';
import 'package:californiaflutter/pages/shared/common_background.dart';
import 'package:californiaflutter/pages/shared/common_modal.dart';
import 'package:californiaflutter/providers/pinned_card_provider.dart';
import 'package:californiaflutter/services/api_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

class OtherBenefitsScreen extends StatefulWidget {
  const OtherBenefitsScreen({super.key});

  @override
  State<OtherBenefitsScreen> createState() => _OtherBenefitsScreenState();
}

class _OtherBenefitsScreenState extends State<OtherBenefitsScreen> {
  // QUẢN LÝ DỮ LIỆU THẺ
  List<Map<String, dynamic>> _memberCards = [];
  Map<String, dynamic>? _selectedCard;
  MembershipCard _msCard = MembershipCard();

  // 1. QUẢN LÝ DANH SÁCH SẢN PHẨM (Dễ dàng đấu nối API)

  final List<Map<String, dynamic>> _allProducts = [
    {
      'id': 'towel_small',
      "code": "tsm",
      'nameKey': 'other_benefits.product_towel_small',
      'count': 0,
      'icon': 'assets/images/vuesax/ic_towel.png',
    },
    {
      'id': 'towel_large',
      "code": "txl",
      'nameKey': 'other_benefits.product_towel_large',
      'count': 0,
      'icon': 'assets/images/vuesax/ic_towel.png',
    },
    {
      'id': 'towel_set',
      "code": "set-1txl-1tsm",
      'nameKey': 'other_benefits.product_towel_set',
      'count': 0,
      'icon': 'assets/images/vuesax/ic_towel.png',
    },
    {
      'id': 'robe',
      "code": "coa",
      'nameKey': 'other_benefits.product_robe',
      'count': 0,
      'icon': 'assets/images/vuesax/ic_robe.png',
    },
    {
      'id': 'shirt',
      "code": "vts",
      'nameKey': 'other_benefits.product_shirt',
      'count': 0,
      'icon': 'assets/images/vuesax/ic_shirt.png',
    },
    {
      'id': 'pants',
      "code": "vpa",
      'nameKey': 'other_benefits.product_pants',
      'count': 0,
      'icon': 'assets/images/vuesax/ic_pants.png',
    },
    {
      'id': 'lock',
      "code": "lok",
      'nameKey': 'other_benefits.product_lock',
      'count': 0,
      'icon': 'assets/images/vuesax/ic_lock.png',
    },
    {
      'id': 'vip',
      "code": "acc",
      'nameKey': 'other_benefits.product_vip_access_card',
      'count': 0,
      'icon': 'assets/images/vuesax/ic_vip_card.png',
    },
  ];
  List<Map<String, dynamic>> _products = [];

  void _updateCount(int index, int delta) {
    setState(() {
      int newVal = _products[index]['count'] + delta;
      if (newVal >= 0 && newVal <= 1) _products[index]['count'] = newVal;
    });
  }

  @override
  void initState() {
    super.initState();
    // Khởi tạo danh sách thẻ từ MemberModel
    _memberCards = buildMemberCards(SessionManager.member);
    if (_memberCards.isNotEmpty) {
      _selectedCard = _memberCards[0];
      _msCard = SessionManager.member.listMembershipCard![0];
      getProductByCard();
    }
  }

  void getProductByCard() {
    _products = _allProducts
        .where(
          (item) =>
              _selectedCard?['benefitMember'].split(',').contains(item['code']),
        )
        .toList();
  }

  bool _isSelectedMemberCard(Map<String, dynamic> card) {
    return _selectedCard?['membershipNumber'] == card['membershipNumber'] &&
        _selectedCard?['membershipType'] == card['membershipType'];
  }

  bool get _hasSelectedProducts =>
      _products.any((item) => (item['count'] as int) > 0);

  // HÀM HIỂN THỊ CHỌN THẺ (BOTTOM SHEET) THEO SNIPPET
  void _showMemberCardsBottomSheet() {
    final pinnedProvider = context.read<PinnedCardProvider>();
    final sortedCards = pinnedProvider.sortCards(_memberCards);

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF151515),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                top: context.resH(8),
                bottom: context.resH(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header của Bottom Sheet
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.resW(20),
                      vertical: context.resH(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'other_benefits.select_card'.tr(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: context.resClamp(16, 14, 18),
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Danh sách thẻ
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: sortedCards.length,
                      itemBuilder: (context, index) {
                        final card = sortedCards[index];
                        final isCurrent = _isSelectedMemberCard(card);
                        // Tìm index gốc trong _memberCards để map đúng listMembershipCard
                        final originalIndex = _memberCards.indexWhere(
                          (c) =>
                              c['membershipNumber'] == card['membershipNumber'],
                        );

                        return InkWell(
                          onTap: () {
                            setState(() {
                              _selectedCard = card;
                              _msCard = SessionManager
                                  .member
                                  .listMembershipCard![originalIndex];
                              getProductByCard();
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
                                      card['membershipNumber'] ?? '',
                                      style: TextStyle(
                                        color: const Color(0xFF9A9A9A),
                                        fontSize: context.resClamp(12, 10, 14),
                                        fontFamily: 'Inter',
                                      ),
                                    ),
                                  ],
                                ),
                                // Vòng tròn check chọn thẻ
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: const Color(0xFF6B6B6B),
                                    ),
                                    color: isCurrent
                                        ? const Color(0xFFE04A50)
                                        : Colors.transparent,
                                  ),
                                  child: isCurrent
                                      ? const Icon(
                                          Icons.check,
                                          size: 16,
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
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF151515),
      body: Stack(
        children: [
          // LỚP 1: BACKGROUND IMAGE THEO SNIPPET (OPACITY 12%)
          CommonBackgroundWidget.buildBackgroundImage(
            context,
            dotenv.get('IMAGES_BG_BENEFIT_V3_LAYER'),
          ),

          // LỚP 2: NỘI DUNG CHÍNH
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.only(bottom: context.resH(20)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildMembershipSection(),
                        _buildProductSection(),
                      ],
                    ),
                  ),
                ),
                _buildBottomAction(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- 1. Header: Tiêu đề và nút quay lại ---
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(top: 4, left: 8, right: 20, bottom: 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Text(
              'home.fnc_other_benefit'.tr(),
              style: TextStyle(
                color: Colors.white,
                fontSize: context.resClamp(18, 16, 22),
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                height: 1.5,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TowelOrdersScreen()),
              );
            },
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: context.resW(10),
                vertical: context.resH(6),
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF242424),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'towel_orders.btn_my_orders'.tr(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: context.resClamp(12, 10, 14),
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- 2. Thẻ hội viên (Membership Section) ---
  Widget _buildMembershipSection() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.resW(20),
        vertical: context.resH(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'home.section_member_card'.tr(),
            style: TextStyle(
              color: Colors.white,
              fontSize: context.resClamp(14, 12, 16),
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: context.resH(12)),
          GestureDetector(
            onTap: _showMemberCardsBottomSheet, // CLICK ĐỂ MỞ DANH SÁCH THẺ
            child: Container(
              width: double.infinity,
              height: context.resH(56),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: ShapeDecoration(
                color: const Color(0xFF242424),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedCard?['membershipType'] ?? 'Gold',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: context.resClamp(14, 12, 16),
                          fontFamily: 'Inter',
                        ),
                      ),
                      Text(
                        _selectedCard?['membershipNumber'] ?? 'S0100958',
                        style: TextStyle(
                          color: const Color(0xFF9A9A9A),
                          fontSize: context.resClamp(12, 10, 14),
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                  const Icon(
                    Icons.arrow_drop_down,
                    color: Color(0xFFD9D9D9),
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- 3. Danh sách chọn sản phẩm ---
  Widget _buildProductSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.resW(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'other_benefits.select_product'.tr(),
            style: TextStyle(
              color: Colors.white,
              fontSize: context.resClamp(14, 12, 16),
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: context.resH(8)),
          // Tự động render list sản phẩm
          ...List.generate(_products.length, (index) {
            final item = _products[index];
            return _buildProductItem(
              index,
              item['nameKey'],
              item['count'],
              item['icon'],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildProductItem(
    int index,
    String nameKey,
    int count,
    String iconPath,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.resH(8)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset(
            iconPath,
            width: context.resW(24).clamp(20.0, 26.0),
            height: context.resW(24).clamp(20.0, 26.0),
          ),
          SizedBox(width: context.resW(12)),
          Expanded(
            child: Text(
              nameKey.tr(),
              style: TextStyle(
                color: Colors.white,
                fontSize: context.resClamp(14, 12, 16),
                fontFamily: 'Inter',
                height: 1.5,
              ),
            ),
          ),
          Row(
            children: [
              _buildQtyBtn(Icons.remove, () => _updateCount(index, -1)),
              Container(
                width: context.resW(40),
                alignment: Alignment.center,
                child: Text(
                  '$count',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: context.resClamp(14, 12, 16),
                    fontFamily: 'Inter',
                  ),
                ),
              ),
              _buildQtyBtn(Icons.add, () => _updateCount(index, 1)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQtyBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: const Color(0xFF3E3E3E),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(icon, color: Colors.white, size: 16),
      ),
    );
  }

  // --- 4. Nút Xác nhận ở dưới đáy ---
  Widget _buildBottomAction() {
    final hasSelectedProducts = _hasSelectedProducts;

    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        MediaQuery.of(context).padding.bottom + 12,
      ),
      child: SizedBox(
        width: double.infinity,
        height: context.resH(48).clamp(44, 56),
        child: ElevatedButton(
          onPressed: hasSelectedProducts
              ? () {
                  // Xử lý xác nhận quyền lợi
                  List<Map<String, dynamic>> selectedProducts = _products
                      .where((item) => item['count'] > 0)
                      .toList();
                  String result = selectedProducts
                      .map((item) => "${item['count']}${item['code']}")
                      .join("-");

                  int milliseconds = DateTime.now()
                      .add(Duration(hours: 7))
                      .millisecondsSinceEpoch;

                  String sSecrect =
                      "${SessionManager.sClientId}flg2022towel$result$milliseconds";
                  String sMd5 = generateMd5(sSecrect);

                  //Link booking towel
                  StringBuffer buffer = StringBuffer();
                  buffer.write(dotenv.env["CALIFORNIA_URI"]);
                  buffer.write("/fitlgbackend/fitlg/towel/towelorders/create?");
                  buffer.write("c=${SessionManager.sClientId}");
                  buffer.write("&ms=&p=$result");
                  buffer.write("&cn=${_msCard.membershipCardNumber}");
                  buffer.write("&nc=${_msCard.membershipType}");
                  buffer.write("&co=${_msCard.mbMemberId}");
                  buffer.write("&io=${_msCard.isOwner}");
                  buffer.write("&mb=${_msCard.membershipNumber}");
                  buffer.write("&t=$milliseconds");
                  buffer.write("&secrect=$sMd5");

                  debugPrint(buffer.toString());

                  CommonModalWidget.showBigQrModal(
                    context: context,
                    qrData: buffer.toString(),
                    instructionText: 'other_benefits.qr_instruction'.tr(),
                    closeButtonText: 'other_benefits.btn_close'.tr(),
                  );
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFD92229),
            disabledBackgroundColor: Colors.grey,
            disabledForegroundColor: Colors.white.withValues(alpha: 0.6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            elevation: 0,
          ),
          child: Text(
            'common.accept'.tr(),
            style: TextStyle(
              color: Colors.white,
              fontSize: context.resClamp(16, 14, 18),
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
