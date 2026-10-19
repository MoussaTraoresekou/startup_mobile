import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:startup_mobile/models/ProjetModel%20.dart';
import '../../cor/reseau/dio_provider.dart';

part 'project_repository.g.dart';

class ProjectRepository {
  final Dio _dio;

  ProjectRepository(this._dio);

  Future<List<ProjetModel>> getFluxProjets() async {
    try {
      final response = await _dio.get('/api/investisseur/flux-projets');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;
        return data.map((json) => ProjetModel.fromJson(json as Map<String, dynamic>)).toList();
      }
      throw Exception('Impossible de charger le flux de projets.');
    } on DioException catch (e) {
      if (e.response != null && e.response?.data != null) {
        final message = e.response?.data['message'];
        if (message is String) throw Exception(message);
      }
      throw Exception('Erreur réseau lors de la récupération des pitchs.');
    }
  }
}

@riverpod
ProjectRepository projectRepository(Ref ref) {
  final dio = ref.watch(dioProvider);
  return ProjectRepository(dio);
}

@riverpod
Future<List<ProjetModel>> fluxProjets(Ref ref) {
  return ref.watch(projectRepositoryProvider).getFluxProjets();
}
