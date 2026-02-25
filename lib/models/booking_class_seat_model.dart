class BookingClassSeatModel {
  final bool? success;
  final String? message;
  final String? errorCode;
  final dynamic warningData;
  final BookingClassSeatData? data;

  BookingClassSeatModel({
    this.success,
    this.message,
    this.errorCode,
    this.warningData,
    this.data,
  });

  factory BookingClassSeatModel.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];

    return BookingClassSeatModel(
      success: json['success'],
      message: json['message'],
      errorCode: json['error_code'],
      warningData: json['warning_data'],
      data: rawData is Map<String, dynamic>
          ? BookingClassSeatData.fromJson(rawData)
          : null, // xử lý khi data = [] hoặc null
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'error_code': errorCode,
      'warning_data': warningData,
      'data': data?.toJson(),
    };
  }
}

class BookingClassSeatData {
  final TicketInfo? ticketInfo;

  BookingClassSeatData({this.ticketInfo});

  factory BookingClassSeatData.fromJson(Map<String, dynamic> json) {
    return BookingClassSeatData(
      ticketInfo: json['ticket_info'] is Map<String, dynamic>
          ? TicketInfo.fromJson(json['ticket_info'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'ticket_info': ticketInfo?.toJson()};
  }
}

class TicketInfo {
  final String? ticketNumber;
  final String? instructor;
  final String? className;
  final String? classType;
  final String? studioName;
  final String? clubName;
  final String? date;
  final String? time;
  final String? seatNumber;

  TicketInfo({
    this.ticketNumber,
    this.instructor,
    this.className,
    this.classType,
    this.studioName,
    this.clubName,
    this.date,
    this.time,
    this.seatNumber,
  });

  factory TicketInfo.fromJson(Map<String, dynamic> json) {
    return TicketInfo(
      ticketNumber: json['ticket_number']?.toString(),
      instructor: json['instructor'],
      className: json['class_name'],
      classType: json['class_type'],
      studioName: json['studio_name'],
      clubName: json['club_name'],
      date: json['date'],
      time: json['time'],
      seatNumber: json['seat_number']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ticket_number': ticketNumber,
      'instructor': instructor,
      'class_name': className,
      'class_type': classType,
      'studio_name': studioName,
      'club_name': clubName,
      'date': date,
      'time': time,
      'seat_number': seatNumber,
    };
  }
}
