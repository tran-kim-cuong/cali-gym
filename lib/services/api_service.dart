import 'dart:convert';
import 'package:californiaflutter/models/booking_class_model.dart';
import 'package:californiaflutter/models/booking_class_seat_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:math';
import 'package:californiaflutter/models/member_model.dart';
import 'package:crypto/crypto.dart';

Future<String> getToken() async {
  final response = await http.post(
    Uri.parse('${dotenv.get('CALIFORNIA_URI')}/api/login'),
    headers: {'Accept': 'application/json'},
    body: {'email': 'api@livwell.asia', 'password': "X'YS}4Fhdxg*q7AJ"},
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['token']; // hoặc transactionId
  } else {
    throw Exception('Get OTP failed');
  }
}

Future<int> snedSms(String otp, String phoneNumber) async {
  final response = await http.post(
    Uri.parse('https://web-api.cfyc.asia/api/sms/send'),
    headers: {'Accept': 'application/json'},
    body: {
      'phone_number': phoneNumber,
      'api_key': "gprVEgtgzqbk8h2zdvdsvsbypLV3qwYdzYwTYuDL",
      'message':
          'Cali.vn - Ma xac thuc cua ban tren website https://cali.vn la $otp',
      'brand_name': "Cali.vn",
      'sender': "esms",
    },
  );

  if (response.statusCode == 200) {
    return 1;
  } else {
    throw Exception('Get Club failed');
  }
}

int gen4Digits() {
  final random = Random();
  // nextInt(9000) trả về từ 0 đến 8999
  // 1000 + 0 = 1000 (Min 4 chữ số)
  // 1000 + 8999 = 9999 (Max 4 chữ số)
  return 1000 + random.nextInt(9000);
}

Future<MemberModel> getMember(
  String token,
  String clientId,
  String phone,
) async {
  final response = await http.post(
    Uri.parse('https://booking-stg.cali.vn/api/booking/check/member'),
    headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    body: {'clientcode': clientId, 'phone_number': phone},
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    MemberModel member = MemberModel.fromJson(data['data']);
    return member;
  } else {
    throw Exception('Get member failed');
  }
}

Future<BookingClassModel> getBookingClass(String token, String clientId) async {
  final response = await http.post(
    Uri.parse(
      'https://booking-stg.cali.vn/api/booking/post/getUserBookedClasses',
    ),
    headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    body: {'clientcode': clientId},
  );

  if (response.statusCode == 200) {
    final jsonResponse = jsonDecode(response.body);
    BookingClassModel model = BookingClassModel.fromJson(jsonResponse);
    return model;
  } else {
    throw Exception('Get member failed');
  }
}

Future<BookingClassSeatModel> bookingClassSeat(
  String token,
  String clinetId,
  String phoneNumber,
  String scheduleId,
  String seat,
) async {
  final response = await http.post(
    Uri.parse('https://booking-stg.cali.vn/api/booking/seat/book'),
    headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    body: {
      'clientcode': clinetId,
      'phone_number': phoneNumber,
      'schedule_id': scheduleId,
      'seat_number': seat,
    },
  );

  if (response.statusCode == 200) {
    final jsonResponse = jsonDecode(response.body);
    // print(jsonResponse);
    BookingClassSeatModel model = BookingClassSeatModel.fromJson(jsonResponse);
    // print("============");
    if (model.data != null) {
      // print(model.data?.ticketInfo?.ticketNumber);
    } else {
      debugPrint("lỗi trùng");
    }
    return model;
  } else {
    throw Exception('Get Club failed');
  }
}

Future<int> bookingCancel(
  String token,
  String clinetId,
  String ticketNumber,
) async {
  final response = await http.post(
    Uri.parse('https://booking-stg.cali.vn/api/booking/seat/delete'),
    headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    body: {'clientcode': clinetId, 'ticket_number': ticketNumber},
  );

  if (response.statusCode == 200) {
    return 1;
  } else {
    return 0;
  }
}

String createQRCheckIn(String membership, String keyCode) {
  /// ===== SERVER TIME (GMT+7 ví dụ) =====
  final now = DateTime.now().toUtc().add(const Duration(hours: 7));

  String two(int n) => n.toString().padLeft(2, '0');

  /// date + month + hour
  String time = two(now.day) + two(now.month) + two(now.hour);

  /// membership + '?' + time
  String mbsTime = "$membership?$time";

  /// ===== tính sum giống JS =====
  int sum = 0;

  for (int i = 0; i < mbsTime.length; i++) {
    sum += keyCode.indexOf(mbsTime[i]); // kể cả -1
  }

  /// JS modulo luôn dương → Dart cần fix
  int index = sum % keyCode.length;
  if (index < 0) {
    index += keyCode.length;
  }

  String key = keyCode[index];

  return mbsTime + key;
}

String generateMd5(String input) {
  // convert string -> bytes (UTF8)
  var bytes = utf8.encode(input);

  // mã hóa MD5
  var digest = md5.convert(bytes);

  return digest.toString();
}
