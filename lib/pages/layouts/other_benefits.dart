import 'package:californiaflutter/helpers/convert_model.dart';
import 'package:californiaflutter/helpers/session_manager.dart';
import 'package:californiaflutter/helpers/size_utils.dart';
import 'package:californiaflutter/models/member_model.dart';
import 'package:californiaflutter/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/svg.dart';

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
  final List<Map<String, dynamic>> _products = [
    {
      'id': 'towel_small',
      "code": "tsm",
      'name': 'Khăn nhỏ',
      'count': 1,
      'icon': 'assets/images/vuesax/towel-svgrepo-com 1.svg',
    },
    {
      'id': 'towel_large',
      "code": "txl",
      'name': 'Khăn to',
      'count': 1,
      'icon': 'assets/images/vuesax/towel-svgrepo-com 1.svg',
    },
    {
      'id': 'towel_set',
      "code": "set-1txl-1tsm",
      'name': 'Set khăn (1 to + 1 nhỏ)',
      'count': 0,
      'icon': 'assets/images/vuesax/towel-svgrepo-com 1.svg',
    },
    {
      'id': 'robe',
      "code": "coa",
      'name': 'Áo choàng',
      'count': 0,
      'icon': 'assets/images/vuesax/wear-svgrepo-com 1.svg',
    },
    {
      'id': 'shirt',
      "code": "vts",
      'name': 'Áo tập',
      'count': 0,
      'icon': 'assets/images/vuesax/wear-svgrepo-com 1.svg',
    },
    {
      'id': 'pants',
      "code": "vpa",
      'name': 'Quần tập',
      'count': 0,
      'icon': 'assets/images/vuesax/pant-pants-svgrepo-com 1.svg',
    },
    {
      'id': 'lock',
      "code": "lok",
      'name': 'Khoá',
      'count': 0,
      'icon': 'assets/images/vuesax/lock-svgrepo-com 1.svg',
    },
    {
      'id': 'vip',
      "code": "acc",
      'name': 'Thẻ ra vào khu vực VIP',
      'count': 0,
      'icon': 'assets/images/vuesax/card-svgrepo-com 1.svg',
    },
  ];

  void _updateCount(int index, int delta) {
    setState(() {
      int newVal = _products[index]['count'] + delta;
      if (newVal >= 0) _products[index]['count'] = newVal;
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
    }
  }

  // HÀM HIỂN THỊ CHỌN THẺ (BOTTOM SHEET) THEO SNIPPET
  void _showMemberCardsBottomSheet() {
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
                          'Chọn thẻ',
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
                      itemCount: _memberCards.length,
                      itemBuilder: (context, index) {
                        final card = _memberCards[index];
                        bool isCurrent = _selectedCard?['id'] == card['id'];

                        return InkWell(
                          onTap: () {
                            setState(() => _selectedCard = card);
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
          Positioned(
            left: -47,
            top: -33,
            child: Opacity(
              opacity: 0.12,
              child: Image.asset(
                "assets/images/backgound_benefit_v3_layer.png",
                width: context.resW(813),
                height: context.resH(789),
                fit: BoxFit.fill,
              ),
            ),
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
          Text(
            'Quyền lợi khác',
            style: TextStyle(
              color: Colors.white,
              fontSize: context.resClamp(18, 16, 22),
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              height: 1.5,
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
            'Thẻ hội viên',
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
            'Chọn sản phẩm',
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
              item['name'],
              item['count'],
              item['icon'],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildProductItem(int index, String name, int count, String svgPath) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.resH(8)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Hiển thị SVG trước tên
          SvgPicture.asset(
            svgPath,
            width: context.resW(24).clamp(20.0, 26.0),
            height: context.resW(24).clamp(20.0, 26.0),
            // Phủ màu trắng cho icon để nổi bật trên nền tối
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
          ),
          SizedBox(width: context.resW(12)),
          Expanded(
            child: Text(
              name,
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
          onPressed: () {
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
                SessionManager.sClientId +
                "flg2022towel" +
                result +
                milliseconds.toString();
            String sMd5 = generateMd5(sSecrect);

            //Link booking towel
            StringBuffer buffer = StringBuffer();
            buffer.write(dotenv.env["CALIFORNIA_URI"]);
            buffer.write("/fitlgbackend/fitlg/towel/towelorders/create?");
            buffer.write("c=${SessionManager.sClientId}");
            buffer.write("&ms=&p=${result}");
            buffer.write("&cn=${_msCard.membershipCardNumber}");
            buffer.write("&nc=${_msCard.membershipType}");
            buffer.write("&co=${_msCard.mbMemberId}");
            buffer.write("&io=${_msCard.isOwner}");
            buffer.write("&mb=${_msCard.membershipNumber}");
            buffer.write("&t=$milliseconds");
            buffer.write("&secrect=$sMd5");

            print(buffer.toString());
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFD92229),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            elevation: 0,
          ),
          child: Text(
            'Xác nhận',
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
