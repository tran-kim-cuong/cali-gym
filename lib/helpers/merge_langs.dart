import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:io';

// import 'package:flutter/foundation.dart';

// Chạy lệnh này: dart merge_langs.dart
void main() async {
  final sourceDir = Directory('assets/translations/source');
  final outputDir = Directory('assets/translations');

  // 1. Tạo bộ mã hóa JSON có thụt đầu dòng (2 khoảng trắng)
  const JsonEncoder encoder = JsonEncoder.withIndent('  ');

  // Duyệt qua các folder ngôn ngữ (vi, en...)
  if (await sourceDir.exists()) {
    await for (var langDir in sourceDir.list()) {
      if (langDir is Directory) {
        String langCode = langDir.path.split(Platform.pathSeparator).last;
        
        // Dùng SplayTreeMap nếu muốn key tự động sắp xếp theo alphabet (tùy chọn)
        // Hoặc dùng Map bình thường nếu muốn giữ thứ tự insert
        Map<String, dynamic> mergedContent = {}; 

        dev.log('Processing language: $langCode...');

        // Duyệt qua từng file json con (login.json, home.json...)
        List<FileSystemEntity> files = await langDir.list().toList();
        
        // Sắp xếp file để thứ tự key trong json tổng ổn định
        files.sort((a, b) => a.path.compareTo(b.path));

        for (var file in files) {
          if (file is File && file.path.endsWith('.json')) {
            String fileName = file.path
                .split(Platform.pathSeparator)
                .last
                .replaceAll('.json', '');
            
            try {
              String content = await file.readAsString();
              dynamic jsonContent = jsonDecode(content);

              // Dùng tên file làm Key lớn (Nested JSON)
              mergedContent[fileName] = jsonContent;
            } catch (e) {
              dev.log('Error reading file ${file.path}: $e');
            }
          }
        }

        // Ghi ra file tổng (ví dụ: assets/translations/vi.json)
        File outputFile = File('${outputDir.path}/$langCode.json');
        
        // 2. Sử dụng encoder đã tạo để ghi nội dung đã format đẹp
        await outputFile.writeAsString(encoder.convert(mergedContent));
        
        dev.log('--> Generated: ${outputFile.path} (Formatted)');
      }
    }
    dev.log('Done! Run "flutter pub get" or "Hot Restart" to apply.');
  } else {
    dev.log('Source directory not found: ${sourceDir.path}');
  }
}