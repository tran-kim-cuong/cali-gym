import 'package:californiaflutter/bases/app_session.dart';
import 'package:californiaflutter/bases/base_api.dart';
import 'package:californiaflutter/bases/loading_wrapper.dart';
import 'package:californiaflutter/helpers/image_helper.dart';
import 'package:californiaflutter/helpers/size_utils.dart';
import 'package:californiaflutter/models/schedule_model.dart';
import 'package:californiaflutter/pages/master.dart';
import 'package:californiaflutter/pages/shared/common_modal.dart';
import 'package:californiaflutter/pages/shared/common_notification.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ClassDetailScreen extends StatefulWidget {
  final int? scheduleId;
  final String? seatCode;
  final String? clubCode;

  const ClassDetailScreen({
    super.key,
    required this.scheduleId,
    required this.seatCode,
    required this.clubCode,
  });

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
            'class_detail.title'.tr(),
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
              _tagWidget(
                schedule?.classType ?? 'class_detail.default_null'.tr(),
                const Color(0xFF8B66F0),
              ),
              SizedBox(width: context.resW(8)),
              _tagWidget(
                'class_detail.tag_widget_status'.tr(),
                const Color(0xFF859DFE),
              ),
            ],
          ),
          SizedBox(height: context.resH(16)),

          // 2. TIÊU ĐỀ LỚP HỌC
          Text(
            schedule?.className ?? 'class_detail.default_null'.tr(),
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
            '${'class_detail.info_sub_trainer'.tr()} ${schedule?.trainerName ?? 'class_detail.default_null'.tr()}',
          ),
          _buildInfoLine(
            Icons.location_on_outlined,
            '${schedule?.clubName}',
            hasAction: true,
            actionText: 'class_detail.info_googlemaps'.tr(),
          ),
          _buildInfoLine(
            Icons.map_outlined,
            '${schedule?.numberSeat} ${'class_detail.info_sub_seat'.tr()}',
            hasAction: true,
            actionText: 'class_detail.info_classmaps'.tr(),
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
                  'class_detail.info_duration'.tr(),
                  '${schedule?.duration} ${'class_detail.info_minutes'.tr()}',
                ),
                Container(width: 1, height: 30, color: const Color(0xFF3E3E3E)),
                _buildStatItem(
                  context,
                  'class_detail.info_seat'.tr(),
                  '${widget.seatCode}',
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
          _sectionTitle('class_detail.info_introduce'.tr()),
          SizedBox(height: context.resH(8)),
          Text(
            (schedule?.note != null && schedule!.note!.isNotEmpty)
                ? schedule!.note!
                : 'class_detail.default_message'.tr(),
            style: const TextStyle(
              color: Color(0xFFC7C7C7),
              fontSize: 12,
              height: 1.5,
            ),
          ),
          SizedBox(height: context.resH(24)),
          _sectionTitle('class_detail.info_notice'.tr()),
          SizedBox(height: context.resH(8)),
          Text(
            'class_detail.content_notice'.tr(),
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
                CommonModalWidget.showQuestionModal(
                  context: context,
                  imagePath: dotenv.get('IMAGES_QUESTION_ILLUSTRATION'),
                  title: 'class_detail.model_question_title_text'.tr(),
                  onConfirm: () async {
                    String ticketNumber =
                        "${widget.scheduleId}${widget.clubCode}${AppSession().customerId}.${widget.seatCode}";
                    var response = await handleApi(
                      context,
                      BaseApi().client.post(
                        '/api/booking/seat/delete',
                        data: {
                          "ticket_number": ticketNumber,
                          "clientcode": AppSession().clientId,
                        },
                      ),
                    );

                    if (!context.mounted) return;

                    if (response == null ||
                        response.statusCode != 200 ||
                        response.data == null) {
                      CommonModalWidget.showWarningModal(
                        context: context,
                        imagePath: dotenv.get('IMAGES_CANCEL_ILLUSTRATION'),
                        title: '',
                        description: 'class_detail.modal_cancel_title_text'
                            .tr(),
                        buttonText: 'class_detail.modal_cancel_button_text'
                            .tr(), // 'Đã hiểu'
                      );
                    } else {
                      if (response.data['success'] == false) {
                        CommonModalWidget.showWarningModal(
                          context: context,
                          imagePath: dotenv.get('IMAGES_CANCEL_ILLUSTRATION'),
                          title: '',
                          description:
                              '${response.data['message']} [${response.data['error_code']}]',
                          buttonText: 'class_detail.modal_cancel_button_text'
                              .tr(),
                        );
                      } else {
                        CommonNotification.show(
                          context,
                          message: 'class_detail.notice_cancel_succeed'
                              .tr(), // 'Hủy lớp học thành công'
                        );
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            // Gọi đến Layout chứa Bottom Nav Bar, truyền index của tab Lịch tập (ví dụ là 1)
                            builder: (context) =>
                                const MasterScreen(initialIndex: 1),
                          ),
                          (route) =>
                              false, // Xóa sạch các trang cũ để tránh lỗi chồng lấp
                        );
                      }
                    }
                  },
                );
              },
              style: OutlinedButton.styleFrom(
                // Màu viền xám mỏng theo hình mẫu
                side: const BorderSide(color: Color(0xFF6B6B6B), width: 1),
                minimumSize: Size(double.infinity, context.resH(48)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: Text(
                'class_detail.cancel_button_text'.tr(), // 'Huỷ lịch hẹn'
                style: const TextStyle(
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
                print("QR code checkin");
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
              child: Text(
                'class_detail.scan_checkin_button_text'
                    .tr(), // 'Quét để Check-in'
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
