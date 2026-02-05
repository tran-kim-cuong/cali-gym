import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LanguageBottomSheet {
  // Hàm static để gọi từ bất cứ đâu mà không cần khởi tạo class
  static void show({
    required BuildContext context,
    required String
    currentLanguage, // Ngôn ngữ đang chọn (ví dụ: 'vi' hoặc 'en')
    required Function(String)
    onLanguageSelected, // Callback trả về kết quả khi chọn
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return _LanguageBody(
          currentLanguage: currentLanguage,
          onSelect: (code) {
            onLanguageSelected(code); // Trả code ngôn ngữ về màn hình cha
            Navigator.pop(context); // Đóng modal
          },
        );
      },
    );
  }
}

// Widget nội bộ, chỉ dùng trong file này để dựng giao diện danh sách
class _LanguageBody extends StatelessWidget {
  final String currentLanguage;
  final Function(String) onSelect;

  const _LanguageBody({required this.currentLanguage, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Ngôn ngữ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white24, height: 1),

          // Danh sách ngôn ngữ
          _buildOption('vi', 'Tiếng Việt', 'assets/images/vietnam.svg'),
          const Divider(
            color: Colors.white24,
            height: 1,
            indent: 20,
            endIndent: 20,
          ),
          _buildOption('en', 'English', 'assets/images/kingdom.svg'),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildOption(String code, String name, String assetPath) {
    final isSelected = currentLanguage == code;
    return InkWell(
      onTap: () => onSelect(code),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: SvgPicture.asset(
                assetPath,
                fit: BoxFit.cover,
                // Fallback icon nếu chưa có ảnh cờ
                placeholderBuilder: (_) =>
                    const Icon(Icons.flag, color: Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            // Custom Radio Button
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? const Color(0xFFDA212D) : Colors.grey,
                  width: 2,
                ),
                color: isSelected
                    ? const Color(0xFFDA212D)
                    : Colors.transparent,
              ),
              child: isSelected
                  ? const Center(
                      child: CircleAvatar(
                        radius: 4,
                        backgroundColor: Colors.white,
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
