import 'package:flutter/material.dart';

class CommonBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CommonBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  // Định nghĩa màu sắc cố định theo thiết kế
  final Color _redColor = const Color(0xFFD92229);
  final Color _inactiveColor = const Color(0xFF9A9A9A);

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      color: Colors.white,
      shadowColor: Colors.black12,
      elevation: 10,
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(Icons.home, "Trang chủ", 0),
            _navItem(Icons.calendar_today, "Lớp học", 1),
            const SizedBox(width: 40), // Khoảng trống cho FloatingActionButton
            _navItem(Icons.local_offer_outlined, "Khuyến mãi", 2),
            _navItem(Icons.person_outline, "Hồ sơ", 3),
          ],
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    bool isSelected = currentIndex == index;
    return InkWell(
      onTap: () => onTap(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: isSelected ? _redColor : _inactiveColor),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: isSelected ? _redColor : _inactiveColor,
            ),
          ),
        ],
      ),
    );
  }
}
