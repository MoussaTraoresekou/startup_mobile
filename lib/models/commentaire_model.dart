class CommentaireModel {
  final int id;
  final String contenu;
  final String auteurNomComplet;
  final DateTime? dateCreation;
  final bool monCommentaire;

  const CommentaireModel({
    required this.id,
    required this.contenu,
    required this.auteurNomComplet,
    this.dateCreation,
    required this.monCommentaire,
  });

  factory CommentaireModel.fromJson(Map<String, dynamic> json) {
    return CommentaireModel(
      id: (json['id'] as num).toInt(),
      contenu: json['contenu'] as String,
      auteurNomComplet: json['auteurNomComplet'] as String,
      dateCreation: json['dateCreation'] == null
          ? null
          : DateTime.parse(json['dateCreation'] as String),
      monCommentaire: json['monCommentaire'] as bool? ?? false,
    );
  }
}