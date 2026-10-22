import 'package:flutter/material.dart';

class ModifierProfilButton extends StatelessWidget {
  final String prenom;
  final String nom;
  final String telephone;

  /// Cette fonction sera fournie par le controller de ton projet.
  final Future<void> Function({
    required String prenom,
    required String nom,
    required String telephone,
  })
  onModifier;

  const ModifierProfilButton({
    super.key,
    required this.prenom,
    required this.nom,
    required this.telephone,
    required this.onModifier,
  });

  Future<void> _ouvrirDialogueModification(BuildContext context) async {
    final prenomController = TextEditingController(text: prenom);
    final nomController = TextEditingController(text: nom);
    final telephoneController = TextEditingController(text: telephone);

    final formKey = GlobalKey<FormState>();

    bool isChargement = false;

    try {
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (sheetContext) {
          return StatefulBuilder(
            builder: (context, setState) {
              final theme = Theme.of(context);
              final colors = theme.colorScheme;

              Future<void> enregistrerModifications() async {
                if (isChargement) return;

                if (!(formKey.currentState?.validate() ?? false)) {
                  return;
                }

                setState(() => isChargement = true);

                try {
                  await onModifier(
                    prenom: prenomController.text.trim(),
                    nom: nomController.text.trim(),
                    telephone: telephoneController.text.trim(),
                  );

                  if (!context.mounted) return;

                  Navigator.of(context).pop();

                  ScaffoldMessenger.of(thisContext(context)).showSnackBar(
                    SnackBar(
                      content: const Text('Profil mis à jour avec succès.'),
                      backgroundColor: colors.primary,
                    ),
                  );
                } catch (e) {
                  if (!context.mounted) return;

                  setState(() => isChargement = false);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Impossible de modifier le profil : $e'),
                      backgroundColor: colors.error,
                    ),
                  );
                }
              }

              return Padding(
                padding: EdgeInsets.only(
                  top: 24,
                  left: 20,
                  right: 20,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                ),
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'Modifier mon profil',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colors.onSurface,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: isChargement
                                  ? null
                                  : () => Navigator.of(context).pop(),
                              icon: const Icon(Icons.close),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        _champTexte(
                          controller: prenomController,
                          label: 'Prénom',
                          hint: 'Votre prénom',
                          icon: Icons.person_outline,
                        ),

                        const SizedBox(height: 14),

                        _champTexte(
                          controller: nomController,
                          label: 'Nom',
                          hint: 'Votre nom',
                          icon: Icons.person_outline,
                        ),

                        const SizedBox(height: 14),

                        _champTexte(
                          controller: telephoneController,
                          label: 'Téléphone',
                          hint: '+223 00 00 00 00',
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                        ),

                        const SizedBox(height: 24),

                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: FilledButton(
                            onPressed: isChargement
                                ? null
                                : enregistrerModifications,
                            child: isChargement
                                ? SizedBox(
                                    height: 23,
                                    width: 23,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: colors.onPrimary,
                                    ),
                                  )
                                : const Text(
                                    'Enregistrer',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      );
    } finally {
      prenomController.dispose();
      nomController.dispose();
      telephoneController.dispose();
    }
  }

  Widget _champTexte({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Le champ $label est obligatoire.';
        }

        if (label == 'Téléphone' &&
            value.trim().replaceAll(RegExp(r'\s+'), '').length < 8) {
          return 'Veuillez saisir un numéro valide.';
        }

        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        onPressed: () => _ouvrirDialogueModification(context),
        icon: const Icon(Icons.edit_outlined, size: 20),
        label: const Text(
          'Modifier mon profil',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.primary,
          side: BorderSide(color: colors.primary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}

/// Conserve le contexte de la page derrière le bottom sheet.
BuildContext thisContext(BuildContext context) {
  return context;
}
