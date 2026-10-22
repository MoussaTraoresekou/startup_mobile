
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:startup_mobile/cor/router/routes.dart';
import 'package:startup_mobile/repository/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://zoagjvcjrolrrlhdkhob.supabase.co',
    anonKey: 'sb_publishable_KDK3Dxx_1XfarmHK1CI5YA_c4aRncjy',
  );

  await initializeDateFormatting('fr_FR', null);
  Intl.defaultLocale = 'fr_FR';

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Entrepreneur360',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      themeMode: themeMode,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
    );
  }
}
