import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

Future<String> creerUrlVideo(List<int> donnees) async {
  final octets = Uint8List.fromList(donnees);

  final blob = web.Blob(
    [octets.toJS].toJS,
    web.BlobPropertyBag(type: 'video/mp4'),
  );

  return web.URL.createObjectURL(blob);
}

void libererUrlVideo(String url) {
  if (url.startsWith('blob:')) {
    web.URL.revokeObjectURL(url);
  }
}