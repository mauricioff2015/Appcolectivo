import 'dart:typed_data';
import 'package:universal_html/html.dart' as html;

Future<void> saveExcelBytes(Uint8List bytes, {required String fileNameOrPath}) async {
  final blob = html.Blob([bytes], 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.document.createElement('a') as html.AnchorElement
    ..href = url
    ..download = fileNameOrPath;
  html.document.body!.append(anchor);
  anchor.click();
  anchor.remove();
  html.Url.revokeObjectUrl(url);
}
