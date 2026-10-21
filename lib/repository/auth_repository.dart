import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:startup_mobile/cor/reseau/dio_provider.dart';
import 'package:startup_mobile/cor/storage/token_storage.dart'; 
import 'package:startup_mobile/models/InvestorRegisterDto.dart';
import 'package:startup_mobile/models/LoginResponse.dart';

part 'auth_repository.g.dart';

class AuthRepository {
  final Dio _dio;
  final TokenStorage _tokenStorage;

  AuthRepository(this._dio, this._tokenStorage);
/*
  Future<LoginResponse> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/api/user/login',
        data: {
          'email': email.trim().toLowerCase(),
          'password': password,
        },
      );

      final loginResponse = LoginResponse.fromJson(response.data);

      await _tokenStorage.saveToken(loginResponse.token);
      await _tokenStorage.saveProfileStatus(loginResponse.profileCompleted);

      return loginResponse;
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }
  */
  Future<LoginResponse> login(String email, String password) async {
  try {
    final response = await _dio.post(
      '/api/user/login',
      data: {
        'email': email.trim().toLowerCase(),
        'password': password,
      },
    );

    final loginResponse = LoginResponse.fromJson(response.data);

    await _tokenStorage.saveToken(loginResponse.token);
    await _tokenStorage.saveProfileStatus(
      loginResponse.profileCompleted,
    );

    // Enregistrer l'identifiant de l'utilisateur connecté.
    await _tokenStorage.saveUserId(loginResponse.id);

    return loginResponse;
  } on DioException catch (e) {
    throw Exception(_getErrorMessage(e));
  }
}

  Future<void> register(InvestorRegisterDto dto) async {
    try {
      await _dio.post(
        '/api/investisseur/register',
        data: dto.toJson(),
      );
    } on DioException catch (e) {
      throw Exception(_getErrorMessage(e));
    }
  }

  Future<void> logout() async {
    await _tokenStorage.deleteToken();
  }

  String _getErrorMessage(DioException e) {
    debugPrint(
      'Dio: type=${e.type} | statut=${e.response?.statusCode} | '
      'message=${e.message} | url=${e.requestOptions.uri}',
    );

    final data = e.response?.data;

    if (data is Map) {
      final message = data['message'];
      if (message is String && message.isNotEmpty) {
        return message;
      }
    }

    if (e.response == null) {
      return 'Impossible de joindre le serveur. Vérifiez votre connexion.';
    }

    switch (e.response?.statusCode) {
      case 400:
        return 'Les données envoyées sont invalides.';
      case 401:
        return 'Email ou mot de passe incorrect.';
      case 403:
        return 'Vous n’avez pas l’autorisation d’effectuer cette action.';
      case 404:
        return 'Le service demandé est introuvable.';
      case 409:
        return 'Un compte existe déjà avec ces informations.';
      case 500:
        return 'Une erreur interne est survenue sur le serveur.';
      default:
        return 'Une erreur est survenue lors de la communication avec le serveur.';
    }
  }
}

@riverpod
AuthRepository authRepository(Ref ref) {
  final dio = ref.watch(dioProvider);
  final storageInstance = ref.watch(tokenStorageProvider);

  return AuthRepository(dio, storageInstance);
}
