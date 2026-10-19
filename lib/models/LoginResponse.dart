class LoginResponse {
  final int id;
  final String token;
  final String role;
  final String nom;
  final String prenom;
  final String email;

  /// false pour un investisseur qui n'a pas encore choisi ses secteurs
  /// (ni cliqué sur « Passer »). Vaut true si le serveur ne l'envoie pas
  /// (autres rôles, ancienne version du serveur).
  final bool profileCompleted;

  LoginResponse({
    required this.id,
    required this.token,
    required this.role,
    required this.nom,
    required this.prenom,
    required this.email,
    this.profileCompleted = true,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      id: json['id'] as int,
      token: json['token'] as String,
      role: json['role'] as String,
      nom: json['nom'] as String,
      prenom: json['prenom'] as String,
      email: json['email'] as String,
      profileCompleted: json['profileCompleted'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'token': token,
      'role': role,
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'profileCompleted': profileCompleted,
    };
  }
}