class LoginResponse {
  final int id;
  final String token;
  final String role;
  final String nom;
  final String prenom;
  final String email;

  LoginResponse({
    required this.id,
    required this.token,
    required this.role,
    required this.nom,
    required this.prenom,
    required this.email,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      id: json['id'] as int,
      token: json['token'] as String,
      role: json['role'] as String,
      nom: json['nom'] as String,
      prenom: json['prenom'] as String,
      email: json['email'] as String,
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
    };
  }
}
