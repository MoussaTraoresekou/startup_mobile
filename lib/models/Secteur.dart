class Secteur {
  final int id;
  final String nom;

  Secteur({
    required this.id,
    required this.nom,
  });

  factory Secteur.fromJson(Map<String, dynamic> json) {
    return Secteur(
      id: json['id'] as int,
      // 🟢 CORRECTION : On mappe la clé 'secteur' du JSON Java sur la propriété 'nom' de Flutter
      nom: json['secteur'] as String? ?? 'Secteur inconnu',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'secteur': nom,
    };
  }
}
