import 'package:californiaflutter/pages/shared/common_point_badge.dart';
import 'package:flutter/material.dart';

class LoyaltyScreen extends StatelessWidget {
  const LoyaltyScreen({super.key});

  final Color _bgPrimary = const Color(0xFF242424);
  final Color _bgSecondary = const Color(0xFF3E3E3E);
  final Color _textGray = const Color(0xFF9A9A9A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgPrimary,
      appBar: AppBar(
        backgroundColor: _bgPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Cali Loyalty",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Phần Khu vực
            _buildLocationHeader(),

            // Phần Điểm và Voucher
            _buildLoyaltyStats(),

            // Phần Khoá tập ngắn hạn
            _buildSection(
              title: "Khoá tập ngắn hạn",
              items: [
                _buildProductItem(
                  "30 ngày tập Dance Sport",
                  "500",
                  "assets/images/loyalty/khoa_hoc_ngan_han.png",
                ),
                _buildProductItem(
                  "Yoga cơ bản 15 buổi",
                  "800",
                  "assets/images/loyalty/khoa_hoc_ngan_han.png",
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Phần Quà tặng
            _buildSection(
              title: "Quà tặng",
              items: [
                _buildProductItem(
                  "Bình nước Cali",
                  "30",
                  "assets/images/loyalty/binh_nuoc.png",
                ),
                _buildProductItem(
                  "Nón thời trang",
                  "45",
                  "assets/images/loyalty/non.png",
                ),
                _buildProductItem(
                  "Túi xách thể thao",
                  "120",
                  "assets/images/loyalty/khoa_hoc_ngan_han.png",
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Khu vực", style: TextStyle(color: _textGray, fontSize: 14)),
          const SizedBox(height: 4),
          Row(
            children: const [
              Text(
                "Ho Chi Minh",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Icon(Icons.keyboard_arrow_down, color: Colors.white),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoyaltyStats() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _bgPrimary,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _bgSecondary),
      ),
      child: Row(
        children: [
          // Điểm tích lũy
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Điểm tích luỹ",
                  style: TextStyle(color: _textGray, fontSize: 12),
                ),
                Row(
                  children: [
                    const Text(
                      "500",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const CommonPointBadge(),
                  ],
                ),
              ],
            ),
          ),
          // Đường kẻ chia dọc
          Container(width: 1, height: 30, color: _bgSecondary),
          const SizedBox(width: 20),
          // Voucher của tôi
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Voucher của tôi",
                  style: TextStyle(color: _textGray, fontSize: 12),
                ),
                Row(
                  children: const [
                    Text(
                      "12",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.confirmation_number_outlined,
                      color: Colors.white,
                      size: 16,
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

  Widget _buildSection({required String title, required List<Widget> items}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                "Xem tất cả",
                style: TextStyle(color: _textGray, fontSize: 14),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.only(left: 20),
          child: Row(children: items),
        ),
      ],
    );
  }

  Widget _buildProductItem(String name, String points, String imageUrl) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: _bgSecondary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            child: Image.asset(
              imageUrl,
              height: 120,
              width: 150,
              fit: BoxFit.cover,
              // Thêm errorBuilder để tránh crash nếu thiếu file ảnh
              errorBuilder: (context, error, stackTrace) => Container(
                height: 120,
                width: 150,
                color: Colors.grey,
                child: const Icon(Icons.image_not_supported),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      points,
                      style: TextStyle(color: _textGray, fontSize: 12),
                    ),
                    const SizedBox(width: 4),
                    const CommonPointBadge(),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
