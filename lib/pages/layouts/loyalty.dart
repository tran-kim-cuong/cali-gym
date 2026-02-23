import 'package:californiaflutter/helpers/size_utils.dart';
// import 'package:californiaflutter/pages/shared/common_bottom_nav_bar.dart';
import 'package:californiaflutter/pages/shared/common_point_badge.dart';
import 'package:flutter/material.dart';

class LoyaltyScreen extends StatefulWidget {
  const LoyaltyScreen({super.key});

  @override
  State<LoyaltyScreen> createState() => _LoyaltyScreenState();
}

class _LoyaltyScreenState extends State<LoyaltyScreen> {
  // int _selectedIndex = 2;

  // 1. MẢNG DỮ LIỆU MẪU (Dễ dàng thay thế bằng API sau này)
  final List<Map<String, dynamic>> _energyProducts = [
    {
      'name': 'Sinh tố dâu tây mát lạnh',
      'points': '500',
      'image': 'assets/images/loyalty/sinh_to_dau.png',
    },
    {
      'name': 'Gói whey uống nạp năng lượng',
      'points': '500',
      'image': 'assets/images/loyalty/goi_whey_uong.png',
    },
  ];

  final List<Map<String, dynamic>> _gifts = [
    {
      'name': 'Nón thể thao',
      'points': '100',
      'image': 'assets/images/loyalty/non.png',
    },
    {
      'name': 'Bình nước thể thao',
      'points': '150',
      'image': 'assets/images/loyalty/binh_nuoc.png',
    },
  ];

  final List<Map<String, dynamic>> _shortCourses = [
    {
      'name': '30 ngày tập nhảy',
      'points': '100',
      'image': 'assets/images/loyalty/30_tap_nhay.png',
    },
    {
      'name': '15 ngày tập Yoga',
      'points': '100',
      'image': 'assets/images/loyalty/15_tap_yoga.png',
    },
  ];

  // void _onItemTapped(int index) {
  //   if (index == 0) {
  //     // Quay về trang chủ nếu nhấn index 0
  //     Navigator.pop(context);
  //   } else {
  //     setState(() => _selectedIndex = index);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final double bottomSafeHeight = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFF151515),
      body: Stack(
        children: [
          // LỚP 1: BACKGROUND IMAGE THEO SNIPPET
          Positioned(
            left: -104,
            top: 42,
            child: Opacity(
              opacity: 0.1,
              child: Image.asset(
                "assets/images/background_login_v3_layer.png", // Cập nhật đúng path ảnh
                width: context.resW(695),
                height: context.resH(795),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // LỚP 2: NỘI DUNG CHÍNH
          SafeArea(
            child: Column(
              children: [
                // _buildHeader(), // Header mới không nút back
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLocationRow(),
                        _buildLoyaltyStatsCards(),
                        SizedBox(height: context.resH(16)),
                        _buildHorizontalSection(
                          'Nạp năng lượng',
                          _energyProducts,
                        ),
                        _buildHorizontalSection('Quà tặng', _gifts),
                        _buildHorizontalSection(
                          'Khoá tập ngắn hạn',
                          _shortCourses,
                        ),
                        SizedBox(height: context.resH(80) + bottomSafeHeight),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      // THÊM BOTTOM NAV BAR VÀO ĐÂY
      // bottomNavigationBar: CommonBottomNavBar(
      //   currentIndex: _selectedIndex,
      //   onTap: _onItemTapped,
      // ),
    );
  }

  // Header với nút quay lại và tiêu đề
  // Widget _buildHeader() {
  //   return Padding(
  //     padding: EdgeInsets.symmetric(
  //       horizontal: context.resW(8),
  //       vertical: context.resH(10),
  //     ),
  //     child: Row(
  //       children: [
  //         IconButton(
  //           icon: const Icon(
  //             Icons.arrow_back_ios,
  //             color: Colors.white,
  //             size: 20,
  //           ),
  //           onPressed: () => Navigator.pop(context),
  //         ),
  //         Text(
  //           "Cali Loyalty",
  //           style: TextStyle(
  //             color: Colors.white,
  //             fontSize: context.resClamp(18, 16, 22),
  //             fontWeight: FontWeight.bold,
  //             fontFamily: 'Inter',
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Dòng hiển thị khu vực
  Widget _buildLocationRow() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.resW(20),
        vertical: context.resH(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Khu vực',
            style: TextStyle(
              color: const Color(0xFFC7C7C7),
              fontSize: context.resClamp(14, 12, 16),
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                'Ho Chi Minh',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: context.resClamp(16, 14, 18),
                  fontFamily: 'Mulish',
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.keyboard_arrow_down,
                color: Colors.white,
                size: 18,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoyaltyStatsCards() {
    return Container(
      width: double.infinity,
      height: context.resH(56),
      margin: EdgeInsets.symmetric(horizontal: context.resW(20)),
      padding: EdgeInsets.symmetric(
        horizontal: context.resW(12),
        vertical: context.resH(4),
      ),
      decoration: ShapeDecoration(
        color: const Color(0xFF242424),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Row(
        children: [
          // PHẦN ĐIỂM TÍCH LŨY
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Điểm tích luỹ',
                  style: TextStyle(
                    color: const Color(0xFF9A9A9A),
                    fontSize: context.resClamp(12, 10, 14),
                    fontFamily: 'Inter',
                    height: 1.5,
                  ),
                ),
                // Bọc Badge và Icon vào Row để nằm trên 1 dòng
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CommonPointBadge(
                      value: '500',
                      svgPath: 'assets/images/vuesax/ranking.svg',
                      hasBorder: false,
                    ),
                    const SizedBox(width: 4),
                    // BIỂU TƯỢNG MŨI TÊN (Khoanh đỏ trong hình)
                    Icon(
                      Icons.arrow_forward_ios,
                      color: const Color(0xFF9A9A9A),
                      size: context.resClamp(10, 8, 12), // Responsive size
                    ),
                  ],
                ),
              ],
            ),
          ),

          // VẠCH CHIA DỌC
          Container(
            width: 1,
            height: context.resH(37),
            color: const Color(0xFF3E3E3E),
          ),
          SizedBox(width: context.resW(12)),

          // PHẦN VOUCHER CỦA TÔI
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Voucher của tôi',
                  style: TextStyle(
                    color: const Color(0xFF9A9A9A),
                    fontSize: context.resClamp(12, 10, 14),
                    fontFamily: 'Inter',
                    height: 1.5,
                  ),
                ),
                // Bọc Badge và Icon vào Row cho phần Voucher
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CommonPointBadge(
                      value: '5',
                      svgPath: 'assets/images/vuesax/ticket-discount.svg',
                      useGradient: false,
                      hasBorder: false,
                    ),
                    const SizedBox(width: 4),
                    // BIỂU TƯỢNG MŨI TÊN (Khoanh đỏ trong hình)
                    Icon(
                      Icons.arrow_forward_ios,
                      color: const Color(0xFF9A9A9A),
                      size: context.resClamp(10, 8, 12), // Responsive size
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget _statCard(String label, String value, {required bool isPoint}) {
  //   return Container(
  //     width: double.infinity,
  //     height: context.resH(56),
  //     padding: EdgeInsets.symmetric(horizontal: context.resW(12)),
  //     decoration: BoxDecoration(
  //       color: const Color(0xFF242424),
  //       borderRadius: BorderRadius.circular(8),
  //     ),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //       children: [
  //         Text(
  //           label,
  //           style: TextStyle(
  //             color: const Color(0xFF9A9A9A),
  //             fontSize: context.resClamp(12, 10, 14),
  //             fontFamily: 'Inter',
  //           ),
  //         ),
  //         CommonPointBadge(
  //           value: value,
  //           svgPath: isPoint
  //               ? 'assets/images/vuesax/ranking.svg'
  //               : 'assets/images/vuesax/ticket-discount.svg',
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildHorizontalSection(
    String title,
    List<Map<String, dynamic>> items,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.resW(20),
            vertical: context.resH(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: context.resClamp(14, 12, 16),
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Xem tất cả',
                style: TextStyle(
                  color: const Color(0xFF9A9A9A),
                  fontSize: context.resClamp(14, 12, 16),
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: context.resH(230),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.only(left: context.resW(20)),
            itemCount: items.length,
            itemBuilder: (context, index) => _buildProductCard(items[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard(Map<String, dynamic> item) {
    return Container(
      width: context.resW(150),
      margin: EdgeInsets.only(right: context.resW(20), bottom: 10, top: 5),
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: const Color(0xFF3E3E3E),
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 2, color: Color(0xFF6B6B6B)),
          borderRadius: BorderRadius.circular(8),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0xFF545152),
            blurRadius: 0,
            offset: Offset(5, 5),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // BO GÓC HÌNH ẢNH
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
            child: Image.asset(
              item['image'],
              width: double.infinity,
              height: context.resH(110),
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(context.resW(10)),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start, // NAME VÀ POINT THẲNG HÀNG TRÁI
              children: [
                // SỬ DỤNG SIZEDBOX ĐỂ CỐ ĐỊNH CHIỀU CAO TÊN (Đảm bảo point ngang hàng nhau)
                SizedBox(
                  height: context.resH(42), // Đủ cho tối đa 2 dòng chữ
                  child: Text(
                    item['name'],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: context.resClamp(13, 11, 15),
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Inter',
                      height: 1.2,
                    ),
                  ),
                ),
                SizedBox(height: context.resH(8)),
                // Point Badge không border, không padding ngoài
                CommonPointBadge(
                  value: item['points'],
                  svgPath: 'assets/images/vuesax/ranking.svg',
                  hasBorder: false, // Bỏ border khung ngoài
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
