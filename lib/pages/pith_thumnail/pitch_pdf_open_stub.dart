Future<void> ouvrirPdfNatif(
  List<int> donnees,
  String nomFichier,
) async {
  throw UnsupportedError(
    'L’ouverture native du PDF n’est pas disponible sur cette plateforme.',
  );
}

Future<void> ouvrirPdfWeb(List<int> donnees) async {
  throw UnsupportedError(
    'L’ouverture Web du PDF n’est pas disponible sur cette plateforme.',
  );
}