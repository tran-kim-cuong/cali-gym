import 'package:californiaflutter/pages/shared/common_membership_card.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class MemberListScreen extends StatefulWidget {
  final List<Map<String, dynamic>> cards;
  const MemberListScreen({super.key, required this.cards});

  @override
  State<MemberListScreen> createState() => _MemberListScreenState();
}

class _MemberListScreenState extends State<MemberListScreen> {
  // Thay đổi kiểu dữ liệu của _activeCardId từ String sang dynamic để nhận cả Index
  dynamic _activeCardId;

  // --- HÀM XỬ LÝ RIÊNG CỦA MÀN HÌNH NÀY ---
  void _showBigQrModal(BuildContext context, String qrData) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        // Dùng Container bao ngoài để ép chiều ngang full màn hình
        return Container(
          width: double.infinity, // <--- QUAN TRỌNG: Full width
          padding: const EdgeInsets.only(
            bottom: 20,
          ), // Thêm chút padding đáy cho đẹp
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment:
                  CrossAxisAlignment.center, // Căn giữa nội dung
              children: [
                const SizedBox(height: 12),
                // Thanh gạch ngang (Handle bar)
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 30),

                // QR Code
                SizedBox(
                  width: 250,
                  height: 250,
                  child: QrImageView(data: qrData, version: QrVersions.auto),
                ),

                const SizedBox(height: 30),

                // Text hướng dẫn
                const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20,
                  ), // Padding text cho đỡ sát lề
                  child: Text(
                    "Vui lòng đưa mã này cho lễ tân để check-in",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text(
          'Thẻ hội viên',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: widget.cards.length,
        separatorBuilder: (context, index) => const SizedBox(height: 20),
        itemBuilder: (context, index) {
          final cardData = widget.cards[index];
          // Sử dụng kết hợp index và id để đảm bảo tính duy nhất tuyệt đối
          final String uniqueKey = "${index}_${cardData['id']}";

          return CommonMembershipCard(
            data: cardData,
            margin: EdgeInsets.zero,
            isExpanded: _activeCardId == uniqueKey,

            // Xử lý đóng mở thẻ
            onToggle: () {
              setState(() {
                _activeCardId = (_activeCardId == uniqueKey) ? null : uniqueKey;
              });
            },

            // --- TRUYỀN HÀM XỬ LÝ MODAL VÀO ĐÂY ---
            onQrClick: (String currentQrData) {
              // Gọi hàm hiển thị modal của trang này
              _showBigQrModal(context, currentQrData);
            },
          );
        },
      ),
    );
  }
}
