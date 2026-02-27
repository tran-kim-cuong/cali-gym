class BookingClassModel {
  bool? success;
  String? message;
  String? clientcode;
  List<BookingData>? bookingData;

  BookingClassModel({
    this.success,
    this.message,
    this.clientcode,
    this.bookingData,
  });

  // Chuyển từ JSON sang Object
  BookingClassModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    clientcode = json['clientcode'];
    if (json['booking_data'] != null) {
      bookingData = <BookingData>[];
      json['booking_data'].forEach((v) {
        bookingData!.add(BookingData.fromJson(v));
      });
    }
  }

  // Chuyển từ Object ngược lại JSON (nếu cần gửi lên server)
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['message'] = message;
    data['clientcode'] = clientcode;
    if (bookingData != null) {
      data['booking_data'] = bookingData!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class BookingData {
  int? scheduleId;
  String? serviceName;
  String? clubCode;
  String? clubName;
  String? code;
  DateTime? startDate;
  DateTime? endDate;
  String? classType;
  String? trainerName;

  BookingData({
    this.scheduleId,
    this.serviceName,
    this.clubCode,
    this.clubName,
    this.code,
    this.startDate,
    this.endDate,
    this.classType,
  });

  BookingData.fromJson(Map<String, dynamic> json) {
    scheduleId = json['schedule_id'];
    serviceName = json['service_name'];
    clubCode = json['club_code'];
    clubName = json['club_name'];
    code = json['code'];
    startDate = DateTime.parse(json['start_date']);
    endDate = DateTime.parse(json['end_date']);
    classType = json['class_type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['schedule_id'] = scheduleId;
    data['service_name'] = serviceName;
    data['club_code'] = clubCode;
    data['club_name'] = clubName;
    data['code'] = code;
    data['start_date'] = startDate?.toIso8601String();
    data['end_date'] = endDate?.toIso8601String();
    data['class_type'] = classType;
    return data;
  }
}
