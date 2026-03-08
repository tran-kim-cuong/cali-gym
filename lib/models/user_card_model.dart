class CardUserModel {
  final String fullName;
  final String clientId;
  final String phoneNumber;
  final bool isActive;

  CardUserModel({
    required this.fullName,
    required this.clientId,
    required this.phoneNumber,
    required this.isActive,
  });

  // Hàm lấy dòng thông tin kết hợp như hình ảnh
  String get displayClientIdAndPhoneNo {
    // Logic masking số điện thoại: Giữ 4 số đầu + *** + 3 số cuối
    String maskedPhone = phoneNumber;
    if (phoneNumber.length >= 7) {
      maskedPhone =
          "${phoneNumber.substring(0, 4)}***${phoneNumber.substring(phoneNumber.length - 3)}";
    }

    // Trả về định dạng: "clientId - maskedPhone"
    return "$clientId - $maskedPhone";
  }

  @override
  String toString() {
    return 'CardUserModel(fullName: $fullName, clientId: $clientId, isActive: $isActive)';
  }
}
