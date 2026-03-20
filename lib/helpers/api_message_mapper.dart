import 'package:flutter/widgets.dart';

// SẼ XOÁ SAU KHI API TRẢ VỀ STATUS ĐÚNG KỸ THUẬT

class ApiMessageMapper {
  ApiMessageMapper._();

  static const Map<String, _LocalizedApiMessage> _messages = {
    'Do not exist schedules': _LocalizedApiMessage(
      en: 'No schedules available',
      vi: 'Không có lịch nào khả dụng',
    ),
    'Tickets are duplicated': _LocalizedApiMessage(
      en: 'Tickets are duplicated',
      vi: 'Bạn đã chọn vé trùng',
    ),
    'This membership card can not book tickets this period time':
        _LocalizedApiMessage(
          en: 'This membership card cannot book tickets during this period',
          vi: 'Thẻ hội viên này không thể đặt vé trong thời gian này',
        ),
    'End of time': _LocalizedApiMessage(
      en: "Couldn't complete your booking. End of time for booking on app",
      vi: 'Không thể hoàn tất đặt lớp học. Hết giờ đặt chỗ trên ứng dụng.',
    ),
  };

  static String map(BuildContext context, String message) {
    final normalizedMessage = message.trim();
    if (normalizedMessage.isEmpty) return message;

    for (final entry in _messages.entries) {
      if (normalizedMessage == entry.key) {
        return _displayText(context, entry.value);
      }

      if (normalizedMessage.startsWith('${entry.key} [')) {
        final suffix = normalizedMessage.substring(entry.key.length);
        return '${_displayText(context, entry.value)}$suffix';
      }
    }

    return message;
  }

  static String _displayText(
    BuildContext context,
    _LocalizedApiMessage localizedMessage,
  ) {
    final languageCode = Localizations.localeOf(context).languageCode;
    return languageCode == 'vi' ? localizedMessage.vi : localizedMessage.en;
  }
}

class _LocalizedApiMessage {
  final String en;
  final String vi;

  const _LocalizedApiMessage({required this.en, required this.vi});
}
