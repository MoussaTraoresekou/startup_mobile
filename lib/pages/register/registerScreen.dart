import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:startup_mobile/commun_widget/custom_text_field.dart';
import 'package:startup_mobile/commun_widget/primary_button.dart';
import 'package:startup_mobile/cor/theme/app_theme.dart';
import 'package:startup_mobile/cor/utils/size_config.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  static const String _logoAsset = 'assets/images/onboarding/logo_startup.png';
  static const double _sheetOverlap = 32;
  static final RegExp _emailRegex = RegExp(
    r'^[\w\-.]+@([\w\-]+\.)+[\w\-]{2,}$',
  );

  /// `code` est envoyé à l'API (stable), `label` est affiché à l'écran.
  static const List<({String code, String label})> _investorTypes = [
    (
      code: 'INDIVIDUEL_DIASPORA',
      label: 'Investisseur Individuel / Diaspora',
    ),
    (
      code: 'OPERATEUR_ECONOMIQUE',
      label: 'Opérateur Économique / Groupe Industriel',
    ),
    (
      code: 'FONDS_INVESTISSEMENT',
      label: "Fonds d'Investissement / Capital-Risque",
    ),
    (
      code: 'INSTITUTION_FINANCIERE',
      label: 'Institution Financière / Microfinance',
    ),
  ];

  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  late final AnimationController _entryController;

  String? _selectedInvestorType; // code
  bool _hidePassword = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage(_logoAsset), context);
  }

  @override
  void dispose() {
    _entryController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    if (_isLoading) return;
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);
    try {
      // TODO: brancher l'appel POST vers /api/investisseur/register avec :
      // prénom, nom, e-mail, mot de passe et type d'investisseur
      // (_selectedInvestorType = code). Les secteurs, tickets et régions
      // seront demandés dans le profil, à la première connexion.
      await Future<void>.delayed(const Duration(milliseconds: 1500));
      if (mounted) context.go('/login');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _reveal({
    required Widget child,
    required double start,
    required double end,
    double dy = 0.10,
  }) {
    final animation = CurvedAnimation(
      parent: _entryController,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: Offset(0, dy),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: context.bgColor,
        body: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(context),
              Transform.translate(
                offset: const Offset(0, -_sheetOverlap),
                child: _buildFormSheet(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final Color start = context.navbarColor;
    final Color end = Color.lerp(context.navbarColor, Colors.black, 0.30)!;

    return Container(
      width: double.infinity,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [start, end],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -60.w(context),
            right: -50.w(context),
            child: _decorCircle(190.w(context), 0.10),
          ),
          Positioned(
            top: 50.h(context),
            left: -70.w(context),
            child: _decorCircle(150.w(context), 0.07),
          ),
          SafeArea(
            bottom: false,
            child: SizedBox(
              width: double.infinity,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  24.w(context),
                  24.h(context),
                  24.w(context),
                  _sheetOverlap + 28.h(context),
                ),
                child: _reveal(
                  start: 0.0,
                  end: 0.50,
                  dy: -0.08,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(12.w(context)),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Image.asset(
                          _logoAsset,
                          width: 48.w(context),
                          height: 48.w(context),
                          fit: BoxFit.contain,
                          semanticLabel: 'Logo Entrepreneur360',
                        ),
                      ),
                      SizedBox(height: 14.h(context)),
                      Text(
                        'Créer un compte',
                        textAlign: TextAlign.center,
                        style: context.headingTextStyle.copyWith(
                          fontSize: 22.w(context),
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4.h(context)),
                      Text(
                        "Rejoignez l'écosystème d'investisseurs.",
                        textAlign: TextAlign.center,
                        style: context.normalTextStyle.copyWith(
                          fontSize: 13.w(context),
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _decorCircle(double size, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: opacity),
      ),
    );
  }

  Widget _buildFormSheet(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
      ),
      padding: EdgeInsets.fromLTRB(
        24.w(context),
        32.h(context),
        24.w(context),
        24.h(context),
      ),
      child: SafeArea(
        top: false,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _reveal(
                start: 0.15,
                end: 0.65,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: 'Prénom',
                        hintText: 'Prénom',
                        controller: _firstNameController,
                        validator: (value) =>
                            (value?.trim().isEmpty ?? true) ? 'Requis' : null,
                      ),
                    ),
                    SizedBox(width: 16.w(context)),
                    Expanded(
                      child: CustomTextField(
                        label: 'Nom',
                        hintText: 'Nom',
                        controller: _lastNameController,
                        validator: (value) =>
                            (value?.trim().isEmpty ?? true) ? 'Requis' : null,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 18.h(context)),
              _reveal(
                start: 0.28,
                end: 0.78,
                child: _buildInvestorTypeDropdown(context),
              ),
              SizedBox(height: 18.h(context)),
              _reveal(
                start: 0.40,
                end: 0.88,
                child: CustomTextField(
                  label: 'Adresse e-mail',
                  hintText: 'nom@exemple.com',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  validator: (value) {
                    final email = value?.trim() ?? '';
                    if (email.isEmpty) return "L'email est requis";
                    if (!_emailRegex.hasMatch(email)) {
                      return "Format d'email invalide";
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(height: 18.h(context)),
              _reveal(
                start: 0.52,
                end: 0.95,
                child: CustomTextField(
                  label: 'Mot de passe',
                  hintText: '••••••••',
                  controller: _passwordController,
                  isPassword: _hidePassword,
                  prefixIcon: Icons.lock_outline,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _hidePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: context.iconColor,
                    ),
                    onPressed: () =>
                        setState(() => _hidePassword = !_hidePassword),
                  ),
                  validator: (value) => (value == null || value.length < 6)
                      ? 'Minimum 6 caractères'
                      : null,
                ),
              ),
              SizedBox(height: 32.h(context)),
              _reveal(
                start: 0.65,
                end: 1.0,
                child: PrimaryButton(
                  label: 'Créer mon compte',
                  isLoading: _isLoading,
                  onPressed: _onSubmit,
                ),
              ),
              SizedBox(height: 24.h(context)),
              _reveal(
                start: 0.72,
                end: 1.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Déjà inscrit ?',
                      style: context.normalTextStyle.copyWith(
                        fontSize: 14,
                        color: context.textMuted,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.go('/login'),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Se connecter',
                        style: context.normalTextStyle.copyWith(
                          fontSize: 14,
                          color: context.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInvestorTypeDropdown(BuildContext context) {
    OutlineInputBorder border(Color color, {double width = 1}) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Type d'investisseur",
          style: context.normalTextStyle.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedInvestorType,
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: context.iconColor,
          ),
          dropdownColor: context.background,
          borderRadius: BorderRadius.circular(12),
          style: context.normalTextStyle.copyWith(fontSize: 15),
          hint: Text(
            'Sélectionnez votre profil',
            style: context.normalTextStyle.copyWith(
              fontSize: 15,
              color: context.textMuted,
            ),
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: context.background,
            prefixIcon: Icon(
              Icons.assignment_ind_outlined,
              color: context.iconColor,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
            enabledBorder: border(context.borderColor),
            focusedBorder: border(context.borderSelected, width: 1.5),
            errorBorder: border(context.badgeRed),
            focusedErrorBorder: border(context.badgeRed, width: 1.5),
          ),
          items: [
            for (final type in _investorTypes)
              DropdownMenuItem<String>(
                value: type.code,
                child: Text(
                  type.label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
          onChanged: (value) => setState(() => _selectedInvestorType = value),
          validator: (value) =>
              value == null ? 'Veuillez choisir un profil' : null,
        ),
      ],
    );
  }
}