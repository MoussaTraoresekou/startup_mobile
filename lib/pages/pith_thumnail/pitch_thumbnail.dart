
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:startup_mobile/cor/config/ApiConfig.dart';
import 'package:startup_mobile/cor/reseau/dio_provider.dart';
import 'package:startup_mobile/cor/theme/app_theme.dart';
import 'package:startup_mobile/cor/utils/size_config.dart';

class PitchThumbnail extends ConsumerStatefulWidget {
  final String? thumbnailUrl;
  final Widget fallback;

  const PitchThumbnail({
    super.key,
    required this.thumbnailUrl,
    required this.fallback,
  });

  @override
  ConsumerState<PitchThumbnail> createState() =>
      _PitchThumbnailState();
}

class _PitchThumbnailState extends ConsumerState<PitchThumbnail> {
  Future<List<int>>? _imageFuture;

  @override
  void initState() {
    super.initState();
    _chargerImage();
  }

  @override
  void didUpdateWidget(covariant PitchThumbnail oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.thumbnailUrl != widget.thumbnailUrl) {
      _chargerImage();
    }
  }

  void _chargerImage() {
    final nomFichier = widget.thumbnailUrl?.trim() ?? '';

    if (nomFichier.isEmpty) {
      _imageFuture = null;
      return;
    }

    _imageFuture = _telechargerImage(nomFichier);
  }

  Future<List<int>> _telechargerImage(String nomFichier) async {
    final dio = ref.read(dioProvider);

    final response = await dio.get<List<int>>(
      '${ApiConfig.baseUrl}/api/fichiers/pitch/$nomFichier',
      options: Options(
        responseType: ResponseType.bytes,
        headers: {'Accept': 'image/jpeg'},
      ),
    );

    final donnees = response.data;

    if (donnees == null || donnees.isEmpty) {
      throw Exception('Miniature vide.');
    }

    return donnees;
  }

  @override
  Widget build(BuildContext context) {
    final future = _imageFuture;

    if (future == null) {
      return widget.fallback;
    }

    return FutureBuilder<List<int>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: SizedBox(
              width: 24.w(context),
              height: 24.h(context),
              child: CircularProgressIndicator(
                strokeWidth: 2.w(context),
                color: context.primary,
              ),
            ),
          );
        }

        if (snapshot.hasError || snapshot.data == null) {
          return widget.fallback;
        }

        return Image.memory(
          Uint8List.fromList(snapshot.data!),
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          gaplessPlayback: true,
          errorBuilder: (_, __, ___) => widget.fallback,
        );
      },
    );
  }
}
