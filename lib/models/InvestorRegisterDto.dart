class InvestorRegisterDto {
  final String nom;
  final String prenom;
  final String email;
  final String telephone;
  final String password;
  final String typeInvestisseurCode; // Reçoit le code stable de l'enum (ex: 'INDIVIDUEL_DIASPORA')

  InvestorRegisterDto({
    required this.nom,
    required this.prenom,
    required this.email,
    required this.telephone,
    required this.password,
    required this.typeInvestisseurCode,
  });

  /// Convertit l'objet en Map pour l'envoyer au format JSON à votre API Spring Boot
  Map<String, dynamic> toJson() {
    return {
      'nom': nom.trim(),
      'prenom': prenom.trim(),
      'email': email.trim().toLowerCase(),
      'telephone': telephone.trim(),
      'password': password,
      'typeInvestisseur': typeInvestisseurCode, // S'aligne parfaitement sur TypeInvestisseurEnum.java
    };
  }
}
