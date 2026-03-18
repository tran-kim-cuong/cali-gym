import 'package:californiaflutter/helpers/session_manager.dart';
import 'package:californiaflutter/helpers/size_utils.dart';
import 'package:californiaflutter/pages/shared/common_background.dart';
import 'package:californiaflutter/pages/shared/common_modal.dart';
import 'package:californiaflutter/services/api_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class TowelOrdersScreen extends StatefulWidget {
  const TowelOrdersScreen({super.key});

  @override
  State<TowelOrdersScreen> createState() => _TowelOrdersScreenState();
}

class _TowelOrdersScreenState extends State<TowelOrdersScreen> {
  List<dynamic> _orders = [];
  bool _isLoading = true;
  String? _error;
  String? _selectedTicketCode;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final token = await SessionManager.getToken();
      if (token == null) throw Exception('Token not found');
      final orders = await getTowelOrders(token, SessionManager.sClientId);
      if (mounted) {
        setState(() {
          _orders = orders;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  String _formatDate(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr.replaceFirst(' ', 'T'));
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentOrders = _orders
        .where((o) => o['status_code'] != 'odpr_returned')
        .toList();
    final pastOrders = _orders
        .where((o) => o['status_code'] == 'odpr_returned')
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFF151515),
      body: Stack(
        children: [
          CommonBackgroundWidget.buildBackgroundImage(
            context,
            dotenv.get('IMAGES_BG_BENEFIT_V3_LAYER'),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFFD92229),
                          ),
                        )
                      : _error != null
                      ? Center(
                          child: Text(
                            'Không thể tải đơn hàng',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: context.resClamp(14, 12, 16),
                              fontFamily: 'Inter',
                            ),
                          ),
                        )
                      : _orders.isEmpty
                      ? Center(
                          child: Text(
                            'Chưa có đơn hàng nào',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: context.resClamp(14, 12, 16),
                              fontFamily: 'Inter',
                            ),
                          ),
                        )
                      : SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.fromLTRB(
                            context.resW(16),
                            0,
                            context.resW(16),
                            context.resH(20),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (currentOrders.isNotEmpty) ...[
                                Padding(
                                  padding: EdgeInsets.only(
                                    bottom: context.resH(8),
                                  ),
                                  child: Text(
                                    'Chọn ID đơn hàng để trả lại sản phẩm',
                                    style: TextStyle(
                                      color: const Color(0xFF9A9A9A),
                                      fontSize: context.resClamp(12, 10, 14),
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                ),
                              ],
                              if (currentOrders.isNotEmpty) ...[
                                ...currentOrders.map(
                                  (order) => _buildOrderGroup(
                                    order,
                                    isReturned: false,
                                  ),
                                ),
                                if (_selectedTicketCode != null)
                                  _buildReturnButton(),
                                SizedBox(height: context.resH(20)),
                              ],
                              if (pastOrders.isNotEmpty) ...[
                                Padding(
                                  padding: EdgeInsets.only(
                                    bottom: context.resH(12),
                                  ),
                                  child: Text(
                                    'Đơn hàng trước',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: context.resClamp(16, 14, 18),
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                ...pastOrders.map(
                                  (order) =>
                                      _buildOrderGroup(order, isReturned: true),
                                ),
                              ],
                            ],
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

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 4, left: 8, right: 20, bottom: 4),
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
            'Đơn bạn đã đặt',
            style: TextStyle(
              color: Colors.white,
              fontSize: context.resClamp(18, 16, 22),
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderGroup(
    Map<String, dynamic> order, {
    required bool isReturned,
  }) {
    final ticketCode = order['ticket_code'] ?? '';
    final products = (order['products'] as List?) ?? [];
    final takenAt = order['taken_at'] ?? '';
    final isSelected = _selectedTicketCode == ticketCode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Order ticket code row
        GestureDetector(
          onTap: !isReturned
              ? () {
                  setState(() {
                    _selectedTicketCode = isSelected ? null : ticketCode;
                  });
                }
              : null,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: context.resH(8)),
            child: Row(
              children: [
                if (!isReturned)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 22,
                    height: 22,
                    margin: EdgeInsets.only(right: context.resW(10)),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFFD92229)
                            : Colors.white54,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(4),
                      color: isSelected
                          ? const Color(0xFFD92229)
                          : Colors.transparent,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, size: 15, color: Colors.white)
                        : null,
                  ),
                Text(
                  'Mã đơn hàng : $ticketCode',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: context.resClamp(14, 12, 16),
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Product cards
        ...products.map<Widget>((product) {
          return _buildProductCard(
            product,
            takenAt: takenAt,
            orderDate: _formatDate(order['created_at'] ?? ''),
            isReturned: isReturned,
          );
        }),
        SizedBox(height: context.resH(4)),
      ],
    );
  }

  Widget _buildProductCard(
    Map<String, dynamic> product, {
    required String takenAt,
    required String orderDate,
    required bool isReturned,
  }) {
    final locale = context.locale.languageCode;
    final name = locale == 'vi'
        ? (product['name'] ?? product['name_en'] ?? '')
        : (product['name_en'] ?? product['name'] ?? '');
    final quantity = product['quantity'] ?? 1;
    final statusLabel = locale == 'vi'
        ? (product['status_vi'] ?? product['status_en'] ?? '')
        : (product['status_en'] ?? product['status_vi'] ?? '');
    final returnAt = product['return_at'] ?? '';

    final statusCode = product['status_code'] ?? '';
    final isProductReturned = statusCode == 'odpr_returned';

    return Container(
      margin: EdgeInsets.only(bottom: context.resH(8)),
      padding: EdgeInsets.symmetric(
        horizontal: context.resW(14),
        vertical: context.resH(10),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF242424),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '$name ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: context.resClamp(14, 12, 16),
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(
                        text: 'x$quantity',
                        style: TextStyle(
                          color: const Color(0xFF4DB6AC),
                          fontSize: context.resClamp(14, 12, 16),
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.resW(10),
                  vertical: context.resH(4),
                ),
                decoration: BoxDecoration(
                  color: isProductReturned
                      ? const Color(0xFF3D6B5A)
                      : const Color(0xFF2E7D60),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: context.resClamp(12, 10, 14),
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: context.resH(6)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (takenAt.isNotEmpty)
                      Text(
                        'Nơi nhận $takenAt',
                        style: TextStyle(
                          color: const Color(0xFF9A9A9A),
                          fontSize: context.resClamp(12, 10, 14),
                          fontFamily: 'Inter',
                        ),
                      ),
                    if (isProductReturned && returnAt.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: context.resH(2)),
                        child: Text(
                          'Nơi trả $returnAt',
                          style: TextStyle(
                            color: const Color(0xFF9A9A9A),
                            fontSize: context.resClamp(12, 10, 14),
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (orderDate.isNotEmpty)
                Text(
                  orderDate,
                  style: TextStyle(
                    color: const Color(0xFF9A9A9A),
                    fontSize: context.resClamp(12, 10, 14),
                    fontFamily: 'Inter',
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _onReturnPressed() async {
    final ticketCode = _selectedTicketCode;
    if (ticketCode == null) return;

    final int milliseconds = DateTime.now()
        .add(const Duration(hours: 7))
        .millisecondsSinceEpoch;
    final String sSecrect =
        '${SessionManager.sClientId}flg2022towel$milliseconds$ticketCode';
    final String sMd5 = generateMd5(sSecrect);

    final StringBuffer buffer = StringBuffer();
    buffer.write(dotenv.get('CALIFORNIA_URI'));
    buffer.write('/towel/checker?');
    buffer.write('clientcode=${SessionManager.sClientId}');
    buffer.write('&ticket=$ticketCode');
    buffer.write('&t=$milliseconds');
    buffer.write('&secrect=$sMd5');
    buffer.write('&type=view');

    debugPrint('=== TOWEL RETURN QR URL ===');
    debugPrint(buffer.toString());
    debugPrint('===========================');

    await CommonModalWidget.showBigQrModal(
      context: context,
      qrData: buffer.toString(),
      instructionText:
          'Vui lòng xuất trình mã QR này tại quầy lễ tân để hoàn trả sản phẩm. Xin cảm ơn.',
      closeButtonText: 'Đóng',
    );

    // Reload data sau khi đóng modal
    setState(() => _selectedTicketCode = null);
    _fetchOrders();
  }

  Widget _buildReturnButton() {
    return SizedBox(
      width: double.infinity,
      height: context.resH(48).clamp(44, 56),
      child: ElevatedButton(
        onPressed: _onReturnPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFD92229),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          elevation: 0,
        ),
        child: Text(
          'Hoàn trả',
          style: TextStyle(
            color: Colors.white,
            fontSize: context.resClamp(16, 14, 18),
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
