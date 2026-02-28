class MemberInfoModel {
  final bool? success;
  final String? message;
  final MemberData? data;

  MemberInfoModel({this.success, this.message, this.data});

  factory MemberInfoModel.fromJson(Map<String, dynamic> json) {
    return MemberInfoModel(
      success: json['success'],
      message: json['message'],
      data: json['data'] != null ? MemberData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'message': message, 'data': data?.toJson()};
  }
}

class MemberData {
  final int? userId;
  final String? memberId;

  MemberData({this.userId, this.memberId});

  factory MemberData.fromJson(Map<String, dynamic> json) {
    return MemberData(userId: json['user_id'], memberId: json['member_id']);
  }

  Map<String, dynamic> toJson() {
    return {'user_id': userId, 'member_id': memberId};
  }
}
