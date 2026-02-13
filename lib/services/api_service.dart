import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:math';
import 'package:californiaflutter/models/member_model.dart';

Future<String> getToken() async {
  final response = await http.post(
    Uri.parse('https://booking-stg.cali.vn/api/login'),
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
  return 1000 + random.nextInt(9999);
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
    // print(member.listMembershipCard?.length);
    // print(member.listMembershipCard?[0].membershipType);
    // print(member.listMembershipCard?[1].membershipType);
    // print(member.listMembershipCard?[2].membershipType);
    // print(member.listMembershipCard?[3].membershipType);
    return member;
  } else {
    throw Exception('Get member failed');
  }
}
