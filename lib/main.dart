import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'providers/theme_provider.dart';
import 'screens/main_navigation_screen.dart';
import 'screens/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final hasOnboarded = prefs.getBool(AppConstants.prefHasOnboarded) ?? false;

  runApp(
    ProviderScope(
      child: SalaryFlowApp(hasOnboarded: hasOnboarded),
    ),
  );
}

class SalaryFlowApp extends ConsumerWidget {
  final bool hasOnboarded;

  const SalaryFlowApp({super.key, required this.hasOnboarded});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: hasOnboarded ? const MainNavigationScreen() : const OnboardingScreen(),
    );
  }
}

