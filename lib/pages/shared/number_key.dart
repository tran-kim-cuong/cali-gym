import 'package:flutter/material.dart';

class NumericKeyboard extends StatelessWidget {
  final Function(String) onKeyTap;

  const NumericKeyboard({super.key, required this.onKeyTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.2),
      padding: const EdgeInsets.only(bottom: 20, top: 10),
      child: Column(
        children: [
          _buildKeyboardRow(["1", "2", "3"]),
          _buildKeyboardRow(["4", "5", "6"]),
          _buildKeyboardRow(["7", "8", "9"]),
          _buildKeyboardRow(["", "0", "delete"]),
        ],
      ),
    );
  }

  Widget _buildKeyboardRow(List<String> keys) {
    return Row(
      children: keys.map((key) {
        return Expanded(
          child: InkWell(
            onTap: () => onKeyTap(key),
            child: Container(
              height: 60, // Tăng chiều cao để dễ bấm hơn trên mobile
              alignment: Alignment.center,
              child: key == "delete"
                  ? const Icon(Icons.backspace_outlined, color: Colors.white)
                  : Text(
                      key,
                      style: const TextStyle(color: Colors.white, fontSize: 24),
                    ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
