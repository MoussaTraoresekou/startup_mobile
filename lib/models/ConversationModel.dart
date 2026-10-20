class ConversationModel {
  final int id;
  final int projetId;
  final String projetTitre;
  final int investisseurId;
  final String investisseurNom;
  final int porteurId;
  final String porteurNom;
  final String dernierMessage;
  final DateTime? dateCreation;
  final DateTime? dateDernierMessage;

  const ConversationModel({
    required this.id,
    required this.projetId,
    required this.projetTitre,
    required this.investisseurId,
    required this.investisseurNom,
    required this.porteurId,
    required this.porteurNom,
    required this.dernierMessage,
    this.dateCreation,
    this.dateDernierMessage,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: (json['id'] as num).toInt(),
      projetId: (json['projetId'] as num).toInt(),
      projetTitre: json['projetTitre'] as String? ?? '',
      investisseurId: (json['investisseurId'] as num).toInt(),
      investisseurNom: json['investisseurNom'] as String? ?? '',
      porteurId: (json['porteurId'] as num).toInt(),
      porteurNom: json['porteurNom'] as String? ?? '',
      dernierMessage: json['dernierMessage'] as String? ?? '',
      dateCreation: json['dateCreation'] != null
          ? DateTime.parse(json['dateCreation'] as String)
          : null,
      dateDernierMessage: json['dateDernierMessage'] != null
          ? DateTime.parse(json['dateDernierMessage'] as String)
          : null,
    );
  }
}
