import 'package:californiaflutter/helpers/size_utils.dart';
import 'package:californiaflutter/pages/layouts/login.dart';
import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Lấy kích thước màn hình để tính toán tỷ lệ nếu cần
    // final Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF151515),
      body: Column(
        children: [
          // 1. PHẦN TRÊN: HÌNH ẢNH (Chiếm khoảng 55-60% màn hình)
          Expanded(
            flex: 6,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/background_v3_layer.png',
                    fit: BoxFit.cover,
                    // Căn giữa hình ảnh để lấy phần người mẫu
                    alignment: const Alignment(0.2, 0),
                  ),
                ),
                // Lớp phủ tối nhẹ trên ảnh để thấy rõ thanh trạng thái
                Positioned.fill(
                  child: Container(color: Colors.black.withValues(alpha: 0.2)),
                ),
                // Thanh trạng thái giả lập (9:41)
                // SafeArea(
                //   child: Padding(
                //     padding: EdgeInsets.symmetric(
                //       horizontal: context.res(24),
                //       vertical: context.res(12),
                //     ),
                //     child: Row(
                //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //       children: [
                //         Text(
                //           '9:41',
                //           style: TextStyle(
                //             color: Colors.white,
                //             fontSize: context.resClamp(15, 13, 18),
                //             fontWeight: FontWeight.w600,
                //           ),
                //         ),
                //         const Icon(
                //           Icons.signal_cellular_alt,
                //           color: Colors.white,
                //           size: 18,
                //         ),
                //       ],
                //     ),
                //   ),
                // ),
              ],
            ),
          ),

          // 2. PHẦN DƯỚI: NỘI DUNG (Khối màu đen chứa Text và Button)
          Expanded(
            flex: 4,
            child: Container(
              width: double.infinity,
              color: const Color(0xFF151515),
              padding: EdgeInsets.symmetric(horizontal: context.res(24)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tiêu đề lớn
                  Text(
                    'MORE THAN\nJUST AN APP',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Oswald',
                      fontSize: context.resClamp(52, 40, 65),
                      fontWeight: FontWeight.w700,
                      height: 1.1,
                    ),
                  ),

                  SizedBox(height: context.res(12)),

                  // Văn bản mô tả
                  Text(
                    "Sống khỏe không áp lực. Vừa chill vóc dáng, vừa 'feel' quà sang",
                    style: TextStyle(
                      color: const Color(0xFFC7C7C7),
                      fontFamily: 'Inter',
                      fontSize: context.resClamp(14, 12, 16),
                      fontWeight: FontWeight.w400,
                      height: 1.4,
                    ),
                  ),

                  SizedBox(height: context.res(32)),

                  // Nút Đăng nhập
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // CHUYỂN TRANG TẠI ĐÂY
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                          );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFDA2128),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          vertical: context.resClamp(16, 14, 20),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Đăng nhập',
                        style: TextStyle(
                          fontSize: context.resClamp(16, 14, 18),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  // Khoảng cách an toàn dưới cùng cho Home Indicator
                  SizedBox(height: context.res(20)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
