class BookingClassConfirmModel {
  final bool success;
  final String message;
  final String? errorCode;

  BookingClassConfirmModel({
    required this.success,
    required this.message,
    this.errorCode,
  });

  /// JSON -> Model
  factory BookingClassConfirmModel.fromJson(Map<String, dynamic> json) {
    return BookingClassConfirmModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      errorCode: json['error_code'],
    );
  }

  /// Model -> JSON
  Map<String, dynamic> toJson() {
    return {'success': success, 'message': message, 'error_code': errorCode};
  }
}
