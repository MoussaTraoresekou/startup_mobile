import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

Future<void> ouvrirPdfWeb(List<int> donnees) async {
  final octets = Uint8List.fromList(donnees);

  final blob = web.Blob(
    [octets.toJS].toJS,
    web.BlobPropertyBag(type: 'application/pdf'),
  );

  final url = web.URL.createObjectURL(blob);

  web.window.open(url, '_blank');
}