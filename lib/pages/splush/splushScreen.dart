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
  static const Duration _minSplashDuration = Duration(milliseconds: 2000);

  late final AnimationController _controller;

  late final Animation<double> _logoFadeAnimation;
  late final Animation<double> _logoScaleAnimation;
  late final Animation<Offset> _logoSlideAnimation;

  late final Animation<double> _titleFadeAnimation;
  late final Animation<Offset> _titleSlideAnimation;

  late final Animation<double> _subtitleFadeAnimation;
  late final Animation<Offset> _subtitleSlideAnimation;

  late final Animation<double> _loaderFadeAnimation;

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: _minSplashDuration,
    );

    _logoFadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.35, curve: Curves.easeIn),
      ),
    );

    _logoScaleAnimation = Tween<double>(begin: 0.82, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.60, curve: Curves.easeOutCubic),
      ),
    );

    _logoSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.20),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.60, curve: Curves.easeOutCubic),
      ),
    );

    _titleFadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.30, 0.65, curve: Curves.easeIn),
      ),
    );

    _titleSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.20),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.30, 0.70, curve: Curves.easeOutCubic),
      ),
    );

    _subtitleFadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.55, 0.85, curve: Curves.easeIn),
      ),
    );

    _subtitleSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.55, 0.90, curve: Curves.easeOutCubic),
      ),
    );

    _loaderFadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.75, 1.0, curve: Curves.easeIn),
      ),
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
                FadeTransition(
                  opacity: _logoFadeAnimation,
                  child: SlideTransition(
                    position: _logoSlideAnimation,
                    child: ScaleTransition(
                      scale: _logoScaleAnimation,
                      child: Image.asset(
                        _logoAsset,
                        width: 160.w(context),
                        height: 160.w(context),
                        fit: BoxFit.contain,
                        semanticLabel: 'Logo $_appName',
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 24.h(context)),
                FadeTransition(
                  opacity: _titleFadeAnimation,
                  child: SlideTransition(
                    position: _titleSlideAnimation,
                    child: Text(
                      _appName,
                      textAlign: TextAlign.center,
                      style: context.headingTextStyle.copyWith(
                        fontSize: 28.w(context),
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                        color: context.primary,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 12.h(context)),
                FadeTransition(
                  opacity: _subtitleFadeAnimation,
                  child: SlideTransition(
                    position: _subtitleSlideAnimation,
                    child: Text(
                      _slogan,
                      textAlign: TextAlign.center,
                      style: context.normalTextStyle.copyWith(
                        fontSize: 15.w(context),
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.4,
                        height: 1.5,
                        color: context.textMuted,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 40.h(context)),
                FadeTransition(
                  opacity: _loaderFadeAnimation,
                  child: SizedBox(
                    width: 26.w(context),
                    height: 26.w(context),
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        context.primary,
                      ),
                    ),
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
