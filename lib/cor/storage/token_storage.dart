
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TokenStorage {
  const TokenStorage();

  static const FlutterSecureStorage _storage =
      FlutterSecureStorage();

  static const String _tokenKey = 'jwt_token';
  static const String _profileKey = 'profile_completed';
  static const String _userIdKey = 'user_id';
  static const String _nomKey = 'user_nom';
  static const String _prenomKey = 'user_prenom';
  static const String _emailKey = 'user_email';
  static const String _roleKey = 'user_role';

  // TOKEN
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> readToken() async {
    return _storage.read(key: _tokenKey);
  }

  // IDENTIFIANT
  Future<void> saveUserId(int userId) async {
    await _storage.write(
      key: _userIdKey,
      value: userId.toString(),
    );
  }

  Future<int?> readUserId() async {
    final value = await _storage.read(key: _userIdKey);
    if (value == null || value.isEmpty) return null;
    return int.tryParse(value);
  }

  // INFORMATIONS DU PROFIL
  Future<void> saveUserProfile({
    required String nom,
    required String prenom,
    required String email,
    required String role,
  }) async {
    await _storage.write(key: _nomKey, value: nom);
    await _storage.write(key: _prenomKey, value: prenom);
    await _storage.write(key: _emailKey, value: email);
    await _storage.write(key: _roleKey, value: role);
  }

  Future<Map<String, String?>> readUserProfile() async {
    final values = await Future.wait([
      _storage.read(key: _nomKey),
      _storage.read(key: _prenomKey),
      _storage.read(key: _emailKey),
      _storage.read(key: _roleKey),
    ]);

    return {
      'nom': values[0],
      'prenom': values[1],
      'email': values[2],
      'role': values[3],
    };
  }

  // STATUT DU PROFIL
  Future<void> saveProfileStatus(bool completed) async {
    await _storage.write(
      key: _profileKey,
      value: completed ? 'true' : 'false',
    );
  }

  Future<String?> readProfileStatus() async {
    return _storage.read(key: _profileKey);
  }

  // DÉCONNEXION : supprimer toutes les données de session
  Future<void> deleteToken() async {
    await Future.wait([
      _storage.delete(key: _tokenKey),
      _storage.delete(key: _profileKey),
      _storage.delete(key: _userIdKey),
      _storage.delete(key: _nomKey),
      _storage.delete(key: _prenomKey),
      _storage.delete(key: _emailKey),
      _storage.delete(key: _roleKey),
    ]);
  }
}

final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return const TokenStorage();
});
