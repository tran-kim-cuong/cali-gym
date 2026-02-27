import 'package:californiaflutter/bases/app_session.dart';
import 'package:californiaflutter/bases/base_api.dart';
import 'package:californiaflutter/bases/loading_wrapper.dart';
import 'package:californiaflutter/helpers/image_helper.dart';
import 'package:californiaflutter/helpers/size_utils.dart';
import 'package:californiaflutter/models/schedule_model.dart';
import 'package:californiaflutter/pages/shared/common_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';

class ClassDetailScreen extends StatefulWidget {
  final int? scheduleId;

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
    // Tự động gọi API khi vào màn hình
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _fetchData();
    });
  }

  Future<void> _fetchData() async {
    try {
      final response = await handleApi(
        context,
        BaseApi().client.get(
          '/get/schedules/id',
          queryParameters: {'scheduleIds': widget.scheduleId},
        ),
      );

      if (response?.statusCode == 200 && response?.data != null) {
        final List<dynamic> listData = response?.data['data'] ?? [];
        if (listData.isNotEmpty && mounted) {
          setState(() {
            debugPrint('${listData.first}');
            schedule = ScheduleModel.fromJson(listData.first);
          });
        }
      }
    } catch (e) {
      debugPrint("Lỗi tải chi tiết: $e");
    }
  }

  String _formatClassTime(DateTime? start, DateTime? end) {
    if (start == null || end == null) return 'N/A';

    // 1. Định dạng ngày: dd/MM/yyyy
    final String dateStr = DateFormat('dd/MM/yyyy').format(start);

    // 2. Định dạng giờ bắt đầu và kết thúc: hh:mm a
    final String startTime = DateFormat('hh:mm a').format(start);
    final String endTime = DateFormat('hh:mm a').format(end);

    return '$dateStr $startTime - $endTime';
  }

  @override
  Widget build(BuildContext context) {
    final double systemTopPadding = MediaQuery.of(context).padding.top;
    final double systemBottomPadding = MediaQuery.of(context).padding.bottom;

    if (schedule == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF151515),
        body: Center(child: CircularProgressIndicator(color: Colors.red)),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF151515),
      body: Stack(
        children: [
          _buildHeroImage(context),
          Column(
            children: [
              _buildHeader(context, systemTopPadding),
              Expanded(
                child: RefreshIndicator(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.only(
                      bottom: context.resH(120) + systemBottomPadding,
                    ),
                    child: Column(
                      children: [
                        // GIẢM KHOẢNG CÁCH TẠI ĐÂY ĐỂ ĐẨY CARD LÊN CAO
                        SizedBox(height: context.resH(12)),

                        _buildMainStatsCard(context),
                        _buildContentSections(context),
                      ],
                    ),
                  ),
                  onRefresh: () => _fetchData(),
                ),
              ),
            ],
          ),
          _buildStickyBottomActions(context, systemBottomPadding),
        ],
      ),
    );
  }

  // MARK: - UI Components

  Widget _buildHeroImage(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: context.resH(325), // Chiều cao ảnh theo snippet
      child: Stack(
        children: [
          Image.asset(
            ImageHelper.getClassThumbnail(schedule?.classType),
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (c, e, s) =>
                Image.asset("assets/images/none.jpg", fit: BoxFit.cover),
          ),
          // Gradient phủ tối để chữ header rõ nét
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.55),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, double topPadding) {
    return Container(
      padding: EdgeInsets.only(top: topPadding + 8, left: 8, right: 20),
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
              fontSize: context.resClamp(18, 16, 20),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainStatsCard(BuildContext context) {
    return Padding(
      // Thêm padding top nếu muốn dãn nhẹ với header
      padding: EdgeInsets.fromLTRB(
        context.resW(20),
        context.resH(10), // Khoảng cách nhỏ với chữ "Chi tiết lớp"
        context.resW(20),
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. TAGS (GroupX & Chờ xác nhận)
          Row(
            children: [
              _tagWidget('GroupX', const Color(0xFF8B66F0)),
              SizedBox(width: context.resW(8)),
              _tagWidget('Chờ xác nhận', const Color(0xFF859DFE)),
            ],
          ),
          SizedBox(height: context.resH(16)),

          // 2. TIÊU ĐỀ LỚP HỌC
          Text(
            schedule?.className ?? 'Gentle Yoga',
            style: TextStyle(
              color: Colors.white,
              fontSize: context.resClamp(28, 24, 32),
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          SizedBox(height: context.resH(16)),

          // 3. DANH SÁCH THÔNG TIN ICON
          _buildInfoLine(
            Icons.calendar_month_outlined,
            _formatClassTime(schedule?.startDate, schedule?.endDate),
          ), // Format cứng theo hình mẫu
          _buildInfoLine(
            Icons.person_outline,
            'Giáo viên ${schedule?.trainerName ?? 'Alex Smith'}',
          ),
          _buildInfoLine(
            Icons.location_on_outlined,
            '${schedule?.clubName}',
            hasAction: true,
            actionText: 'Xem đường đi',
          ),
          _buildInfoLine(
            Icons.map_outlined,
            '${schedule?.numberSeat} chỗ ngồi',
            hasAction: true,
            actionText: 'Xem sơ đồ',
          ),

          SizedBox(height: context.resH(20)),

          // 4. THẺ THÔNG SỐ (90 PHÚT - VỊ TRÍ 12)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF242424),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                _buildStatItem(
                  context,
                  'Thời lượng học',
                  '${schedule?.duration} phút',
                ),
                Container(width: 1, height: 30, color: const Color(0xFF3E3E3E)),
                _buildStatItem(
                  context,
                  'Vị trí ngồi',
                  '${schedule?.slotBooked}',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tagWidget(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildInfoLine(
    IconData icon,
    String text, {
    bool hasAction = false,
    String? actionText,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          SizedBox(width: context.resW(10)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          if (hasAction)
            GestureDetector(
              onTap: () {},
              child: Text(
                actionText!,
                style: const TextStyle(
                  color: Color(0xFFE1494F), // Màu đỏ action
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContentSections(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(context.resW(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Giới thiệu'),
          SizedBox(height: context.resH(8)),
          Text(
            (schedule?.note != null && schedule!.note!.isNotEmpty)
                ? schedule!.note!
                : 'Thông tin đang được cập nhật...',
            style: const TextStyle(
              color: Color(0xFFC7C7C7),
              fontSize: 12,
              height: 1.5,
            ),
          ),
          SizedBox(height: context.resH(24)),
          _sectionTitle('Lưu ý'),
          SizedBox(height: context.resH(8)),
          Text(
            dotenv.get(
              'COMMON_NOTICED',
              fallback: 'Thông tin đang được cập nhật...',
            ),
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

  Widget _buildStickyBottomActions(BuildContext context, double bottomPadding) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.fromLTRB(
          20,
          12,
          20,
          // Xử lý thông minh: Nếu có Home Indicator thì dùng padding hệ thống,
          // nếu không thì cách đáy 24px cho đẹp
          bottomPadding > 0 ? bottomPadding : 24,
        ),
        decoration: const BoxDecoration(
          color: Color(0xFF151515), // Nền đen đồng bộ với màn hình
          border: Border(top: BorderSide(color: Colors.white10, width: 0.5)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment:
              CrossAxisAlignment.stretch, // Trải dài nút hết chiều ngang
          children: [
            // 1. NÚT HUỶ LỊCH HẸN (Dạng Outlined)
            OutlinedButton(
              onPressed: () {
                // Thêm logic huỷ lịch tại đây
                print(widget.scheduleId);
                print("clubCode");
                print(AppSession().customerId);
                print("chỗ ngồi");
                print("test hủy lịch hẹn");
              },
              style: OutlinedButton.styleFrom(
                // Màu viền xám mỏng theo hình mẫu
                side: const BorderSide(color: Color(0xFF6B6B6B), width: 1),
                minimumSize: Size(double.infinity, context.resH(48)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: const Text(
                'Huỷ lịch hẹn 1',
                style: TextStyle(
                  color: Colors.white, // Chữ trắng nổi bật trên nền tối
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            SizedBox(height: context.resH(12)), // Khoảng cách giữa 2 nút
            // 2. NÚT QUÉT ĐỂ CHECK-IN (Dạng Solid Red)
            ElevatedButton(
              onPressed: () {
                String qrCode = ''; // Gắn nội dung bỏ vô đây - DungDT
                CommonModalWidget.showBigQrModal(
                  context: context,
                  qrData: qrCode,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD92229), // Màu đỏ thương hiệu
                minimumSize: Size(double.infinity, context.resH(48)),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: const Text(
                'Quét để Check-in',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // MARK: - Helper Widgets
  Widget _buildStatItem(BuildContext context, String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(color: Color(0xFFC7C7C7), fontSize: 10),
          ),
          const SizedBox(height: 4),
          Text(
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

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
