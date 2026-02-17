import 'package:californiaflutter/helpers/session_manager.dart';
import 'package:flutter/material.dart';

class OtherBenefitsScreen extends StatefulWidget {
  const OtherBenefitsScreen({super.key});

  @override
  State<OtherBenefitsScreen> createState() => _OtherBenefitsScreenState();
}

class _OtherBenefitsScreenState extends State<OtherBenefitsScreen> {
  // Quản lý số lượng sản phẩm
  int _smallTowelCount = 1;
  int _largeTowelCount = 1;
  int _setTowelCount = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFF242424,
      ), // Colors-Background-bg-base-primary
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFF1A1A1A), // Nền tối hơn cho phần nội dung
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [_buildMembershipSection(), _buildProductSection()],
              ),
            ),
          ),
          _buildBottomAction(),
        ],
      ),
    );
  }

  // --- 1. Header: Tiêu đề và nút quay lại ---
  Widget _buildHeader(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
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
            const Expanded(
              child: Text(
                'Quyền lợi khác',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 2. Thẻ hội viên (Staff Section) ---
  Widget _buildMembershipSection() {
    // 1. Truy cập thông tin hội viên từ SessionManager
    // final member = SessionManager.member;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thẻ hội viên',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF3E3E3E),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 2. Hiển thị tên hạng thẻ hoặc trạng thái
                      // Giả định trường dữ liệu là membershipLevel hoặc status
                      // Text(
                      //   // member?.membershipType ?? 'Staff',
                      //   'Staff',
                      //   style: const TextStyle(
                      //     color: Colors.white,
                      //     fontSize: 14,
                      //   ),
                      // ),
                      // 3. Hiển thị mã số hội viên
                      // Giả định trường dữ liệu là memberCode hoặc barcode
                      // Text(
                      //   member ?? 'N/A',
                      //   style: const TextStyle(
                      //     color: Color(0xFF9A9A9A),
                      //     fontSize: 12,
                      //   ),
                      // ),
                    ],
                  ),
                ),
                const Icon(Icons.credit_card, color: Color(0xFFD9D9D9)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- 3. Danh sách chọn sản phẩm ---
  Widget _buildProductSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Chọn sản phẩm',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          _buildProductItem(
            'Khăn nhỏ',
            _smallTowelCount,
            (val) => setState(() => _smallTowelCount = val),
          ),
          _buildProductItem(
            'Khăn to',
            _largeTowelCount,
            (val) => setState(() => _largeTowelCount = val),
          ),
          _buildProductItem(
            'Set khăn (1 to + 1 nhỏ)',
            _setTowelCount,
            (val) => setState(() => _setTowelCount = val),
          ),
        ],
      ),
    );
  }

  // Widget con cho từng dòng sản phẩm
  Widget _buildProductItem(String name, int count, Function(int) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name, style: const TextStyle(color: Colors.white, fontSize: 14)),
          Row(
            children: [
              _buildQtyBtn(
                Icons.remove,
                () => count > 0 ? onChanged(count - 1) : null,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '$count',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
              _buildQtyBtn(Icons.add, () => onChanged(count + 1)),
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
        padding: const EdgeInsets.all(4),
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
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 34),
      child: ElevatedButton(
        onPressed: () {
          // Xử lý xác nhận quyền lợi
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFD92229),
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        child: const Text(
          'Xác nhận',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
