
class MessageResponseModel {
  final int id;
  final int conversationId;
  final int expediteurId;
  final String expediteurNom;
  final String contenu;
  final DateTime? dateEnvoi;
  final DateTime? dateLecture;

  const MessageResponseModel({
    required this.id,
    required this.conversationId,
    required this.expediteurId,
    required this.expediteurNom,
    required this.contenu,
    this.dateEnvoi,
    this.dateLecture,
  });

  factory MessageResponseModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return MessageResponseModel(
      id: (json['id'] as num).toInt(),
      conversationId:
          (json['conversationId'] as num).toInt(),
      expediteurId:
          (json['expediteurId'] as num).toInt(),
      expediteurNom: json['expediteurNom'] as String,
      contenu: json['contenu'] as String,
      dateEnvoi: json['dateEnvoi'] == null
          ? null
          : DateTime.parse(json['dateEnvoi'] as String),
      dateLecture: json['dateLecture'] == null
          ? null
          : DateTime.parse(json['dateLecture'] as String),
    );
  }
}
