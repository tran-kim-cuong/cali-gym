import 'package:californiaflutter/models/booking_class_model.dart';

class ScheduleModel {
  final int? scheduleId;
  final String? clubCode;
  final String? clubName;
  final String? studioName;
  final String? classType;
  final String? className;
  final String? trainerName;
  final String? trainerCode;
  final int? numberSeat;
  final int? slotBooked;
  final int? slotLeft;
  final DateTime? openDate;
  final DateTime? startDate;
  final DateTime? endDate; // Ánh xạ từ close_date
  final int? duration;
  final String? capacity;
  final String? seatMapImage;
  final String? note;
  final bool? publishOnLivwell;

  final String? capacityBooked;

  ScheduleModel({
    this.scheduleId,
    this.clubCode,
    this.clubName,
    this.studioName,
    this.classType,
    this.className,
    this.trainerName,
    this.trainerCode,
    this.numberSeat,
    this.slotBooked,
    this.slotLeft,
    this.openDate,
    this.startDate,
    this.endDate,
    this.duration,
    this.capacity,
    this.seatMapImage,
    this.note,
    this.publishOnLivwell,

    this.capacityBooked,
  });

  // Chuyển từ JSON sang Object
  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    return ScheduleModel(
      scheduleId: json['schedule_id'],
      clubCode: json['club_code'],
      clubName: json['club_name'],
      studioName: json['studio_name'],
      classType: json['class_type'],
      className: json['class_name'],
      trainerName: json['trainer_name'],
      trainerCode: json['trainer_code'],
      numberSeat: json['number_seat'],
      slotBooked: json['slot_booked'],
      slotLeft: json['slot_left'],
      openDate: json['open_date'] != null
          ? DateTime.parse(json['open_date'])
          : null,
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'])
          : null,
      endDate: json['close_date'] != null
          ? DateTime.parse(json['close_date'])
          : null,
      duration: json['duration'],
      capacity: json['capacity'],
      seatMapImage: json['seat_map_image'],
      note: json['note'],
      publishOnLivwell: json['publish_on_livwell'] == "yes",

      capacityBooked: json['capacity_booked'],
    );
  }

  List<String> get capacityValid {
    // 1. Nếu capacity gốc null hoặc rỗng -> Trả về danh sách trống
    if (capacity == null || capacity!.trim().isEmpty) return [];

    // 2. Chuyển chuỗi "1,3,5..." thành List ["1", "3", "5"...]
    List<String> allSeats = capacity!
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    // 3. TRƯỜNG HỢP capacity_booked LÀ NULL: Trả về toàn bộ danh sách
    if (capacityBooked == null || capacityBooked!.trim().isEmpty) {
      return allSeats;
    }

    // 4. TRƯỜNG HỢP capacity_booked CÓ DỮ LIỆU: Lấy capacity - capacity_booked
    List<String> bookedSeats = capacityBooked!
        .split(',')
        .map((s) => s.trim())
        .toList();

    // Lọc ra những chỗ (seat) KHÔNG nằm trong danh sách đã đặt
    return allSeats.where((seat) => !bookedSeats.contains(seat)).toList();
  }

  List<String> get capacityArr {
    // 1. Nếu capacity gốc null hoặc rỗng -> Trả về danh sách trống
    if (capacity == null || capacity!.trim().isEmpty) return [];

    // 2. Chuyển chuỗi "1,3,5..." thành List ["1", "3", "5"...]
    List<String> allSeats = capacity!
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    return allSeats;
  }

  List<String> get capacityBookedArr {
    // 1. Nếu capacity gốc null hoặc rỗng -> Trả về danh sách trống
    if (capacityBooked == null || capacityBooked!.trim().isEmpty) return [];

    // 2. Chuyển chuỗi "1,3,5..." thành List ["1", "3", "5"...]
    List<String> allBookedSeats = capacityBooked!
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    return allBookedSeats;
  }

  // Chuyển từ Object sang JSON (nếu cần gửi lên API)
  Map<String, dynamic> toJson() {
    return {
      'schedule_id': scheduleId,
      'club_code': clubCode,
      'club_name': clubName,
      'studio_name': studioName,
      'class_type': classType,
      'class_name': className,
      'trainer_name': trainerName,
      'trainer_code': trainerCode,
      'number_seat': numberSeat,
      'slot_booked': slotBooked,
      'slot_left': slotLeft,
      'open_date': openDate?.toIso8601String(),
      'start_date': startDate?.toIso8601String(),
      'close_date': endDate?.toIso8601String(),
      'duration': duration,
      'capacity': capacity,
      'seat_map_image': seatMapImage,
      'note': note,
      'publish_on_livwell': publishOnLivwell == true ? "yes" : "no",

      'capacity_booked': capacityBooked,
    };
  }
}

extension ScheduleMapper on ScheduleModel {
  BookingData toBookingData() {
    return BookingData(
      scheduleId: scheduleId,
      // Trong ScheduleModel thường dùng className cho tên dịch vụ (Yoga, Group X...)
      serviceName: className,
      clubCode: clubCode,
      clubName: clubName,
      // ScheduleModel không có trường 'code' định danh đặt chỗ, có thể để null hoặc dùng trainerCode
      code: '',
      startDate: startDate,
      endDate: endDate,
      classType: classType,
    )..trainerName = trainerName; // Gán thêm trainerName nếu cần
  }
}
