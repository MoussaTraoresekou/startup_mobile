import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

Future<String> creerUrlVideo(List<int> donnees) async {
  if (donnees.isEmpty) {
    throw Exception('Le fichier vidéo reçu est vide.');
  }

  final repertoire = await getTemporaryDirectory();

  final fichier = File(
    '${repertoire.path}${Platform.pathSeparator}'
    'pitch_${DateTime.now().microsecondsSinceEpoch}.mp4',
  );

  await fichier.writeAsBytes(donnees, flush: true);

  return fichier.path;
}

VideoPlayerController creerControleurVideo(String chemin) {
  return VideoPlayerController.file(File(chemin));
}

void libererUrlVideo(String chemin) {
  try {
    final fichier = File(chemin);

    if (fichier.existsSync()) {
      fichier.deleteSync();
    }
  } catch (e) {
    // Le nettoyage du fichier temporaire a échoué.
  }
}