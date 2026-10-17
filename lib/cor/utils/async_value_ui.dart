import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:startup_mobile/cor/theme/app_theme.dart';

extension AsyncValueUi on AsyncValue {
  void showErrorDialog(BuildContext context) {
    if (!isLoading && hasError) {
      if (ModalRoute.of(context)?.isCurrent == false) {
        return;
      }

      final message = _errorMessage(error);

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          backgroundColor: context.background,
          icon: Icon(Icons.error, color: context.badgeRed, size: 40),
          title: Text(
            message,
            textAlign: TextAlign.center,
            style: context.normalTextStyle.copyWith(
              color: context.badgeRed,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.badgeRed,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Fermer',
                    style: TextStyle(
                      color: context.textInverse,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }
  }

  void showSuccessDialog(
    BuildContext context,
    String message,
    VoidCallback onConfirm,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        backgroundColor: context.background,
        icon: Icon(
          Icons.check_circle_outline,
          color: context.primary,
          size: 54,
        ),
        title: Text(
          message,
          textAlign: TextAlign.center,
          style: context.normalTextStyle.copyWith(
            color: context.textDark,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  onConfirm();
                },
                child: Text(
                  'Continuer',
                  style: TextStyle(
                    color: context.textInverse,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _errorMessage(Object? error) {
    if (error is DioException) {
      if (error.response != null && error.response?.data != null) {
        final data = error.response?.data;
        if (data is Map<String, dynamic> && data.containsKey('message')) {
          return data['message'];
        }
      }
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
          return 'Le serveur met trop de temps à répondre. Veuillez réessayer.';
        case DioExceptionType.connectionError:
          return 'Impossible de joindre le serveur Spring Boot. Vérifiez votre connexion Internet.';
        default:
          return 'Une erreur réseau est survenue avec l\'API.';
      }
    }
    return error?.toString() ?? 'Une erreur inattendue est survenue.';
  }
}
