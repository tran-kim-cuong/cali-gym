import 'dart:convert';

import 'package:californiaflutter/bases/base_api.dart';
import 'package:californiaflutter/bases/loading_wrapper.dart';
import 'package:californiaflutter/helpers/image_helper.dart';
import 'package:californiaflutter/helpers/size_utils.dart';
import 'package:californiaflutter/models/schedule_model.dart';
import 'package:californiaflutter/pages/layouts/history_schedule.dart';
import 'package:californiaflutter/pages/layouts/schedule_detail.dart';
import 'package:californiaflutter/pages/shared/common_background.dart';
import 'package:californiaflutter/pages/shared/language_bottom_sheet.dart';
import 'package:californiaflutter/services/vietnam_time_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> with LoadingWrapper {
  int _selectedDateIndex = 0; // T2 - Ngày 15
  // Biến hứng danh sách dữ liệu từ API
  List<ScheduleModel> _schedules = [];
  List<Map<String, dynamic>> _cities = [];
  List<Map<String, dynamic>> _clubs = [];
  List<Map<String, dynamic>> _services = [];
  String sClubs = '';
  DateTime? _nowVietnam;

  DateTime get _effectiveVietnamNow =>
      _nowVietnam ?? VietnamTimeService.instance.getDeviceNowVietnam();

  DateTime _getDateTimeFromIndex(int index) {
    final DateTime base = _effectiveVietnamNow;
    final DateTime todayInVietnam = DateTime(base.year, base.month, base.day);
    return todayInVietnam.add(Duration(days: index));
  }

  // 3. Hàm lấy nhãn Thứ (T2-CN) dựa trên DateTime thực tế
  String _getDayLabel(DateTime date) {
    switch (date.weekday) {
      case 1:
        return 'schedule.mon'.tr();
      case 2:
        return 'schedule.tue'.tr();
      case 3:
        return 'schedule.wed'.tr();
      case 4:
        return 'schedule.thu'.tr();
      case 5:
        return 'schedule.fri'.tr();
      case 6:
        return 'schedule.sat'.tr();
      case 7:
        return 'schedule.sun'.tr();
      default:
        return '';
    }
  }

  // ─── FILTER PERSISTENCE ─────────────────────────────────────────────────────

  static const String _kFilterServices = 'schedule_filter_services';
  static const String _kFilterCities = 'schedule_filter_cities';
  static const String _kFilterClubs = 'schedule_filter_clubs';
  static const String _kFilterSClubs = 'schedule_filter_sclubs';

  Future<void> _saveFilterPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kFilterServices, jsonEncode(_services));
    await prefs.setString(_kFilterCities, jsonEncode(_cities));
    await prefs.setString(_kFilterClubs, jsonEncode(_clubs));
    await prefs.setString(_kFilterSClubs, sClubs);
  }

  Future<void> _loadFilterPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final servicesJson = prefs.getString(_kFilterServices);
    final citiesJson = prefs.getString(_kFilterCities);
    final clubsJson = prefs.getString(_kFilterClubs);
    final savedSClubs = prefs.getString(_kFilterSClubs) ?? '';

    if (!mounted) return;
    setState(() {
      if (servicesJson != null) {
        _services = List<Map<String, dynamic>>.from(
          (jsonDecode(servicesJson) as List).map(
            (e) => Map<String, dynamic>.from(e as Map),
          ),
        );
      }
      if (citiesJson != null) {
        _cities = List<Map<String, dynamic>>.from(
          (jsonDecode(citiesJson) as List).map(
            (e) => Map<String, dynamic>.from(e as Map),
          ),
        );
      }
      if (clubsJson != null) {
        _clubs = List<Map<String, dynamic>>.from(
          (jsonDecode(clubsJson) as List).map(
            (e) => Map<String, dynamic>.from(e as Map),
          ),
        );
      }
      sClubs = savedSClubs;
    });
  }

  Future<void> _clearFilterPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kFilterServices);
    await prefs.remove(_kFilterCities);
    await prefs.remove(_kFilterClubs);
    await prefs.remove(_kFilterSClubs);
  }

  // ────────────────────────────────────────────────────────────────────────────

  void _showFilterBottomSheet() {
    // print('khổi tạo bộ lọc');

    /// 1. Khởi tạo bộ dữ liệu từ hình ảnh bạn cung cấp
    final List<Map<String, dynamic>> serviceList = [
      {'id': 'yoga', 'name': 'Yoga', 'isSelected': false},
      {'id': 'cycling', 'name': 'Cycling', 'isSelected': false},
      {'id': 'groupx', 'name': 'Group-X', 'isSelected': false},
    ];
    //hiện lần thứ hai thì hiển thị những loại lớp đã hiện trước đó
    if (_services.isNotEmpty) {
      for (var ite in serviceList) {
        if (_services.any((e) => e['id'] == ite['id'])) {
          ite['isSelected'] = true;
        }
      }
    }

    final List<Map<String, dynamic>> cityList = [
      {'id': 'hanoi', 'name': 'Ha Noi', 'isSelected': false},
      {'id': 'hcm', 'name': 'Ho Chi Minh', 'isSelected': false},
      {'id': 'binhduong', 'name': 'Binh Duong', 'isSelected': false},
      {'id': 'bienhoa', 'name': 'Bien Hoa', 'isSelected': false},
      {'id': 'cantho', 'name': 'Can Tho', 'isSelected': false},
      {'id': 'vungtau', 'name': 'Vung Tau', 'isSelected': false},
      {'id': 'danang', 'name': 'Da Nang', 'isSelected': false},
      {'id': 'nhatrang', 'name': 'Nha Trang', 'isSelected': false},
    ];
    if (_cities.isNotEmpty) {
      for (var ite in cityList) {
        if (_cities.any((e) => e['id'] == ite['id'])) {
          ite['isSelected'] = true;
        }
      }
    }

    // Dữ liệu mẫu cho Câu lạc bộ
    //Luôn luôn phải chọn thành phố
    final List<Map<String, dynamic>> oriClub = [
      {
        'id': 'AMY',
        'name': 'Aeon Mall Binh Tan Club',
        'city_name': 'Ho Chi Minh',
        'isSelected': false,
      },
      {
        'id': 'AMU',
        'name': 'Aeon Mall Tan Phu Club',
        'city_name': 'Ho Chi Minh',
        'isSelected': false,
      },
      {
        'id': 'TTC',
        'name': 'Ba Thang Hai Club',
        'city_name': 'Ho Chi Minh',
        'isSelected': false,
      },
      {
        'id': 'CPT',
        'name': 'Capital Tower',
        'city_name': 'Ha Noi',
        'isSelected': false,
      },
      {
        'id': 'CVC',
        'name': 'Can Tho Club',
        'city_name': 'Can Tho',
        'isSelected': false,
      },
      {
        'id': 'CTC',
        'name': 'California Tower Club',
        'city_name': 'Ho Chi Minh',
        'isSelected': false,
      },
      {
        'id': 'DNG',
        'name': 'Da Nang Club',
        'city_name': 'Da Nang',
        'isSelected': false,
      },
      {
        'id': 'FDC',
        'name': 'Flemington Diamond Club',
        'city_name': 'Ho Chi Minh',
        'isSelected': false,
      },
      {
        'id': 'GMC',
        'name': 'Giga Mall Club',
        'city_name': 'Ho Chi Minh',
        'isSelected': false,
      },
      {
        'id': 'GDC',
        'name': 'Goldview Club',
        'city_name': 'Ho Chi Minh',
        'isSelected': false,
      },
      {
        'id': 'GVC',
        'name': 'Go Vap Club',
        'city_name': 'Ho Chi Minh',
        'isSelected': false,
      },
      {
        'id': 'HDC',
        'name': 'Hang Da Galleria',
        'city_name': 'Ha Noi',
        'isSelected': false,
      },
      {
        'id': 'HDY',
        'name': 'Handico Tower',
        'city_name': 'Ha Noi',
        'isSelected': false,
      },
      {
        'id': 'HVP',
        'name': 'Hung Vuong Club',
        'city_name': 'Ho Chi Minh',
        'isSelected': false,
      },
      {
        'id': 'LMC',
        'name': 'Landmark Centuryon Club',
        'city_name': 'Ho Chi Minh',
        'isSelected': false,
      },
      {
        'id': 'LTC',
        'name': 'Lim Tower Club',
        'city_name': 'Ho Chi Minh',
        'isSelected': false,
      },
      {
        'id': 'MAC',
        'name': 'Mac Plaza',
        'city_name': 'Ha Noi',
        'isSelected': false,
      },
      {
        'id': 'MPC',
        'name': 'Mipec Long Bien',
        'city_name': 'Ha Noi',
        'isSelected': false,
      },
      {
        'id': 'NTC',
        'name': 'Nha Trang Club',
        'city_name': 'Nha Trang',
        'isSelected': false,
      },
      {
        'id': 'PBH',
        'name': 'Pegasus Bien Hoa',
        'city_name': 'Bien Hoa',
        'isSelected': false,
      },
      {
        'id': 'PCO',
        'name': 'Pico Club',
        'city_name': 'Ho Chi Minh',
        'isSelected': false,
      },
      {
        'id': 'PCH',
        'name': 'Pico Xuan Thuy',
        'city_name': 'Ha Noi',
        'isSelected': false,
      },
      {
        'id': 'PPC',
        'name': 'Pearl Plaza Club',
        'city_name': 'Ho Chi Minh',
        'isSelected': false,
      },
      {
        'id': 'SCC',
        'name': 'Saigon Centre \nCenturyon Club',
        'city_name': 'Ho Chi Minh',
        'isSelected': false,
      },
      {
        'id': 'SCT',
        'name': 'Sky City Tower',
        'city_name': 'Ha Noi',
        'isSelected': false,
      },
      {
        'id': 'WPC',
        'name': 'SOMERSET WEST POINT',
        'city_name': 'Ha Noi',
        'isSelected': false,
      },
      {'id': 'T&C', 'name': 'T&C', 'city_name': null, 'isSelected': false},
      {
        'id': 'TDU',
        'name': 'Thao Dien Club',
        'city_name': 'Ho Chi Minh',
        'isSelected': false,
      },
      {
        'id': 'TDY',
        'name': 'Thao Dien Yoga Plus Club',
        'city_name': 'Ho Chi Minh',
        'isSelected': false,
      },
      {
        'id': 'TCM',
        'name': 'Times City Mall',
        'city_name': 'Ha Noi',
        'isSelected': false,
      },
      {
        'id': 'TDC',
        'name': 'Thu Duc Club',
        'city_name': 'Ho Chi Minh',
        'isSelected': false,
      },
      {
        'id': 'VMC',
        'name': 'Viet Market Club',
        'city_name': 'Ho Chi Minh',
        'isSelected': false,
      },
      {
        'id': 'VSC',
        'name': 'Vincom Star City',
        'city_name': 'Ha Noi',
        'isSelected': false,
      },
      {
        'id': 'VVO',
        'name': 'Vivo City',
        'city_name': 'Ho Chi Minh',
        'isSelected': false,
      },
      {
        'id': 'VTC',
        'name': 'Vung Tau Club',
        'city_name': 'Vung Tau',
        'isSelected': false,
      },
    ];
    List<Map<String, dynamic>> clubList = [];
    if (_cities.isNotEmpty) {
      clubList = oriClub.where((club) {
        return _cities.any((city) => city['name'] == club['city_name']);
      }).toList();

      //Check cho club đã chọn
      for (var ite in clubList) {
        if (_clubs.any((e) => e['id'] == ite['id'])) {
          ite['isSelected'] = true;
        }
      }
    }

    final List<Map<String, dynamic>> categories = [
      {
        'id': 'service',
        'label': 'schedule.filter_category_service'.tr(),
        'count': serviceList.length,
      },
      {
        'id': 'city',
        'label': 'schedule.filter_category_city'.tr(),
        'count': cityList.length,
      },
      {
        'id': 'club',
        'label': 'schedule.filter_category_club'.tr(),
        'count': clubList.length,
      },
    ];

    String selectedCategoryId = 'service'; // Tab mặc định

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF3E3E3E), // Màu nền đen theo snippet
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        final double bottomPadding = MediaQuery.of(context).padding.bottom;

        return StatefulBuilder(
          builder: (context, setModalState) {
            // LOGIC QUAN TRỌNG: Xác định danh sách hiển thị bên phải dựa trên Tab đang chọn
            List<Map<String, dynamic>> currentOptions = [];
            if (selectedCategoryId == 'service') {
              currentOptions = serviceList;
            } else if (selectedCategoryId == 'city')
              // ignore: curly_braces_in_flow_control_structures
              currentOptions = cityList;
            else if (selectedCategoryId == 'club')
              // ignore: curly_braces_in_flow_control_structures
              currentOptions = clubList;

            return Container(
              width: double.infinity,
              height: context.resH(540),
              padding: const EdgeInsets.only(top: 8),
              child: Column(
                children: [
                  _buildFilterHeader(context),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Sidebar bên trái: Khi nhấn sẽ gọi setModalState để load lại bên phải
                        _buildFilterSidebar(
                          context,
                          categories,
                          selectedCategoryId,
                          (id) {
                            setModalState(() => selectedCategoryId = id);
                          },
                        ),

                        // Section bên phải: Hiển thị danh sách Options động
                        _buildFilterOptions(
                          context,
                          currentOptions,
                          isRadio: selectedCategoryId == 'city',
                          // SỬA TẠI ĐÂY: Gán tên tham số onToggleIndex cho hàm callback
                          onToggleIndex: (index) {
                            setModalState(() {
                              if (selectedCategoryId == 'city') {
                                // LOGIC RADIO BUTTON: Chỉ cho chọn 1 trong danh sách
                                for (var city in cityList) {
                                  city['isSelected'] = false;
                                }
                                cityList[index]['isSelected'] = true;

                                _cities = cityList
                                    .where((club) => club['isSelected'] == true)
                                    .toList();

                                clubList = oriClub.where((club) {
                                  return _cities.any(
                                    (city) => city['name'] == club['city_name'],
                                  );
                                }).toList();
                                categories[2]['count'] = clubList.length;
                                // print(_cities);
                                // print(clubList);
                              } else {
                                // LOGIC CHECKBOX: Cho phép chọn nhiều
                                currentOptions[index]['isSelected'] =
                                    !currentOptions[index]['isSelected'];
                              }
                              if (selectedCategoryId == 'service') {
                                _services = currentOptions
                                    .where((ite) => ite['isSelected'] == true)
                                    .toList();
                                // print(_services);
                              }
                              if (selectedCategoryId == 'club') {
                                _clubs = currentOptions
                                    .where((club) => club['isSelected'] == true)
                                    .toList();
                                // print(currentOptions);
                                // print(_clubs);
                                sClubs = _clubs.map((e) => e['id']).join(',');
                              }
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  _buildFilterActions(context, bottomPadding),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: context.resW(20),
        vertical: context.resH(12),
      ),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFF6B6B6B), width: 0.5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'schedule.btn_filter'.tr(),
            style: TextStyle(
              color: Colors.white,
              fontSize: context.resClamp(16, 15, 18),
              fontWeight: FontWeight.w600,
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF242424),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  // Hàm helper để xử lý việc lấy Date và gọi API ngay lập tức
  void _fetchDataForIndex(int index) {
    // Lấy ngày DateTime gốc từ index
    DateTime selectedDate = _getDateTimeFromIndex(index);

    // Tạo mốc bắt đầu ngày (00:00:00) và kết thúc ngày (23:59:59)
    DateTime start = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      0,
      0,
      0,
    );
    DateTime end = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      23,
      59,
      59,
    );

    // Định dạng chuỗi theo yêu cầu của API
    String fromDateStr = DateFormat('yyyy-MM-dd HH:mm:ss').format(start);
    String toDateStr = DateFormat('yyyy-MM-dd HH:mm:ss').format(end);

    // Gọi API tải dữ liệu
    _fetchSchedulesByDate(fromDateStr, toDateStr);
  }

  Future<void> _fetchSchedulesByDate(String fromDate, String toDate) async {
    try {
      final DateTime nowVietnam = await VietnamTimeService.instance
          .getNowVietnamWithFallback();
      if (!mounted) return;

      // Sử dụng handleApi để quản lý trạng thái loading
      // print('${fromDate} ${toDate} ${sClubs}');
      final response = await handleApi(
        context,
        BaseApi().client.get(
          '/api/booking/get/schedulesByClub', // Change from requirement Mr Dung.
          queryParameters: {
            'from_date': fromDate,
            'to_date': toDate,
            'club_code': sClubs,
          },
        ),
      );

      if (response?.statusCode == 200) {
        // 1. Lấy mảng 'data' từ response
        final List<dynamic> rawData = response?.data['data'] ?? [];

        // 2. Chuyển đổi List JSON thành List<ScheduleModel>
        List<ScheduleModel> fetchedSchedules = rawData
            .map((json) => ScheduleModel.fromJson(json))
            .toList();

        fetchedSchedules =
            fetchedSchedules.where((schedule) {
              final DateTime? startDate = schedule.startDate;
              if (startDate == null) return false;
              return startDate.isAfter(nowVietnam);
            }).toList()..sort((a, b) {
              if (a.startDate == null || b.startDate == null) return 0;
              return a.startDate!.compareTo(b.startDate!);
            });

        // final selectedServiceIds = _services.map((s) => s['name']).toList();
        // // print(selectedServiceIds);
        // fetchedSchedules = fetchedSchedules.where((schedule) {
        //   return selectedServiceIds.contains(schedule.classType.toString());
        // }).toList();
        // // print(fetchedSchedules.length);

        // 3. Cập nhật giao diện
        setState(() {
          _nowVietnam = nowVietnam;
          _schedules = fetchedSchedules;
        });
      }
    } catch (e) {
      debugPrint("Lỗi khi tải lịch tập: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    // DateTime.now().weekday trả về: 1 (Thứ 2) -> 7 (Chủ nhật)
    // Gán index tương ứng: 0 (Thứ 2) -> 6 (Chủ nhật)
    _selectedDateIndex = 0;

    // 2. TỰ ĐỘNG GỌI API NGAY KHI VÀO MÀN HÌNH
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initAndFetchSchedules();
    });
  }

  Future<void> _initAndFetchSchedules() async {
    final DateTime nowVietnam = await VietnamTimeService.instance
        .getNowVietnamWithFallback();
    if (!mounted) return;

    setState(() {
      _nowVietnam = nowVietnam;
    });

    // Tải lại bộ lọc đã lưu trước khi fetch dữ liệu
    await _loadFilterPreferences();

    _fetchDataForIndex(_selectedDateIndex);
  }

  @override
  Widget build(BuildContext context) {
    // 1. Lấy độ cao dải tác vụ (Gesture bar/3-button)
    final double systemBottomPadding = MediaQuery.of(context).padding.bottom;
    // Chiều cao ước tính của CommonBottomNavBar
    final double navBarHeight = context.resH(80);

    return Scaffold(
      backgroundColor: const Color(0xFF151515), // Color-Base-gray
      body: Stack(
        children: [
          // Lớp nền Background mờ (Opacity 0.12)
          CommonBackgroundWidget.buildBackgroundImage(
            context,
            dotenv.get('IMAGES_BG_LOGIN_V3_LAYER'),
          ),

          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                _buildDateStrip(context),
                _buildSectionTitle(context),

                // Danh sách lớp học dạng Grid/Scroll
                // Danh sách lớp học dạng Grid/Scroll
                Expanded(
                  child: _schedules.isEmpty
                      ? Center(
                          // Hiển thị thông báo khi không có dữ liệu
                          child: Text(
                            'schedule.msg_not_found_schedule'.tr(),
                            style: TextStyle(
                              color: const Color(
                                0xFF9A9A9A,
                              ), // Màu xám nhạt đồng bộ thiết kế
                              fontSize: context.resClamp(14, 12, 16),
                              fontFamily: 'Inter',
                            ),
                          ),
                        )
                      : GridView.builder(
                          padding: EdgeInsets.fromLTRB(
                            context.resW(20),
                            context.resH(8),
                            context.resW(20),
                            // QUAN TRỌNG: Đệm đủ cao để Grid không bị lấp dưới Navbar
                            navBarHeight + systemBottomPadding + 20,
                          ),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: context.resW(16),
                                mainAxisSpacing: context.resH(24),
                                childAspectRatio:
                                    0.65, // Tỉ lệ card theo snippet thiết kế
                              ),
                          // SỬA TẠI ĐÂY: Dùng độ dài thực tế của danh sách hứng được
                          itemCount: _schedules.length,
                          itemBuilder: (context, index) {
                            final itemData = _schedules[index];
                            return _buildClassCard(context, itemData, index);
                          },
                        ),
                ),
              ],
            ),
          ),

          // Bottom Navigation Bar (Nếu bạn cần tích hợp vào file này)
          // _buildBottomNav(context, systemBottomPadding),
        ],
      ),
    );
  }

  // MARK: - UI Helpers

  // Widget _buildBackground(BuildContext context) {
  //   return Positioned(
  //     left: -103,
  //     top: 42,
  //     child: Opacity(
  //       opacity: 0.12,
  //       child: Container(
  //         width: context.resW(695),
  //         height: context.resH(795),
  //         decoration: const BoxDecoration(
  //           image: DecorationImage(
  //             image: AssetImage("assets/images/background_login_v3_layer.png"),
  //             fit: BoxFit.cover,
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity, // Thay 375 bằng infinity để tự giãn theo màn hình
      padding: EdgeInsets.only(left: context.resW(20), right: context.resW(8)),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. Cánh trái: Placeholder cho Logo hoặc Tên màn hình
          Container(
            width: context.resW(
              141,
            ), // Độ rộng co giãn theo chiều ngang màn hình
            height: context.resH(
              24,
            ), // Chiều cao co giãn theo chiều dọc màn hình
            clipBehavior: Clip.antiAlias,
            decoration: const BoxDecoration(),
            child: Stack(
              children: [
                // GẮN SVG TẠI ĐÂY
                SvgPicture.asset(
                  'assets/images/logo_cali.svg',
                  width: double
                      .infinity, // Để SVG tự giãn đầy chiều ngang Container
                  height:
                      double.infinity, // Để SVG tự giãn đầy chiều cao Container
                  // QUAN TRỌNG: BoxFit.contain giúp logo luôn giữ đúng tỉ lệ
                  // và nằm gọn trong khung (141x24) mà không bị méo
                  fit: BoxFit.contain,

                  // Bạn có thể đổi màu logo sang trắng hoặc màu khác tại đây nếu cần
                  // colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                ),
              ],
            ),
          ),

          // 2. Cánh phải: Cụm Icon Buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            // Sử dụng spacing theo đúng code gốc của bạn
            children: [
              // ICON 1: Thông báo
              _buildLanguageButton(),

              // Khoảng cách giữa 2 icon (thay cho spacing: 10 nếu Flutter bản cũ)
              SizedBox(width: context.resW(10)),

              // ICON 2: Tìm kiếm
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HistoryScheduleScreen(),
                    ),
                  );
                },
                child: _buildIconButton(
                  context,
                  'assets/images/vuesax/document-text.svg',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Hàm phụ để tạo các nút icon có bo tròn 40px theo snippet
  Widget _buildIconButton(BuildContext context, String svgPath) {
    return Container(
      // 1. Padding responsive để vùng chạm co giãn theo màn hình
      padding: EdgeInsets.all(context.resW(12)),
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 2. Kích thước khung chứa icon responsive
          SizedBox(
            width: context.resW(24),
            height: context.resW(24),
            // 3. Sử dụng SvgPicture thay cho Icon
            child: SvgPicture.asset(
              svgPath,
              // Sử dụng ColorFilter để đổi màu icon sang trắng
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateStrip(BuildContext context) {
    // 1. Lấy ngày Thứ 2 của tuần hiện tại
    // DateTime now = DateTime.now();
    // DateTime monday = now.subtract(Duration(days: now.weekday - 1));

    // 2. Tạo danh sách nhãn hiển thị Thứ
    // final List<String> dayLabels = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

    return Container(
      height: context.resH(80),
      padding: EdgeInsets.symmetric(horizontal: context.resW(20)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(7, (index) {
          // Tính toán ngày dựa trên độ lệch (offset) từ hôm nay
          DateTime targetDate = _getDateTimeFromIndex(index);
          bool isSelected = index == _selectedDateIndex;

          return GestureDetector(
            onTap: () {
              setState(() => _selectedDateIndex = index);
              // GỌI API NGAY KHI CLICK
              _fetchDataForIndex(index);
            },
            child: Container(
              width: context.resW(42), // Tăng nhẹ để tránh bị cắt chữ số lớn
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFDA2128)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
                border: isSelected
                    ? null
                    : Border.all(color: const Color(0xFF3E3E3E)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Hiển thị Thứ (T2, T3...)
                  Text(
                    _getDayLabel(targetDate), // Thứ thay đổi động
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF9A9A9A),
                      fontSize: context.resClamp(12, 10, 14),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Hiển thị Ngày (15, 16...)
                  Text(
                    targetDate.day.toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: context.resClamp(14, 12, 16),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: context.resW(20),
        vertical: context.resH(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${'schedule.lbl_schedule'.tr()} (${_schedules.length})',
            style: TextStyle(
              color: Colors.white,
              fontSize: context.resClamp(14, 12, 16),
              fontWeight: FontWeight.w600,
            ),
          ),
          // SỬA TẠI ĐÂY: Thêm sự kiện click mở bộ lọc
          GestureDetector(
            onTap: _showFilterBottomSheet,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.filter_list, color: Colors.white, size: 20),
                if (_services.length + _cities.length + _clubs.length > 0)
                  Positioned(
                    top: -6,
                    right: -6,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: Color(0xFFDA2128),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${_services.length + _cities.length + _clubs.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassCard(BuildContext context, ScheduleModel data, int index) {
    // Tăng độ bo góc lên 12 để mềm mại hơn
    final double cardRadius = 12.0;

    final List<String> watermarks = [
      'assets/images/watermark/image 1527.png',
      'assets/images/watermark/image 1526.png',
      'assets/images/watermark/image 1556.png',
    ];
    final String selectedWatermark = watermarks[index % watermarks.length];

    return GestureDetector(
      // 1. CLICK ĐỂ CHUYỂN MÀN HÌNH CHI TIẾT
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ScheduleDetailScreen(schedule: data),
          ),
        );
      },
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          color: const Color(0xFF3E3E3E),
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 2, color: Color(0xFFEF4822)),
            borderRadius: BorderRadius.circular(cardRadius),
          ),
          // Đổ bóng cứng theo phong cách thiết kế của bạn
          shadows: const [
            BoxShadow(
              color: Color(0xFF545152),
              offset: Offset(5, 5),
              blurRadius: 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Phần hình ảnh bo góc trên
            ClipRRect(
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(cardRadius),
              ),
              child: Container(
                height: context.resH(152), // Chiều cao responsive
                width: double.infinity,
                color: Colors.white,
                child: Image.asset(
                  ImageHelper.getClassThumbnail(data.classType),
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) =>
                      Image.asset("assets/images/none.jpg", fit: BoxFit.cover),
                ),
              ),
            ),
            // Phần nội dung thông tin lớp học
            Expanded(
              child: Stack(
                children: [
                  // 2. GẮN WATERMARK TRONG SUỐT CANH DƯỚI PHẢI
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Opacity(
                      opacity: 0.8, // Độ mờ mượt mà theo hình mẫu
                      child: Container(
                        width: context.resW(
                          87,
                        ), // Kích thước khung 87x77 responsive
                        height: context.resH(77),
                        alignment: Alignment.bottomRight,
                        child: Image.asset(
                          selectedWatermark,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.all(
                      context.resW(8),
                    ), // Padding responsive
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          data.className ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Color(0xFFFFA514),
                            fontSize: context.resClamp(
                              13,
                              11,
                              15,
                            ), // Font co giãn
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        _buildIconRow(
                          context,
                          Icons.calendar_today,
                          DateFormat(
                            'dd/MM/yyyy',
                          ).format(data.startDate ?? DateTime.now()),
                        ),
                        _buildIconRow(
                          context,
                          Icons.access_time,
                          '${DateFormat('hh:mm a').format(data.startDate ?? DateTime.now())} - ${DateFormat('hh:mm a').format(data.endDate ?? DateTime.now())}',
                        ),
                        _buildIconRow(
                          context,
                          Icons.location_on_outlined,
                          data.clubName ?? '',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconRow(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF9A9A9A), size: context.resW(12)),
        SizedBox(width: context.resW(4)),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: const Color(0xFF9A9A9A),
              fontSize: context.resClamp(10, 9, 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageButton() {
    final currentCode = context.locale.languageCode;
    return GestureDetector(
      onTap: () => LanguageBottomSheet.show(context: context),
      child: Row(
        children: [
          SvgPicture.asset(
            currentCode == 'vi'
                ? 'assets/images/vietnam.svg'
                : 'assets/images/kingdom.svg',
            width: 20,
          ),
          const SizedBox(width: 8),
          Text(
            currentCode == 'vi' ? 'common.lang_vi'.tr() : 'common.lang_en'.tr(),
            style: TextStyle(
              color: Colors.white,
              fontSize: context.resClamp(12, 10, 14), // Responsive
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterOptions(
    BuildContext context,
    List<Map<String, dynamic>> items, { // Đã bỏ VoidCallback? onToggle thừa
    bool isRadio = false,
    required Function(int) onToggleIndex,
  }) {
    return Expanded(
      child: ListView.builder(
        padding: EdgeInsets.symmetric(vertical: context.resH(8)),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          bool isSelected = item['isSelected'] ?? false;

          return GestureDetector(
            onTap: () => onToggleIndex(index), // Sử dụng đúng onToggleIndex
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: context.resW(16),
                vertical: context.resH(12),
              ),
              color: Colors.transparent,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item['name'] ?? '',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: context.resClamp(14, 13, 15),
                      fontWeight: isSelected
                          ? FontWeight.w500
                          : FontWeight.w400,
                    ),
                  ),

                  // UI Radio hoặc Checkbox
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFD92229)
                          : Colors.transparent,
                      shape: isRadio ? BoxShape.circle : BoxShape.rectangle,
                      borderRadius: isRadio ? null : BorderRadius.circular(4),
                      border: isSelected
                          ? null
                          : Border.all(color: const Color(0xFF6B6B6B)),
                    ),
                    child: isSelected
                        ? (isRadio
                              ? Center(
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                )
                              : const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 16,
                                ))
                        : null,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterActions(BuildContext context, double bottomPadding) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        bottomPadding > 0 ? bottomPadding : 20,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF3E3E3E),
        border: Border(top: BorderSide(color: Colors.white10, width: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _services = [];
                  _cities = [];
                  _clubs = [];
                  sClubs = '';
                });
                _clearFilterPreferences();
                _fetchDataForIndex(_selectedDateIndex);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(
                  0xFF555555,
                ), // Màu xám cho nút Reset
                minimumSize: Size(0, context.resH(48)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'schedule.btn_clear_filter'.tr(),
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                _fetchDataForIndex(_selectedDateIndex);
                _saveFilterPreferences();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD92229), // Màu đỏ nút Áp dụng
                minimumSize: Size(0, context.resH(48)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'schedule.btn_search'.tr(),
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSidebar(
    BuildContext context,
    List<Map<String, dynamic>> cats,
    String selectedId,
    Function(String) onSelect,
  ) {
    return Container(
      width: context.resW(150),
      color: const Color(0xFF242424), // Sidebar xám đậm
      child: ListView.builder(
        itemCount: cats.length,
        itemBuilder: (context, index) {
          final cat = cats[index];
          bool isSelected = selectedId == cat['id'];
          return GestureDetector(
            onTap: () => onSelect(cat['id']),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: context.resW(20),
                vertical: context.resH(16),
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF3E3E3E)
                    : Colors.transparent,
                border: Border(
                  left: BorderSide(
                    color: isSelected
                        ? const Color(0xFFD92229)
                        : Colors.transparent,
                    width: 4,
                  ),
                ),
              ),
              child: Text(
                '${cat['label']} (${cat['count']})',
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF9A9A9A),
                  fontSize: context.resClamp(14, 13, 15),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
