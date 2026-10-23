import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:startup_mobile/cor/theme/app_theme.dart';
import 'package:startup_mobile/cor/utils/size_config.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const String _logoAsset = 'assets/images/onboarding/logo_startup.png';
  static const String _appName = 'Entrepreneur360';
  static const String _slogan = 'Repérez, échangez, investissez.';
  static const Duration _minSplashDuration = Duration(milliseconds: 2200);

  late final AnimationController _controller;
  late final Animation<Offset> _logoSlide;
  late final Animation<double> _texteFade;

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: _minSplashDuration,
    );

    // Le logo tombe du haut de l'écran jusqu'à sa place.
    _logoSlide = Tween<Offset>(
      begin: const Offset(0, -4),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.bounceOut),
      ),
    );

    // Le texte apparaît ensuite.
    _texteFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.6, 1.0, curve: Curves.easeIn),
    );

    _controller.forward();
    _initializeApp();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage(_logoAsset), context);
  }

  Future<void> _initializeApp() async {
    final Future<void> minTimer = Future<void>.delayed(_minSplashDuration);
    final Future<String> routeFuture = _getInitialRoute();

    final String nextRoute = await routeFuture;
    await minTimer;

    if (!mounted) return;
    context.go(nextRoute);
  }

  Future<String> _getInitialRoute() async {
    try {
      final String? token = await _secureStorage.read(key: 'jwt_token');

      if (token != null && token.trim().isNotEmpty) {
        return '/investor-dashboard';
      }
      return '/login';
    } catch (_) {
      return '/login';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgColor,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w(context)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SlideTransition(
                  position: _logoSlide,
                  child: Image.asset(
                    _logoAsset,
                    width: 150,
                    height: 150,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 24),
                FadeTransition(
                  opacity: _texteFade,
                  child: Column(
                    children: [
                      Text(
                        _appName,
                        textAlign: TextAlign.center,
                        style: context.headingTextStyle.copyWith(
                          fontSize: 28.sp(context),
                          fontWeight: FontWeight.w800,
                          color: context.primary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _slogan,
                        textAlign: TextAlign.center,
                        style: context.normalTextStyle.copyWith(
                          fontSize: 15.sp(context),
                          color: context.textMuted,
                        ),
                      ),
                      const SizedBox(height: 36),
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: context.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}