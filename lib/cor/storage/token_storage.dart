import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TokenStorage {
  const TokenStorage();

  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static const String _tokenKey = 'jwt_token';
  static const String _profileKey = 'profile_completed';

  Future<void> saveToken(String token) async {
    await _storage.write(
      key: _tokenKey,
      value: token,
    );
  }

  Future<String?> readToken() async {
    return _storage.read(key: _tokenKey);
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _profileKey);
  }

  /// Sauvegarde le statut du profilage progressif de l'investisseur
  Future<void> saveProfileStatus(bool completed) async {
    await _storage.write(
      key: _profileKey,
      value: completed ? 'true' : 'false',
    );
  }

  /// Lit le statut du profilage progressif local
  Future<String?> readProfileStatus() async {
    return _storage.read(key: _profileKey);
  }
}

/// Fournisseur Riverpod indispensable pour injecter cette classe dans vos dépôts et contrôleurs
final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return const TokenStorage();
});
