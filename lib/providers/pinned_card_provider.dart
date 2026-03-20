import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PinnedCardProvider extends ChangeNotifier {
  static const String _pinnedCardKey = 'pinned_member_card';

  String? _pinnedMembershipNumber;
  String? get pinnedMembershipNumber => _pinnedMembershipNumber;

  bool get hasPinnedCard => _pinnedMembershipNumber != null;

  PinnedCardProvider() {
    _loadPinnedCard();
  }

  Future<void> _loadPinnedCard() async {
    final prefs = await SharedPreferences.getInstance();
    _pinnedMembershipNumber = prefs.getString(_pinnedCardKey);
    notifyListeners();
  }

  Future<void> pinCard(String membershipNumber) async {
    _pinnedMembershipNumber = membershipNumber;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pinnedCardKey, membershipNumber);
    notifyListeners();
  }

  Future<void> unpinCard() async {
    _pinnedMembershipNumber = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pinnedCardKey);
    notifyListeners();
  }

  bool isPinned(String membershipNumber) {
    return _pinnedMembershipNumber == membershipNumber;
  }

  /// Sắp xếp danh sách thẻ: thẻ được ghim luôn ở đầu
  List<Map<String, dynamic>> sortCards(List<Map<String, dynamic>> cards) {
    if (_pinnedMembershipNumber == null) return cards;
    final sorted = List<Map<String, dynamic>>.from(cards);
    final pinnedIndex = sorted.indexWhere(
      (card) => card['membershipNumber'] == _pinnedMembershipNumber,
    );
    if (pinnedIndex > 0) {
      final pinnedCard = sorted.removeAt(pinnedIndex);
      sorted.insert(0, pinnedCard);
    }
    return sorted;
  }
}
