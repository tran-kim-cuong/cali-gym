import 'package:californiaflutter/models/member_model.dart';
import 'package:hive_flutter/hive_flutter.dart';

class MemberCacheManager {
  static const String _boxName = 'app_cache';
  static const String _keyMemberRaw = 'member_raw';

  static final MemberCacheManager _instance = MemberCacheManager._internal();
  factory MemberCacheManager() => _instance;
  MemberCacheManager._internal();

  Box<dynamic>? _box;

  Future<void> init() async {
    await Hive.initFlutter();
    if (Hive.isBoxOpen(_boxName)) {
      _box = Hive.box<dynamic>(_boxName);
      return;
    }
    _box = await Hive.openBox<dynamic>(_boxName);
  }

  MemberModel? getCachedMember() {
    final Box<dynamic>? box = _box;
    if (box == null) return null;

    final dynamic raw = box.get(_keyMemberRaw);
    if (raw is! Map) return null;

    try {
      return MemberModel.fromJson(_toStringDynamicMap(raw));
    } catch (_) {
      return null;
    }
  }

  Future<void> saveMemberRaw(Map<String, dynamic> rawMember) async {
    final Box<dynamic>? box = _box;
    if (box == null) return;
    await box.put(_keyMemberRaw, _normalizeMap(rawMember));
  }

  Future<void> clearMemberCache() async {
    final Box<dynamic>? box = _box;
    if (box == null) return;
    await box.delete(_keyMemberRaw);
  }

  Map<String, dynamic> _toStringDynamicMap(Map<dynamic, dynamic> input) {
    return input.map(
      (key, value) => MapEntry(key.toString(), _normalizeValue(value)),
    );
  }

  Map<String, dynamic> _normalizeMap(Map<String, dynamic> input) {
    return input.map(
      (key, value) => MapEntry(key.toString(), _normalizeValue(value)),
    );
  }

  dynamic _normalizeValue(dynamic value) {
    if (value is Map) {
      return value.map(
        (key, innerValue) =>
            MapEntry(key.toString(), _normalizeValue(innerValue)),
      );
    }

    if (value is List) {
      return value.map(_normalizeValue).toList();
    }

    return value;
  }
}
