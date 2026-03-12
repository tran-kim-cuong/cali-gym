import 'package:californiaflutter/helpers/size_utils.dart'; // Import helper responsive
import 'package:californiaflutter/pages/shared/common_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/svg.dart';

class HistoryScheduleScreen extends StatefulWidget {
  final bool hasBottomActions;

  const HistoryScheduleScreen({super.key, this.hasBottomActions = false});

  @override
  State<HistoryScheduleScreen> createState() => _HistoryScheduleScreenState();
}

class _HistoryScheduleScreenState extends State<HistoryScheduleScreen> {
  // Biến trạng thái cho Tab chính (Hoàn thành / Chưa hoàn thành)
  bool _isCompletedSelected = false;

  @override
  Widget build(BuildContext context) {
    // Xử lý Safe Area cho các dòng máy có tai thỏ và home indicator
    final double systemBottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFF151515),
      body: Stack(
        children: [
          // 1. BACKGROUND IMAGE SCALE THEO THIẾT BỊ
          CommonBackgroundWidget.buildBackgroundImage(
            context,
            dotenv.get('IMAGES_BG_BENEFIT_V3_LAYER'),
          ),

          // 2. NỘI DUNG CHÍNH (Xử lý Notch/Tai thỏ bằng SafeArea)
          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Title "Các lớp học trước"
                // HEADER CÓ NÚT BACK
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.resW(8),
                    vertical: context.resH(8),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: context.resW(20),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Các lớp học trước',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: context.resClamp(18, 16, 22),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      _buildHeaderIcon(
                        context,
                        dotenv.get('VUESAX_ARROW_FILTER'),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: context.resH(16)),

                // Tab: Hoàn thành / Chưa hoàn thành
                Row(
                  children: [
                    _buildTabItem(
                      context,
                      "Hoàn thành",
                      isSelected: _isCompletedSelected,
                      onTap: () => _handleMainTabChange(true),
                    ),
                    _buildTabItem(
                      context,
                      "Chưa hoàn thành",
                      isSelected: !_isCompletedSelected,
                      isError: true, // Màu đỏ cho chưa hoàn thành theo mẫu
                      onTap: () => _handleMainTabChange(false),
                    ),
                  ],
                ),

                // Empty State Content
                // Trong hàm build của HistoryScheduleScreen
                Expanded(
                  child: RefreshIndicator(
                    color: const Color(0xFFD92229),
                    backgroundColor: const Color(0xFF242424),
                    onRefresh: () async =>
                        await Future.delayed(const Duration(seconds: 2)),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            Container(
                              constraints: BoxConstraints(
                                minHeight: constraints.maxHeight,
                              ),
                              alignment: Alignment.center,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // 1. THÊM HÌNH ẢNH SVG
                                  SvgPicture.asset(
                                    dotenv.get(
                                      'VUESAX_NO_DOCUMENT',
                                    ), // Đường dẫn file SVG của bạn
                                    width: context.resW(
                                      120,
                                    ), // Scale chiều rộng theo thiết bị
                                    height: context.resW(
                                      120,
                                    ), // Giữ tỉ lệ vuông
                                    // colorFilter: const ColorFilter.mode(
                                    //   Color(
                                    //     0xFF464444,
                                    //   ), // Màu xám tối để hài hòa với nền
                                    //   BlendMode.srcIn,
                                    // ),
                                  ),

                                  // 2. KHOẢNG CÁCH GIỮA ẢNH VÀ CHỮ
                                  SizedBox(height: context.resH(16)),

                                  // 3. DÒNG CHỮ THÔNG BÁO (Giữ nguyên logic của bạn)
                                  Text(
                                    'Hiện không lớp học nào',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: const Color(0xFF9A9A9A),
                                      fontSize: context.resClamp(
                                        14,
                                        12,
                                        16,
                                      ), // Responsive font
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),

                // 3. Xử lý Home Indicator (Thanh gạch dưới màn hình)
                SizedBox(
                  height: widget.hasBottomActions
                      ? context.resH(10)
                      : systemBottomPadding + 20,
                ),
              ],
            ),
          ),
        ],
      ),
      // Action Bar dưới đáy
      bottomNavigationBar: widget.hasBottomActions
          ? _buildDummyActionBar(context, systemBottomPadding)
          : null,
    );
  }

  // Widget xây dựng Tab chính - Scale Font và Border
  Widget _buildTabItem(
    BuildContext context,
    String title, {
    required bool isSelected,
    bool isError = false,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: context.resH(12)),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                width: context.resW(2),
                color: isSelected
                    ? (isError ? const Color(0xFFE04A50) : Colors.white)
                    : const Color(0xFF6B6B6B),
              ),
            ),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected
                  ? (isError ? const Color(0xFFE04A50) : Colors.white)
                  : const Color(0xFF9A9A9A),
              fontSize: context.resClamp(14, 12, 16),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  void _handleMainTabChange(bool isCompleted) {
    setState(() {
      _isCompletedSelected = isCompleted;
    });
  }

  Widget _buildHeaderIcon(BuildContext context, String icon) {
    return Container(
      padding: EdgeInsets.all(context.resW(8)),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white12),
        borderRadius: BorderRadius.circular(context.resW(8)),
      ),
      child: SvgPicture.asset(
        icon, // 2. Thay size bằng width/height để giữ đúng tỉ lệ SVG
        width: context.resW(20),
        height: context.resW(20),
        // 3. Sử dụng ColorFilter thay cho thuộc tính color đã cũ
        // colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
        fit: BoxFit.contain,
      ),
    );
  }

  // NÚT BẤM SCALE THEO THIẾT BỊ
  Widget _buildDummyActionBar(BuildContext context, double bottomPadding) {
    return Container(
      color: const Color(0xFF151515),
      // Padding bottom tự động cộng thêm khoảng cách của Home Indicator
      padding: EdgeInsets.fromLTRB(
        context.resW(16),
        context.resH(10),
        context.resW(16),
        bottomPadding > 0 ? bottomPadding : context.resH(24),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE04A50),
          // Chiều cao nút scale theo resH
          minimumSize: Size(double.infinity, context.resH(50)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(context.resW(12)),
          ),
        ),
        onPressed: () {},
        child: Text(
          "Tìm lớp học mới",
          style: TextStyle(
            color: Colors.white,
            fontSize: context.resClamp(16, 14, 18),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
