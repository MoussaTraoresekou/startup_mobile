import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:startup_mobile/cor/reseau/dio_provider.dart';
import 'package:startup_mobile/models/Secteur.dart';

class ProfileRepository {
  ProfileRepository(this._dio);

  final Dio _dio;

  Future<List<Secteur>> getSecteurs() async {
    try {
      final response = await _dio.get('/api/investisseur/secteurs');
      final data = response.data as List<dynamic>;
      return data
          .map((e) => Secteur.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw Exception(_message(e));
    }
  }

  Future<void> saveSecteurs(List<int> secteurIds) async {
    try {
      await _dio.put(
        '/api/investisseur/secteurs',
        data: {'secteurIds': secteurIds},
      );
    } on DioException catch (e) {
      throw Exception(_message(e));
    }
  }

  Future<void> skip() async {
    try {
      await _dio.post('/api/investisseur/passer');
    } on DioException catch (e) {
      throw Exception(_message(e));
    }
  }

  String _message(DioException e) {
    debugPrint(
      'Dio: type=${e.type} | statut=${e.response?.statusCode} | '
      'message=${e.message} | url=${e.requestOptions.uri}',
    );

    final data = e.response?.data;
    if (data is Map) {
      final message = data['message'];
      if (message is String && message.isNotEmpty) return message;
    }

    if (e.response == null) {
      return 'Impossible de joindre le serveur. Vérifiez votre connexion.';
    }

    switch (e.response?.statusCode) {
      case 400:
        return 'Les données envoyées sont invalides.';
      case 401:
        return 'Votre session a expiré. Reconnectez-vous.';
      case 403:
        return 'Vous n’avez pas l’autorisation d’effectuer cette action.';
      default:
        return 'Une erreur est survenue lors de la communication avec le serveur.';
    }
  }
  
  /// TODO : remplacer cette URL par l'endpoint qui retourne
  /// réellement les secteurs choisis par l'investisseur.
  Future<List<Secteur>> getSecteursChoisis() async {
    try {
      const endpoint = '/api/investisseur/secteurs-choisis';

      final response = await _dio.get(endpoint);
      final data = response.data as List<dynamic>;

      return data
          .map(
            (e) => Secteur.fromJson(
              Map<String, dynamic>.from(e as Map),
            ),
          )
          .toList();
    } on DioException catch (e) {
      throw Exception(_message(e));
    }
  }

}

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(ref.watch(dioProvider));
});

final secteursProvider = FutureProvider.autoDispose<List<Secteur>>((ref) {
  return ref.watch(profileRepositoryProvider).getSecteurs();
});

final secteursChoisisProvider =
    FutureProvider.autoDispose<List<Secteur>>((ref) {
  return ref
      .watch(profileRepositoryProvider)
      .getSecteursChoisis();
});

