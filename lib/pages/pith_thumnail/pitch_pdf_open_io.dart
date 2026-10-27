import 'dart:io';

import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

Future<void> ouvrirPdfNatif(
  List<int> donnees,
  String nomFichier,
) async {
  if (donnees.isEmpty) {
    throw ArgumentError('Le fichier PDF est vide.');
  }

  final repertoire = await getTemporaryDirectory();

  final fichier = File(
    '${repertoire.path}${Platform.pathSeparator}$nomFichier',
  );

  await fichier.writeAsBytes(donnees, flush: true);

  final resultat = await OpenFilex.open(fichier.path);

  if (resultat.type != ResultType.done) {
    throw Exception(
      resultat.message.isNotEmpty
          ? resultat.message
          : 'Impossible d’ouvrir le fichier PDF.',
    );
  }
}