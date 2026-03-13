import 'package:californiaflutter/bases/app_session.dart';
import 'package:californiaflutter/bases/loading_wrapper.dart';
import 'package:californiaflutter/helpers/image_helper.dart';
import 'package:californiaflutter/helpers/size_utils.dart';
import 'package:californiaflutter/models/booking_class_model.dart';
import 'package:californiaflutter/pages/shared/common_background.dart';
import 'package:californiaflutter/services/booking_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/svg.dart';

class HistoryScheduleScreen extends StatefulWidget {
  final bool hasBottomActions;

  const HistoryScheduleScreen({super.key, this.hasBottomActions = false});

  @override
  State<HistoryScheduleScreen> createState() => _HistoryScheduleScreenState();
}

class _HistoryScheduleScreenState extends State<HistoryScheduleScreen>
    with LoadingWrapper {
  bool _isCompletedSelected = true;
  List<BookingData> _allClasses = [];

  List<BookingData> get _filteredClasses => _allClasses
      .where(
        (c) => _isCompletedSelected
            ? (c.confirmed == true)
            : (c.confirmed != true),
      )
      .toList();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchClasses());
  }

  Future<void> _fetchClasses() async {
    try {
      final List<BookingData> rs =
          await handleApi(
            context,
            BookingService.getUpcomingClasses(AppSession().clientId),
          ) ??
          [];
      if (mounted) {
        setState(() {
          _allClasses = rs
            ..sort((a, b) {
              if (a.startDate == null || b.startDate == null) return 0;
              return b.startDate!.compareTo(a.startDate!);
            });
        });
      }
    } catch (e) {
      debugPrint('HistoryScheduleScreen error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final double systemBottomPadding = MediaQuery.of(context).padding.bottom;
    final List<BookingData> displayList = _filteredClasses;

    return Scaffold(
      backgroundColor: const Color(0xFF151515),
      body: Stack(
        children: [
          CommonBackgroundWidget.buildBackgroundImage(
            context,
            dotenv.get('IMAGES_BG_BENEFIT_V3_LAYER'),
          ),
          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── HEADER ──────────────────────────────────────────────
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

                // ── TABS ─────────────────────────────────────────────────
                Row(
                  children: [
                    _buildTabItem(
                      context,
                      'Hoàn thành',
                      isSelected: _isCompletedSelected,
                      onTap: () => _handleMainTabChange(true),
                    ),
                    _buildTabItem(
                      context,
                      'Chưa hoàn thành',
                      isSelected: !_isCompletedSelected,
                      isError: true,
                      onTap: () => _handleMainTabChange(false),
                    ),
                  ],
                ),

                // ── LIST ─────────────────────────────────────────────────
                Expanded(
                  child: RefreshIndicator(
                    color: const Color(0xFFD92229),
                    backgroundColor: const Color(0xFF242424),
                    onRefresh: _fetchClasses,
                    child: displayList.isEmpty
                        ? _buildEmptyState(context)
                        : ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: EdgeInsets.fromLTRB(
                              context.resW(20),
                              context.resH(12),
                              context.resW(20),
                              systemBottomPadding + context.resH(20),
                            ),
                            itemCount: displayList.length,
                            itemBuilder: (context, index) => _buildHistoryItem(
                              context,
                              index,
                              displayList[index],
                            ),
                          ),
                  ),
                ),

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
      bottomNavigationBar: widget.hasBottomActions
          ? _buildDummyActionBar(context, systemBottomPadding)
          : null,
    );
  }

  // ── HISTORY CARD ──────────────────────────────────────────────────────────
  Widget _buildHistoryItem(BuildContext context, int index, BookingData item) {
    final List<String> watermarks = [
      'assets/images/watermark/image 1527.png',
      'assets/images/watermark/image 1526.png',
      'assets/images/watermark/image 1556.png',
    ];
    final String selectedWatermark = watermarks[index % watermarks.length];
    final bool isCompleted = item.confirmed == true;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: context.resH(16)),
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: const Color(0xFF3E3E3E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(context.resW(4)),
          side: BorderSide(
            color: isCompleted
                ? const Color(0xFF4CAF50)
                : const Color(0xFF6B6B6B),
            width: 1.5,
          ),
        ),
      ),
      child: Column(
        children: [
          // ── TOP ROW (image + info) ───────────────────────────────────
          Stack(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thumbnail image
                  SizedBox(
                    width: context.resW(140),
                    height: context.resH(130),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          ImageHelper.getClassThumbnail(item.classType),
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => Image.asset(
                            'assets/images/none.jpg',
                            fit: BoxFit.cover,
                          ),
                        ),
                        if (isCompleted)
                          Container(
                            color: Colors.black.withValues(alpha: 0.35),
                          ),
                      ],
                    ),
                  ),

                  // Info section
                  Expanded(
                    child: Stack(
                      children: [
                        // Watermark
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Opacity(
                            opacity: 0.8,
                            child: SizedBox(
                              width: context.resW(87),
                              height: context.resH(77),
                              child: Image.asset(
                                selectedWatermark,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),

                        // Text content
                        Padding(
                          padding: EdgeInsets.fromLTRB(
                            context.resW(12),
                            context.resH(12),
                            context.resW(8),
                            context.resH(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Service name
                              Padding(
                                padding: EdgeInsets.only(
                                  right: context.resW(90),
                                ),
                                child: Text(
                                  item.serviceName ?? 'N/A',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: isCompleted
                                        ? const Color(0xFF9A9A9A)
                                        : const Color(0xFFF7941D),
                                    fontSize: context.resClamp(15, 13, 17),
                                    fontWeight: FontWeight.bold,
                                    height: 1.2,
                                  ),
                                ),
                              ),
                              SizedBox(height: context.resH(10)),
                              _buildIconInfo(
                                context,
                                Icons.calendar_month_outlined,
                                DateFormat(
                                  'dd/MM/yyyy HH:mm',
                                ).format(item.startDate!),
                              ),
                              _buildIconInfo(
                                context,
                                Icons.location_on_outlined,
                                item.clubName ?? 'N/A',
                              ),
                              _buildIconInfo(
                                context,
                                Icons.category_outlined,
                                (item.classType ?? 'N/A').toUpperCase(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Status badge
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.resW(10),
                    vertical: context.resH(6),
                  ),
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFF9A9A9A),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(context.resW(8)),
                    ),
                  ),
                  child: Text(
                    isCompleted ? 'Hoàn thành' : 'Chưa xong',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ── RATING BUTTON (completed only) ───────────────────────────
          if (isCompleted)
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: Color(0xFF4D4D4D), width: 1),
                ),
              ),
              child: TextButton.icon(
                onPressed: () => _showRatingBottomSheet(context, item),
                icon: Icon(
                  Icons.star_outline_rounded,
                  color: const Color(0xFFFFB359),
                  size: context.resW(18),
                ),
                label: Text(
                  'Đánh giá lớp học',
                  style: TextStyle(
                    color: const Color(0xFFFFB359),
                    fontSize: context.resClamp(13, 12, 15),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── RATING BOTTOM SHEET ───────────────────────────────────────────────────
  void _showRatingBottomSheet(BuildContext context, BookingData item) {
    int selectedRating = 0;
    final TextEditingController commentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx2, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx2).viewInsets.bottom,
              ),
              child: Container(
                padding: EdgeInsets.all(context.resW(24)),
                decoration: BoxDecoration(
                  color: const Color(0xFF242424),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(context.resW(20)),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle bar
                    Center(
                      child: Container(
                        width: context.resW(40),
                        height: context.resH(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6B6B6B),
                          borderRadius: BorderRadius.circular(context.resW(2)),
                        ),
                      ),
                    ),
                    SizedBox(height: context.resH(20)),

                    // Title
                    Text(
                      'Đánh giá lớp học',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: context.resClamp(18, 16, 20),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: context.resH(4)),
                    Text(
                      item.serviceName ?? '',
                      style: TextStyle(
                        color: const Color(0xFF9A9A9A),
                        fontSize: context.resClamp(13, 12, 15),
                      ),
                    ),
                    SizedBox(height: context.resH(2)),
                    Text(
                      DateFormat('dd/MM/yyyy HH:mm').format(item.startDate!),
                      style: TextStyle(
                        color: const Color(0xFF6B6B6B),
                        fontSize: context.resClamp(12, 11, 14),
                      ),
                    ),
                    SizedBox(height: context.resH(24)),

                    // Star rating row
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (i) {
                          return GestureDetector(
                            onTap: () =>
                                setModalState(() => selectedRating = i + 1),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: context.resW(6),
                              ),
                              child: Icon(
                                i < selectedRating
                                    ? Icons.star_rounded
                                    : Icons.star_outline_rounded,
                                color: const Color(0xFFFFB359),
                                size: context.resW(40),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    SizedBox(height: context.resH(20)),

                    // Comment input
                    TextField(
                      controller: commentController,
                      maxLines: 3,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Chia sẻ cảm nhận của bạn...',
                        hintStyle: const TextStyle(color: Color(0xFF6B6B6B)),
                        filled: true,
                        fillColor: const Color(0xFF3E3E3E),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(context.resW(12)),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.all(context.resW(12)),
                      ),
                    ),
                    SizedBox(height: context.resH(20)),

                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE04A50),
                          disabledBackgroundColor: const Color(0xFF6B6B6B),
                          minimumSize: Size(double.infinity, context.resH(50)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              context.resW(12),
                            ),
                          ),
                        ),
                        onPressed: selectedRating == 0
                            ? null
                            : () async {
                                Navigator.pop(ctx);
                                final result = await handleApi(
                                  context,
                                  BookingService.submitClassReview(
                                    clientCode: AppSession().clientId,
                                    scheduleId: item.scheduleId ?? 0,
                                    rate: selectedRating,
                                    description: commentController.text.trim(),
                                  ),
                                );
                                if (!mounted) return;
                                final isSuccess = result?['success'] == true;
                                final message = isSuccess
                                    ? (result?['message'] as String? ??
                                          'class_detail.class_already_evaluated'
                                              .tr())
                                    : 'class_detail.class_already_evaluated'
                                          .tr();

                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(message),
                                    backgroundColor: isSuccess
                                        ? const Color(0xFF4CAF50)
                                        : const Color(0xFFE04A50),
                                  ),
                                );
                              },
                        child: Text(
                          'Gửi đánh giá',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: context.resClamp(16, 14, 18),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: context.resH(8)),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ── EMPTY STATE ───────────────────────────────────────────────────────────
  Widget _buildEmptyState(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            Container(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    dotenv.get('VUESAX_NO_DOCUMENT'),
                    width: context.resW(120),
                    height: context.resW(120),
                  ),
                  SizedBox(height: context.resH(16)),
                  Text(
                    'Hiện không có lớp học nào',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xFF9A9A9A),
                      fontSize: context.resClamp(14, 12, 16),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // ── SHARED WIDGETS ────────────────────────────────────────────────────────
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
    setState(() => _isCompletedSelected = isCompleted);
  }

  Widget _buildHeaderIcon(BuildContext context, String icon) {
    return Container(
      padding: EdgeInsets.all(context.resW(8)),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white12),
        borderRadius: BorderRadius.circular(context.resW(8)),
      ),
      child: SvgPicture.asset(
        icon,
        width: context.resW(20),
        height: context.resW(20),
        fit: BoxFit.contain,
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

  Widget _buildDummyActionBar(BuildContext context, double bottomPadding) {
    return Container(
      color: const Color(0xFF151515),
      padding: EdgeInsets.fromLTRB(
        context.resW(16),
        context.resH(10),
        context.resW(16),
        bottomPadding > 0 ? bottomPadding : context.resH(24),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE04A50),
          minimumSize: Size(double.infinity, context.resH(50)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(context.resW(12)),
          ),
        ),
        onPressed: () {},
        child: Text(
          'Tìm lớp học mới',
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
