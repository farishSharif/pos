import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/theme/app_theme.dart';
import 'core/widgets/connectivity_overlay.dart';
import 'router.dart';
import 'supabase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  // Initialize Hive
  await Hive.initFlutter();

  // Initialize Supabase if configured
  final isConfigured = supabaseUrl.isNotEmpty &&
      supabaseUrl != 'YOUR_SUPABASE_URL' &&
      supabaseAnon.isNotEmpty &&
      supabaseAnon != 'YOUR_SUPABASE_ANON_KEY';

  if (isConfigured) {
    try {
      await Supabase.initialize(
        url: supabaseUrl,
        publishableKey: supabaseAnon,
      );
    } catch (e) {
      debugPrint('Error initializing Supabase: $e');
    }
  }

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'ROYAL FF',
      theme: AppTheme.darkTheme,
      routerConfig: goRouter,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return ConnectivityOverlay(
          child: child ?? const SizedBox(),
        );
      },
    );
  }
}
