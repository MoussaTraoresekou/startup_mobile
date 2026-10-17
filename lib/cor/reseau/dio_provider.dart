
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:startup_mobile/cor/config/ApiConfig.dart';

import '../storage/token_storage.dart';

final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return const TokenStorage();
});

final dioProvider = Provider<Dio>((ref) {
  final tokenStorage = ref.watch(tokenStorageProvider);

  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        try {
          final token = await tokenStorage.readToken();

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          handler.next(options);
        } catch (error) {
          handler.reject(
            DioException(
              requestOptions: options,
              error: error,
              message: 'Impossible de lire le token sécurisé.',
            ),
          );
        }
      },
    ),
  );

  return dio;
});
