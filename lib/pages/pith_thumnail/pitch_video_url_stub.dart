import 'package:video_player/video_player.dart';

Future<String> creerUrlVideo(List<int> donnees) async {
  throw UnsupportedError(
    'La création d’une URL vidéo est indisponible sur cette plateforme.',
  );
}

void libererUrlVideo(String url) {}

VideoPlayerController creerControleurVideo(String chemin) {
  throw UnsupportedError(
    'La création du contrôleur vidéo est indisponible sur cette plateforme.',
  );
}