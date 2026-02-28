import 'package:californiaflutter/models/member_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

List<Map<String, dynamic>> buildMemberCards(MemberModel? member) {
  return member?.listMembershipCard?.map((card) {
        return {
          "name": member.firstName ?? "",
          "id": member.clientCode ?? "",
          "status": _getStatus(card.endDate),
          "expiry": _formatDate(card.endDate),
          "colors": _getCardColors(card.membershipType),
          "membershipType": card.membershipNameCard ?? "",
          "membershipNumber":
              card.membershipCardNumber ?? "", //Sai, không nên dùng
          "mbMemberId": card.mbMemberId ?? "",
          "mbMembershipNumber": card.membershipNumber ?? "",
        };
      }).toList() ??
      [];
}

String _getStatus(DateTime? endDate) {
  if (endDate == null) return "Unknown";

  if (endDate.isAfter(DateTime.now())) {
    return "Active";
  } else {
    return "Expired";
  }
}

String _formatDate(DateTime? date) {
  if (date == null) return "";
  return DateFormat('dd/MM/yyyy').format(date);
}

List<Color> _getCardColors(String? type) {
  switch (type?.toLowerCase()) {
    case "iconic":
      return [Color(0xFF574E4C), Color(0xFF231E1D)];

    case "staff":
      return [Color(0xFFD4AF37), Color(0xFF8B7500)];

    default:
      return [Color(0xFF757F9A), Color(0xFFD7DDE8)];
  }
}
