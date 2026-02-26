import 'dart:async';

import 'package:californiaflutter/helpers/loading_manager.dart';
import 'package:californiaflutter/helpers/size_utils.dart';
import 'package:californiaflutter/models/schedule_model.dart';
import 'package:californiaflutter/pages/layouts/class_detail.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ScheduleDetailScreen extends StatefulWidget {
  final ScheduleModel schedule;

  const ScheduleDetailScreen({super.key, required this.schedule});

  @override
  State<ScheduleDetailScreen> createState() => _ScheduleDetailScreenState();
}

class _ScheduleDetailScreenState extends State<ScheduleDetailScreen> {
  @override
  void initState() {
    super.initState();
    // 1. Hiển thị loading ngay khi màn hình khởi tạo
    _startFakeLoading();
  }

  @override
  void dispose() {
    // 2. Đảm bảo tắt loading nếu người dùng thoát màn hình đột ngột
    LoadingManager().hide();
    super.dispose();
  }

  void _startFakeLoading() {
    // WidgetsBinding giúp đảm bảo context đã sẵn sàng trước khi gọi Overlay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      LoadingManager().show(context);

      // 3. Đặt thời gian chờ giả lập 3 giây (có thể chỉnh thành 5s)
      Timer(const Duration(seconds: 3), () {
        if (mounted) {
          LoadingManager().hide();
          // Force rebuild để hiển thị nội dung nếu cần
          setState(() {});
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final double systemBottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFF151515),
      body: Stack(
        children: [
          // 1. PHẦN HÌNH ẢNH NỀN VÀ OVERLAY
          _buildHeroImage(context),

          // 2. NỘI DUNG CUỘN
          Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                    bottom: systemBottomPadding + context.resH(100),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: context.resH(160),
                      ), // Đệm để đẩy text xuống dưới ảnh
                      _buildMainInfo(context),
                      _buildStatsRow(context),
                      _buildDescriptionSection(context),
                      _buildNoteSection(context),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // 3. NÚT ĐẶT CHỖ CỐ ĐỊNH Ở ĐÁY
          _buildStickyBookingButton(context, systemBottomPadding),
        ],
      ),
    );
  }

  // MARK: - UI Helpers

  Widget _buildHeroImage(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: context.resH(325),
      child: Stack(
        children: [
          Image.asset(
            "assets/images/none.jpg", // Thay bằng image từ model nếu có
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),
          // Lớp phủ tối dần lên trên
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.55),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: context.resW(8),
          vertical: context.resH(12),
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 20,
              ),
            ),
            Text(
              'Chi tiết lớp',
              style: TextStyle(
                color: Colors.white,
                fontSize: context.resClamp(18, 16, 22),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainInfo(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.resW(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tag loại lớp
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF8B66F0),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              widget.schedule.classType ?? 'GroupX',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(height: context.resH(8)),
          Text(
            widget.schedule.className ?? 'Gentle Yoga',
            style: TextStyle(
              color: Colors.white,
              fontSize: context.resClamp(24, 20, 28),
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: context.resH(8)),
          _buildIconText(
            Icons.calendar_month_outlined,
            // ignore: unnecessary_string_interpolations
            '${DateFormat('dd/MM/yyyy hh:mm a').format(widget.schedule.startDate ?? DateTime.now())}',
          ),
          _buildIconText(
            Icons.person_outline,
            'Giáo viên ${widget.schedule.trainerName ?? 'N/A'}',
          ),
          Row(
            children: [
              _buildIconText(
                Icons.location_on_outlined,
                widget.schedule.clubName ?? 'N/A',
              ),
              const Spacer(),
              Text(
                'Xem đường đi',
                style: TextStyle(
                  color: const Color(0xFFE1494F),
                  fontSize: context.resClamp(12, 10, 14),
                ),
              ),
            ],
          ),
          Row(
            children: [
              _buildIconText(
                Icons.map_outlined,
                widget.schedule.seatMapImage ?? 'N/A',
              ),
              const Spacer(),
              Text(
                'Xem sơ đồ',
                style: TextStyle(
                  color: const Color(0xFFE1494F),
                  fontSize: context.resClamp(12, 10, 14),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(context.resW(20)),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF242424),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          _buildStatItem(
            context,
            'Thời lượng học',
            '${widget.schedule.duration ?? 0} phút',
          ),
          Container(width: 1, height: 30, color: const Color(0xFF6B6B6B)),
          _buildStatItem(
            context,
            'Vị trí ngồi',
            'Còn ${widget.schedule.slotLeft ?? 0}/${widget.schedule.numberSeat ?? 0} chỗ',
            isRich: true,
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.resW(20),
        vertical: context.resH(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Giới thiệu',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: context.resH(8)),
          Text(
            widget.schedule.note?.isNotEmpty == true
                ? widget.schedule.note!
                : 'Gentle Yoga là sự kết hợp của các tư thế chậm và đơn giản...',
            style: const TextStyle(
              color: Color(0xFFC7C7C7),
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteSection(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.resW(20),
        vertical: context.resH(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Lưu ý',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: context.resH(8)),
          const Text(
            'Quyền lợi đặt chỗ trên ứng dụng sẽ đóng trước khi lớp bắt đầu 2 tiếng...',
            style: TextStyle(
              color: Color(0xFFC7C7C7),
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStickyBookingButton(BuildContext context, double bottomPadding) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.fromLTRB(
          20,
          12,
          20,
          bottomPadding > 0 ? bottomPadding : 20,
        ),
        decoration: const BoxDecoration(
          color: Color(0xFF151515),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () {
            return _showSeatSelectionModal(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFD92229),
            minimumSize: Size(double.infinity, context.resH(48)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          child: const Text(
            'Đặt chỗ',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  // Helper Widgets
  Widget _buildIconText(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value, {
    bool isRich = false,
  }) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(color: Color(0xFFC7C7C7), fontSize: 10),
          ),
          const SizedBox(height: 4),
          isRich
              ? Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(
                        text: 'Còn ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(
                        text: value.split(' ')[1].split('/')[0],
                        style: const TextStyle(
                          color: Color(0xFF5BC146),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(
                        text: '/${value.split('/')[1]}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                )
              : Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ],
      ),
    );
  }

  void _showSeatSelectionModal(BuildContext context) {
    // Lấy độ cao dải tác vụ (Safe Area Bottom)
    final double bottomPadding = MediaQuery.of(context).padding.bottom;
    int selectedSeat = 10; // Giá trị mặc định theo snippet

    // 1. TẠO CONTROLLER ĐỂ ĐIỀU KHIỂN VỊ TRÍ CUỘN BẢN ĐẦU
    final FixedExtentScrollController seatController =
        FixedExtentScrollController(
          initialItem: selectedSeat - 1, // index = số ghế - 1
        );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF151515),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) {
        return StatefulBuilder(
          // Để cập nhật số ghế ngay trong modal
          builder: (context, setModalState) {
            return Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(
                context.resW(20),
                context.resH(24),
                context.resW(20),
                bottomPadding > 0
                    ? bottomPadding + 10
                    : 24, // Xử lý thanh tác vụ
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 1. HEADER CHỌN CHỖ
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: const BoxDecoration(
                      // border: Border(
                      //   bottom: BorderSide(color: Color(0xFF3E3E3E), width: 1),
                      // ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Chọn chỗ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: context.resClamp(16, 14, 18),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  SizedBox(height: context.resH(24)),

                  // 2. VÙNG CHỌN SỐ GHẾ (Wheel Picker)
                  // VÙNG CHỌN SỐ GHẾ
                  Container(
                    height: context.resH(220),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFF262626),
                      borderRadius: BorderRadius.circular(8),
                      // border: Border.all(
                      //   color: const Color(0xFF0091FF),
                      //   width: 1.5,
                      // ),
                    ),
                    child: ListWheelScrollView.useDelegate(
                      // 2. GẮN CONTROLLER VÀO ĐÂY
                      controller: seatController,
                      itemExtent: context.resH(50), // Responsive chiều cao mục
                      diameterRatio: 2.0,
                      physics: const FixedExtentScrollPhysics(),
                      onSelectedItemChanged: (index) {
                        // Cập nhật trạng thái khi người dùng cuộn
                        setModalState(() => selectedSeat = index + 1);
                      },
                      childDelegate: ListWheelChildBuilderDelegate(
                        childCount: widget.schedule.numberSeat ?? 30,
                        builder: (context, index) {
                          final seatNum = index + 1;
                          final isSelected = seatNum == selectedSeat;

                          return Center(
                            child: Text(
                              '$seatNum',
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.white.withValues(alpha: 0.3),
                                // 3. RESPONSIVE FONT SIZE
                                fontSize: isSelected
                                    ? context.resClamp(24, 22, 26)
                                    : context.resClamp(18, 16, 20),
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w400,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  SizedBox(height: context.resH(32)),

                  // 3. CỤM NÚT HỦY VÀ XÁC NHẬN
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF3E3E3E)),
                            minimumSize: Size(
                              double.infinity,
                              context.resH(48),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          child: const Text(
                            'Hủy',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      SizedBox(width: context.resW(16)),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // Navigator.pop(context);
                            // Logic xác nhận đặt chỗ với selectedSeat
                            // Bạn có thể in log để kiểm tra số ghế đã chọn
                            debugPrint(
                              "Đặt chỗ thành công cho ghế số: $selectedSeat",
                            );
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ClassDetailScreen(
                                  schedule: widget.schedule,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD92229),
                            minimumSize: Size(
                              double.infinity,
                              context.resH(48),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          child: const Text(
                            'Xác nhận',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
