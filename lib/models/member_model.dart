class MemberModel {
  final String? clientCode;
  final String? membershipNumber;
  final String? membershipType;
  final String? email;
  final String? phoneNumber;
  final String? gender;
  final String? firstName;
  final DateTime? endDate;
  final DateTime? birthDate;
  final int? remainingSession;
  final int? advanceBookingBeforeXDays;
  final List<MembershipCard>? listMembershipCard;

  MemberModel({
    this.clientCode,
    this.membershipNumber,
    this.membershipType,
    this.email,
    this.phoneNumber,
    this.gender,
    this.firstName,
    this.endDate,
    this.birthDate,
    this.remainingSession,
    this.advanceBookingBeforeXDays,
    this.listMembershipCard,
  });

  factory MemberModel.fromJson(Map<String, dynamic> json) {
    return MemberModel(
      clientCode: json['clientcode'],
      membershipNumber: json['membership_number'],
      membershipType: json['membership_type'],
      email: json['email'],
      phoneNumber: json['phonenumber'],
      gender: json['gender'],
      firstName: json['firstname'],
      endDate: _parseDate(json['end_date']),
      birthDate: _parseDate(json['birthdate']),
      remainingSession: _parseInt(json['remaning_session']),
      advanceBookingBeforeXDays: _parseInt(
        json['advance_booking_before_xdays'],
      ),
      listMembershipCard: json['list_membership_card'] != null
          ? (json['list_membership_card'] as List)
                .map((e) => MembershipCard.fromJson(e))
                .toList()
          : [],
    );
  }
}

class MembershipCard {
  final String? membershipNumber;
  final String? membershipType;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool? isOwner;
  final bool? hasBenefit;
  final int? advanceBookingBeforeXDays;
  final List<Club>? clubList;
  final List<Benefit>? benefitMember;

  MembershipCard({
    this.membershipNumber,
    this.membershipType,
    this.startDate,
    this.endDate,
    this.isOwner,
    this.hasBenefit,
    this.advanceBookingBeforeXDays,
    this.clubList,
    this.benefitMember,
  });

  factory MembershipCard.fromJson(Map<String, dynamic> json) {
    return MembershipCard(
      membershipNumber: json['mB_membership_number'],
      membershipType: json['mB_membership_type'],
      startDate: _parseDate(json['mB_start_date']),
      endDate: _parseDate(json['mB_end_date']),
      isOwner: json['mB_isOwner'],
      hasBenefit: json['mB_hasBenefit'],
      advanceBookingBeforeXDays: _parseInt(
        json['mB_advance_booking_before_xdays'],
      ),
      clubList: json['club_list'] != null
          ? (json['club_list'] as List).map((e) => Club.fromJson(e)).toList()
          : [],
      benefitMember: json['benefit_member'] is List
          ? (json['benefit_member'] as List)
                .map((e) => Benefit.fromJson(e))
                .toList()
          : [],
    );
  }
}

class Club {
  final String? clubCode;
  final String? clubName;

  Club({this.clubCode, this.clubName});

  factory Club.fromJson(Map<String, dynamic> json) {
    return Club(clubCode: json['club_Code'], clubName: json['club_Name']);
  }
}

class Benefit {
  final String? productCode;
  final String? productNameEN;
  final String? productNameVI;
  final int? quantityMaximum;

  Benefit({
    this.productCode,
    this.productNameEN,
    this.productNameVI,
    this.quantityMaximum,
  });

  factory Benefit.fromJson(Map<String, dynamic> json) {
    return Benefit(
      productCode: json['productCode'],
      productNameEN: json['productNameEN'],
      productNameVI: json['productNameVI'],
      quantityMaximum: _parseInt(json['quantityMaximum']),
    );
  }
}

DateTime? _parseDate(dynamic value) {
  if (value == null || value == "") return null;
  return DateTime.tryParse(value.toString().replaceAll('/', '-'));
}

int? _parseInt(dynamic value) {
  if (value == null || value == "") return null;
  if (value is int) return value;
  return int.tryParse(value.toString());
}
