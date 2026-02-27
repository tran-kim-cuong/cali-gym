import 'package:californiaflutter/bases/loading_wrapper.dart';
import 'package:californiaflutter/helpers/image_helper.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/schedule_model.dart';

// import '../shared/check_in_bottom_sheet.dart'; //
class ClassDetailScreen extends StatefulWidget {
  final int? scheduleId; // Chỉ nhận ID

  const ClassDetailScreen({super.key, required this.scheduleId});

  @override
  State<ClassDetailScreen> createState() => _ClassDetailScreenState();
}

class _ClassDetailScreenState extends State<ClassDetailScreen>
    with LoadingWrapper {
  ScheduleModel? schedule;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFF242424,
      ), // Colors-Background-bg-base-primary
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderImage(context),
                  _buildMainInfo(),
                  _buildDetailedSection(),
                  _buildNoteSection(),
                  _buildIntroSection(),
                ],
              ),
            ),
          ),
          _buildBottomActions(context),
        ],
      ),
    );
  }

  // --- 1. Ảnh header và nút Back ---
  Widget _buildHeaderImage(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 367,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                ImageHelper.getClassThumbnail(schedule?.classType),
              ), // Hoặc dùng NetworkImage
              fit: BoxFit.cover,
            ),
          ),
        ),
        // Overlay mờ
        Positioned.fill(
          child: Container(color: Colors.black.withValues(alpha: 0.1)),
        ),
        // Nút Back
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(left: 16, top: 10),
            child: CircleAvatar(
              backgroundColor: Colors.black.withValues(alpha: 0.3),
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ),
        // Tiêu đề overlay
        Positioned(
          bottom: 20,
          left: 20,
          child: const Text(
            'Chi tiết dịch vụ',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // --- 2. Thông tin chính (Tên lớp, giáo viên) ---
  Widget _buildMainInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            schedule?.className ?? 'N/A', //
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Giáo viên: ${schedule?.trainerName ?? 'Chưa cập nhật'}',
                style: const TextStyle(color: Color(0xFF9A9A9A), fontSize: 14),
              ),
              Text(
                '${schedule?.slotBooked ?? 0} chiến binh',
                style: const TextStyle(color: Color(0xFF9A9A9A), fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- 3. Section Thông tin chung (Mã lớp, Thời gian, Địa điểm) ---
  Widget _buildDetailedSection() {
    return _buildSectionWrapper(
      title: 'Thông tin chung',
      child: Column(
        children: [
          _buildInfoRow('Mã lớp học', "${schedule?.scheduleId ?? 'N/A'}"),
          _buildInfoRow(
            'Số ghế đặt',
            '${schedule?.slotBooked ?? 'N/A'}/${schedule?.numberSeat ?? 'N/A'}',
            actionLabel: 'Xem sơ đồ',
            onAction: () {},
          ),
          _buildInfoRow(
            'Thời gian học',
            schedule?.startDate != null
                ? DateFormat(
                    'dd/MM/yyyy HH:mm',
                  ).format(schedule?.startDate ?? DateTime.now())
                : '--',
          ),
          _buildInfoRow(
            'Địa điểm học',
            '${schedule?.studioName ?? 'N/A'} - ${schedule?.clubName ?? 'N/A'}',
            actionLabel: 'Xem đường đi',
            onAction: () {},
          ),
        ],
      ),
    );
  }

  // --- 4. Section Lưu ý ---
  Widget _buildNoteSection() {
    return _buildSectionWrapper(
      title: 'Lưu ý',
      child: const Text(
        'Quyền lợi đặt chỗ trên ứng dụng sẽ đóng trước khi lớp bắt đầu 2 tiếng\nQuyền lợi đăng kí trước buổi tập sẽ được tạm ngưng 14 ngày trong trường hợp hội viên thay đổi kế hoạch tập luyện nhưng không huỷ bỏ buổi tập đã đăng ký trước (No show) 3 lần (tích luỹ ) trong vòng 30 ngày kể từ lần vi phạm gần nhất',
        style: TextStyle(color: Color(0xFF9A9A9A), fontSize: 12, height: 1.5),
      ),
    );
  }

  // --- 5. Section Giới thiệu ---
  Widget _buildIntroSection() {
    return _buildSectionWrapper(
      title: 'Giới thiệu',
      child: Text(
        schedule?.note ?? 'N/A', //
        style: const TextStyle(color: Color(0xFF9A9A9A), fontSize: 12),
      ),
    );
  }

  // --- 6. Nút hành động dính dưới đáy ---
  Widget _buildBottomActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        20,
        12,
        20,
        34,
      ), // Padding bottom cho iPhone
      decoration: const BoxDecoration(
        color: Color(0xFF242424),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        spacing: 16,
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF9A9A9A)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                'Huỷ lịch hẹn',
                style: TextStyle(
                  color: Color(0xFFC7C7C7),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Expanded(
            child: ElevatedButton(
              onPressed:
                  null, //() => CheckInBottomSheet.show(context, schedule), //
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD92229),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                'Quét mã Check-in',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper cho giao diện Section
  Widget _buildSectionWrapper({required String title, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  // Helper cho các dòng thông tin (Mã lớp, địa điểm...)
  Widget _buildInfoRow(
    String label,
    String value, {
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon Placeholder (Sử dụng SizedBox như trong thiết kế của bạn)
          Container(
            width: 20,
            height: 20,
            margin: const EdgeInsets.only(right: 8),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF9A9A9A),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (actionLabel != null)
            TextButton(
              onPressed: onAction,
              child: Text(
                actionLabel,
                style: const TextStyle(
                  color: Color(0xFFE04A50),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
