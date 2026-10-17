import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:startup_mobile/commun_widget/custom_text_field.dart';
import 'package:startup_mobile/commun_widget/primary_button.dart';
import 'package:startup_mobile/controller/Auth/auth_controller.dart';
import 'package:startup_mobile/cor/router/routes.dart';
import 'package:startup_mobile/cor/theme/app_theme.dart';
import 'package:startup_mobile/cor/utils/async_value_ui.dart';
import 'package:startup_mobile/cor/utils/size_config.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  static const String _logoAsset = 'assets/images/onboarding/logo_startup.png';
  static const double _sheetOverlap = 32;

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  late final AnimationController _entryController;
  bool _hidePassword = true;

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
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    ref
        .read(authControllerProvider.notifier)
        .login(
          email: _emailController.text,
          password: _passwordController.text,
        );
  }

  Widget _reveal({
    required Widget child,
    required double start,
    required double end,
    double dy = 0.12,
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
    final state = ref.watch(authControllerProvider);

    ref.listen<AsyncValue>(authControllerProvider, (_, nextState) {
      nextState.showErrorDialog(context);
    });

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
                child: _buildFormSheet(context, state.isLoading),
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
            top: 70.h(context),
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
                  28.h(context),
                  24.w(context),
                  _sheetOverlap + 32.h(context),
                ),
                child: _reveal(
                  start: 0.0,
                  end: 0.55,
                  dy: -0.10,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(14.w(context)),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.18),
                              blurRadius: 24,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Image.asset(
                          _logoAsset,
                          width: 56.w(context),
                          height: 56.w(context),
                          fit: BoxFit.contain,
                        ),
                      ),
                      SizedBox(height: 18.h(context)),
                      Text(
                        'Entrepreneur360',
                        textAlign: TextAlign.center,
                        style: context.headingTextStyle.copyWith(
                          fontSize: 22.w(context),
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 6.h(context)),
                      Text(
                        'Repérez, échangez, investissez.',
                        textAlign: TextAlign.center,
                        style: context.normalTextStyle.copyWith(
                          fontSize: 14.w(context),
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

  Widget _buildFormSheet(BuildContext context, bool isLoading) {
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
                start: 0.20,
                end: 0.75,
                child: CustomTextField(
                  label: 'Adresse e-mail',
                  hintText: 'nom@exemple.com',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "L'email est requis";
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(height: 20.h(context)),
              _reveal(
                start: 0.35,
                end: 0.85,
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
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Le mot de passe est requis";
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(height: 16.h(context)),
              _reveal(
                start: 0.45,
                end: 0.90,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Mot de passe oublié ?',
                      style: context.normalTextStyle.copyWith(
                        fontSize: 13,
                        color: context.primary,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 28.h(context)),
              _reveal(
                start: 0.55,
                end: 1.0,
                child: PrimaryButton(
                  label: 'Se connecter',
                  isLoading: isLoading,
                  onPressed: _onSubmit,
                ),
              ),
              SizedBox(height: 24.h(context)),
              _reveal(
                start: 0.65,
                end: 1.0,
                child: Center(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Pas de compte ? ',
                          style: context.normalTextStyle.copyWith(
                            fontSize: 14,
                            color: context.textDark,
                          ),
                        ),
                        TextSpan(
                          text: "S'inscrire",
                          style: context.normalTextStyle.copyWith(
                            fontSize: 14,
                            color: context.primary,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              context.goNamed(AppRoutes.register.name);
                            },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
