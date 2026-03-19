import 'package:californiaflutter/bases/app_session.dart';
import 'package:californiaflutter/bases/loading_wrapper.dart';
import 'package:californiaflutter/helpers/image_helper.dart';
import 'package:californiaflutter/helpers/size_utils.dart';
import 'package:californiaflutter/models/booking_class_model.dart';
import 'package:californiaflutter/pages/layouts/class_detail.dart';
import 'package:californiaflutter/pages/master.dart';
import 'package:californiaflutter/pages/shared/common_background.dart';
import 'package:californiaflutter/services/booking_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ClassScreen extends StatefulWidget {
  const ClassScreen({super.key});

  @override
  State<ClassScreen> createState() => _ClassScreenState();
}

class _ClassScreenState extends State<ClassScreen> with LoadingWrapper {
  List<BookingData> classes = [];

  @override
  void initState() {
    super.initState();
    // GỌI API LẤY DỮ LIỆU MỚI NHẤT KHI VÀO MÀN HÌNH
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchLatestClasses();
    });
  }

  // Logic gọi API lấy danh sách lớp học sắp tới
  Future<void> _fetchLatestClasses() async {
    try {
      final List<BookingData> fetchedClasses =
          await handleApi(
            context,
            BookingService.getUpcomingClasses(AppSession().clientId),
          ) ??
          [];

      fetchedClasses.sort((a, b) {
        if (a.startDate == null || b.startDate == null) return 0;
        return a.startDate!.compareTo(b.startDate!);
      });

      if (mounted) {
        setState(() {
          classes = fetchedClasses;
        });
      }
    } catch (e) {
      debugPrint("Lỗi nạp dữ liệu ClassScreen: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Xử lý Safe Area cho các dòng máy có Home Indicator
    final double systemBottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFF151515),
      body: Stack(
        children: [
          // LỚP 1: BACKGROUND RESPONSIVE
          CommonBackgroundWidget.buildBackgroundImage(
            context,
            dotenv.get('IMAGES_BG_BENEFIT_V3_LAYER'),
          ),

          // LỚP 2: NỘI DUNG CHÍNH (Xử lý tai thỏ bằng SafeArea)
          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),

                // DANH SÁCH LỚP HỌC RESPONSIVE
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.fromLTRB(
                      context.resW(20),
                      context.resH(12),
                      context.resW(20),
                      systemBottomPadding + context.resH(20),
                    ),
                    itemCount: classes.length,
                    itemBuilder: (context, index) {
                      return _buildClassItem(context, index, classes[index]);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Header với nút quay lại và tiêu đề responsive
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.resW(8),
        vertical: context.resH(4),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
              size: 20,
            ),
            onPressed: () {
              // SỬA TẠI ĐÂY: Luôn điều hướng về MasterScreen tab Lịch tập (Index 1)
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const MasterScreen(initialIndex: 0),
                ),
                (route) =>
                    false, // Xóa sạch các route cũ để đảm bảo hiện Nav Bar mới
              );
            },
          ),
          Text(
            'home.section_next_class'.tr(),
            style: TextStyle(
              color: Colors.white,
              // Font scale theo thiết bị
              fontSize: context.resClamp(18, 16, 22),
              fontWeight: FontWeight.w600,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // Widget từng Item lớp học theo snippet thiết kế của bạn
  Widget _buildClassItem(BuildContext context, int index, BookingData item) {
    // Xác định màu sắc tag dựa trên trạng thái
    //item.status == "Chờ xác nhận";
    final List<String> watermarks = [
      'assets/images/watermark/image 1527.png', // Index 0, 3, 6...
      'assets/images/watermark/image 1526.png', // Index 1, 4, 7...
      'assets/images/watermark/image 1556.png', // Index 2, 5, 8...
    ];
    final String selectedWatermark = watermarks[index % watermarks.length];

    // Màu tag trạng thái dựa trên dữ liệu thực tế
    final Color tagColor = (index % 2 == 0)
        ? const Color(0xFFFFB359)
        : const Color(0xFF59BFFF);
    final String tagText = (index % 2 == 0) ? '' : '';

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ClassDetailScreen(
              // Truyền ID sang để trang chi tiết tự gọi API
              scheduleId: item.scheduleId,
              seatCode: item.code,
              clubCode: item.clubCode,
            ),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(bottom: context.resH(16)),
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          color: const Color(0xFF3E3E3E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(context.resW(4)),
            side: const BorderSide(color: Color(0xFFEF4822), width: 1.5),
          ),
        ),
        child: Stack(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ẢNH LỚP HỌC (LẤP ĐẦY CHIỀU CAO)
                SizedBox(
                  width: context.resW(140),
                  height: context.resH(130),
                  child: Image.asset(
                    ImageHelper.getClassThumbnail(item.classType),
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Image.asset(
                      "assets/images/none.jpg",
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                // PHẦN THÔNG TIN BÊN PHẢI
                Expanded(
                  child: Stack(
                    children: [
                      // 3. GẮN WATERMARK CANH PHẢI DƯỚI
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Opacity(
                          opacity: 0.8, // Độ mờ của hình watermark chìm
                          child: Container(
                            width: context.resW(87), // Chiều rộng responsive
                            height: context.resH(77), // Chiều cao responsive
                            alignment: Alignment.bottomRight,
                            child: Image.asset(
                              selectedWatermark,
                              fit: BoxFit
                                  .contain, // Đảm bảo ảnh nằm gọn trong khung 87x77
                            ),
                          ),
                        ),
                      ),

                      // NỘI DUNG CHỮ
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          context.resW(12),
                          context.resH(12), // 4. DỊCH CHUYỂN XUỐNG 1 TÍ
                          context.resW(8),
                          context.resH(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Tên lớp học màu cam rực
                            Padding(
                              padding: EdgeInsets.only(
                                right: context.resW(85),
                              ), // Chừa chỗ cho tag trạng thái
                              child: Text(
                                item.serviceName ?? 'N/A',
                                maxLines:
                                    2, // Cho phép xuống dòng nếu tên quá dài
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: const Color(0xFFF7941D),
                                  fontSize: context.resClamp(16, 14, 18),
                                  fontWeight: FontWeight.bold,
                                  height: 1.2,
                                ),
                              ),
                            ),
                            SizedBox(height: context.resH(10)),
                            _buildIconInfo(
                              context,
                              Icons.person_outline,
                              '${'class_detail.info_sub_trainer'.tr()} ${item.trainerName ?? 'N/A'}',
                            ),
                            _buildIconInfo(
                              context,
                              Icons.calendar_month_outlined,
                              DateFormat(
                                'dd/MM/yyyy h:mm a',
                              ).format(item.startDate!),
                            ),
                            _buildIconInfo(
                              context,
                              Icons.location_on_outlined,
                              '${item.clubName}',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // TAG TRẠNG THÁI
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.resW(10),
                  vertical: context.resH(6),
                ),
                decoration: BoxDecoration(
                  color: tagColor,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(context.resW(8)),
                  ),
                ),
                child: Text(
                  tagText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconInfo(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: context.resH(4)),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF9A9A9A), size: context.resW(12)),
          SizedBox(width: context.resW(4)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: const Color(0xFF9A9A9A),
                fontSize: context.resClamp(10, 9, 12),
                fontWeight: FontWeight.w400,
                height: 1.5,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
