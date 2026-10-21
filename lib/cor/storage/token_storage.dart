import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TokenStorage {
  const TokenStorage();

  static const FlutterSecureStorage _storage =
      FlutterSecureStorage();

  static const String _tokenKey = 'jwt_token';
  static const String _profileKey = 'profile_completed';
  static const String _userIdKey = 'user_id';

  // ==================== TOKEN ====================

  Future<void> saveToken(String token) async {
    await _storage.write(
      key: _tokenKey,
      value: token,
    );
  }

  Future<String?> readToken() async {
    return _storage.read(key: _tokenKey);
  }

  // ==================== IDENTIFIANT UTILISATEUR ====================

  Future<void> saveUserId(int userId) async {
    await _storage.write(
      key: _userIdKey,
      value: userId.toString(),
    );
  }

  Future<int?> readUserId() async {
    final value = await _storage.read(key: _userIdKey);

    if (value == null || value.isEmpty) {
      return null;
    }

    return int.tryParse(value);
  }

  // ==================== PROFIL ====================

  Future<void> saveProfileStatus(bool completed) async {
    await _storage.write(
      key: _profileKey,
      value: completed ? 'true' : 'false',
    );
  }

  Future<String?> readProfileStatus() async {
    return _storage.read(key: _profileKey);
  }

  // ==================== DÉCONNEXION ====================

  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _profileKey);
    await _storage.delete(key: _userIdKey);
  }
}

final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return const TokenStorage();
});
