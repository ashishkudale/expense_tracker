import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/di/di.dart';
import '../features/onboarding/pages/onboarding_page.dart';
import '../features/home/pages/home_page.dart';
import '../features/settings/pages/settings_page.dart';
import '../features/categories/presentation/pages/categories_page.dart';

class AppRouter {
  static const String onboarding = '/onboarding';
  static const String home = '/home';
  static const String settings = '/settings';
  static const String categories = '/categories';
  
  static GoRouter router() {
    return GoRouter(
      initialLocation: home,
      redirect: (BuildContext context, GoRouterState state) {
        final prefs = getIt<SharedPreferences>();
        final onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;
        
        final isOnboardingRoute = state.matchedLocation == onboarding;
        
        if (!onboardingCompleted && !isOnboardingRoute) {
          return onboarding;
        }
        
        if (onboardingCompleted && isOnboardingRoute) {
          return home;
        }
        
        return null;
      },
      routes: [
        GoRoute(
          path: onboarding,
          builder: (context, state) => const OnboardingPage(),
        ),
        GoRoute(
          path: home,
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: settings,
          builder: (context, state) => const SettingsPage(),
        ),
        GoRoute(
          path: categories,
          builder: (context, state) => const CategoriesPage(),
        ),
      ],
    );
  }
}