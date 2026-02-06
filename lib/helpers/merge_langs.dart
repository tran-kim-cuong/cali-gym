import 'dart:convert';
import 'dart:io';

// Chạy lệnh này: dart merge_langs.dart
void main() async {
  final sourceDir = Directory('assets/translations/source');
  final outputDir = Directory('assets/translations');

  // Duyệt qua các folder ngôn ngữ (vi, en...)
  await for (var langDir in sourceDir.list()) {
    if (langDir is Directory) {
      String langCode = langDir.path.split(Platform.pathSeparator).last;
      Map<String, dynamic> mergedContent = {};

      print('Processing language: $langCode...');

      // Duyệt qua từng file json con (login.json, home.json...)
      await for (var file in langDir.list()) {
        if (file is File && file.path.endsWith('.json')) {
          String fileName = file.path
              .split(Platform.pathSeparator)
              .last
              .replaceAll('.json', '');
          String content = await file.readAsString();

          // Dùng tên file làm Key lớn (giống Cách 1)
          mergedContent[fileName] = jsonDecode(content);
        }
      }

      // Ghi ra file tổng (ví dụ: assets/translations/vi.json)
      File outputFile = File('${outputDir.path}/$langCode.json');
      await outputFile.writeAsString(jsonEncode(mergedContent));
      print('--> Generated: ${outputFile.path}');
    }
  }
  print('Done! Run "flutter pub get" or "Hot Restart" to apply.');
}
