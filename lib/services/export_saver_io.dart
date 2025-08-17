import 'dart:io';
import 'dart:typed_data';

Future<void> saveExcelBytes(Uint8List bytes, {required String fileNameOrPath}) async {
  final file = File(fileNameOrPath);
  await file.create(recursive: true);
  await file.writeAsBytes(bytes, flush: true);
}
