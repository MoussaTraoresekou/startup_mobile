enum PitchType { video, pdf, none }

/// Détermine si le pitch est une vidéo ou un PDF à partir de l'URL.
PitchType pitchTypeOf(String url) {
  final value = url.trim();
  if (value.isEmpty) return PitchType.none;

  final path = (Uri.tryParse(value)?.path ?? value).toLowerCase();
  if (path.endsWith('.mp4')) return PitchType.video;
  if (path.endsWith('.pdf')) return PitchType.pdf;
  return PitchType.none;
}