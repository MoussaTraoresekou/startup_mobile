
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  const TokenStorage();

  static const FlutterSecureStorage _storage =
      FlutterSecureStorage();

  static const String _tokenKey = 'jwt_token';

  // Enregistrer le JWT
  Future<void> saveToken(String token) async {
    await _storage.write(
      key: _tokenKey,
      value: token,
    );
  }

  // Lire le JWT
  Future<String?> readToken() async {
    return _storage.read(key: _tokenKey);
  }

  // Supprimer le JWT à la déconnexion
  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }
}
