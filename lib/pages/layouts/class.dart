import 'package:californiaflutter/bases/app_session.dart';
import 'package:californiaflutter/bases/loading_wrapper.dart';
import 'package:californiaflutter/helpers/size_utils.dart';
import 'package:californiaflutter/models/booking_class_model.dart';
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
      final List<BookingData> rs =
          await handleApi(
            context,
            BookingService.getUpcomingClasses(AppSession().clientId),
          ) ??
          [];

      if (mounted) {
        setState(() {
          classes = rs;
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
                      return _buildClassItem(context, classes[index]);
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
            onPressed: () => Navigator.pop(context),
          ),
          Text(
            'Lớp học sắp tới',
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
  Widget _buildClassItem(BuildContext context, BookingData item) {
    // Xác định màu sắc tag dựa trên trạng thái
    //item.status == "Chờ xác nhận";
    final Color tagColor = const Color(0xFF859DFE);

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: context.resH(16)),
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: const Color(0xFF242424),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(context.resW(4)),
        ),
      ),
      child: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ảnh lớp học - Scale theo thiết bị
              Container(
                width: context.resW(128),
                height: context.resH(119),
                decoration: const BoxDecoration(color: Colors.white),
                child: Image.network(
                  "https://placehold.co/199x133",
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => const Icon(Icons.image),
                ),
              ),

              // Thông tin lớp học
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(context.resW(8)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.serviceName ?? 'N/A',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: context.resClamp(14, 12, 16),
                          fontWeight: FontWeight.w600,
                          height: 1.5,
                        ),
                      ),
                      SizedBox(height: context.resH(10)),
                      _buildIconInfo(
                        context,
                        Icons.person,
                        'Giáo viên Alan Smith',
                      ),
                      _buildIconInfo(
                        context,
                        Icons.access_time,
                        DateFormat(
                          'dd/MM/yyyy hh:MM a',
                        ).format(item.startDate!),
                      ),
                      _buildIconInfo(
                        context,
                        Icons.location_on,
                        '${item.clubName}',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Tag trạng thái - Positioned ở góc phải
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: context.resW(8),
                vertical: context.resH(4),
              ),
              decoration: BoxDecoration(
                color: tagColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(context.resW(4)),
                ),
              ),
              // child: Text(
              //   item.status ?? 'Sắp diễn ra',
              //   textAlign: TextAlign.center,
              //   style: TextStyle(
              //     color: Colors.white,
              //     fontSize: context.resClamp(10, 9, 12),
              //     fontWeight: FontWeight.w500,
              //     height: 1.5,
              //   ),
              // ),
            ),
          ),
        ],
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
