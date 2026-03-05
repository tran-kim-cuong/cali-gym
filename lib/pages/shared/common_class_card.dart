import 'package:californiaflutter/helpers/image_helper.dart';
import 'package:californiaflutter/helpers/size_utils.dart';
import 'package:californiaflutter/models/booking_class_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class CommonClassCard extends StatelessWidget {
  final BookingData data;
  final VoidCallback? onCheckIn;
  final int index;

  const CommonClassCard({
    super.key,
    required this.data,
    required this.index,
    this.onCheckIn,
  });

  @override
  Widget build(BuildContext context) {
    // Logic định dạng ngày/giờ tập trung tại đây
    final String formattedDate = data.startDate != null
        ? DateFormat('dd/MM/yyyy').format(data.startDate!)
        : '--/--/----';

    final String timeRange = data.startDate != null && data.endDate != null
        ? "${DateFormat('hh:mm a').format(data.startDate!)} - ${DateFormat('hh:mm a').format(data.endDate!)}"
        : '--:--';

    final _ = context.locale;

    return Container(
      width: context.resW(160),
      margin: EdgeInsets.only(right: context.resW(16), bottom: 6, top: 5),
      decoration: ShapeDecoration(
        color: const Color(0xFF3E3E3E),
        shape: RoundedRectangleBorder(
          side: const BorderSide(
            width: 2,
            color: Color.fromARGB(255, 238, 234, 19),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0xFF545152),
            offset: Offset(4, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Hình ảnh bo góc
          // XỬ LÝ HÌNH ẢNH AN TOÀN
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(7)),
            child: _buildImage(index),
          ),

          Padding(
            padding: EdgeInsets.fromLTRB(
              context.resW(8),
              context.resW(8),
              context.resW(8),
              context.resW(4),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tên lớp học
                Text(
                  data.serviceName ?? 'N/A',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: context.resClamp(14, 12, 16),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                // Ngày tháng
                _buildInfoRow(context, Icons.calendar_today, formattedDate),
                const SizedBox(height: 2),
                // Giờ tập
                _buildInfoRow(context, Icons.access_time, timeRange),

                SizedBox(height: context.resH(8)),

                // Nút Check-in
                _buildCheckInButton(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(int idx) {
    // // Tạo tên file theo định dạng _01, _02, _03...
    // final String imageIndex = (idx + 1).toString().padLeft(2, '0');
    // final String assetPath = 'assets/images/image_class_$imageIndex.png';

    return Image.asset(
      ImageHelper.getClassThumbnail(data.classType),
      height: 120, // context.resH(120)
      width: double.infinity,
      fit: BoxFit.cover,
      // TRÁNH CRASH: Nếu không tìm thấy file class_XX.jpg, hiện none.png
      errorBuilder: (context, error, stackTrace) {
        return Image.asset(
          'assets/images/none.jpg',
          height: 120,
          width: double.infinity,
          fit: BoxFit.cover,
        );
      },
    );
  }

  // Tách hàm nhỏ để code gọn hơn
  Widget _buildInfoRow(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF9A9A9A), size: context.resW(10)),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            color: const Color(0xFF9A9A9A),
            fontSize: context.resClamp(10, 9, 12),
          ),
        ),
      ],
    );
  }

  Widget _buildCheckInButton(BuildContext context) {
    return InkWell(
      onTap: onCheckIn,
      child: Container(
        width: double.infinity,
        height: context.resH(32),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFF6B6B6B),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          'class_detail.scan_checkin_button_text'.tr(),
          style: TextStyle(
            color: const Color(0xFFC7C7C7),
            fontSize: context.resClamp(12, 10, 14),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
