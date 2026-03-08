import 'package:californiaflutter/bases/base_api.dart';
import 'package:californiaflutter/models/user_card_model.dart';
import 'package:dio/dio.dart';

class CommonUserShareCardService {
  static Future<List<CardUserModel>> loadUsersSharedCard(
    String membershipNumber,
    String basicAuthorization,
  ) async {
    final response = await BaseApi().crmClient.get(
      "/api/v1/mbs/GetGuestCardForLivWellApp",
      queryParameters: {"CardNumber": membershipNumber},
      options: Options(headers: {'Authorization': basicAuthorization}),
    );

    if (response.statusCode == 200 && response.data != null) {
      final List<dynamic>? raws = response.data['Data'];
      return raws?.map((item) {
            return CardUserModel(
              fullName: item['fullName'],
              clientId: item['clientId'],
              phoneNumber: item['phoneNumber'],
              isActive: item['isActive'],
            );
          }).toList() ??
          [];
    }

    return [];
  }

  static Future<(String?, int)> confirmUserShareCard(
    String membershipNumber,
    String basicAuthorization,
    String clientIdOfUserSelected, {
    String languageCode = "vi",
  }) async {
    final response = await BaseApi().crmClient.post(
      "/api/v1/mbs/AddGuestToMBSForLivWellApp",
      queryParameters: {
        "MembershipId": membershipNumber,
        "ClientId": clientIdOfUserSelected,
        "IsActive": true,
      },
      data: {
        "MembershipId": membershipNumber,
        "ClientId": clientIdOfUserSelected,
        "IsActive": true,
      },
      options: Options(headers: {'Authorization': basicAuthorization}),
    );

    if (response.statusCode == 200 && response.data != null) {
      int code = response.data['Code'];
      String message = response.data['Message']['VN'];
      if (languageCode != 'vi') {
        message = response.data['Message']['EN'];
      }

      return (message, code);
    }

    return (null, 500);
  }
}
