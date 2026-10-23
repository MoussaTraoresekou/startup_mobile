
class ProjetModel {
  final int id;
  final String titre;
  final String description;
  final String pithUrl;
  final String quotaPropose;
  final String secteur;
  final String porteurNomComplet;
  final DateTime dateCreation;
  final int nombreLikes;

  ProjetModel({
    required this.id,
    required this.titre,
    required this.description,
    required this.pithUrl,
    required this.quotaPropose,
    required this.secteur,
    required this.porteurNomComplet,
    required this.dateCreation,
    this.nombreLikes = 0,
  });

  factory ProjetModel.fromJson(Map<String, dynamic> json) {
    return ProjetModel(
      id: json['id'] as int,
      titre: json['titre'] as String? ?? '',
      description: json['description'] as String? ?? '',
      pithUrl: json['pith_url'] as String? ?? '',
      quotaPropose: json['quota_propose'] as String? ?? '',
      secteur: json['secteur'] as String? ?? 'Général',
      porteurNomComplet:
          json['porteurNomComplet'] as String? ?? 'Anonyme',
      dateCreation: json['date_creation'] != null
          ? DateTime.parse(json['date_creation'] as String)
          : DateTime.now(),
      nombreLikes: (json['nombreLikes'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titre': titre,
      'description': description,
      'pith_url': pithUrl,
      'quota_propose': quotaPropose,
      'secteur': secteur,
      'porteurNomComplet': porteurNomComplet,
      'date_creation': dateCreation.toIso8601String().split('T')[0],
      'nombreLikes': nombreLikes,
    };
  }
}
