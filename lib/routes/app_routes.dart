import 'package:flutter/material.dart';
import 'package:nudge/features/onboarding/onboarding_screen.dart';
import 'package:nudge/features/home/home_screen.dart';
import 'package:nudge/features/favorites/favorites_screen.dart';
import 'package:nudge/features/history/history_screen.dart';
import 'package:nudge/features/search/search_screen.dart';
import 'package:nudge/features/mood/mood_screen.dart';
import 'package:nudge/features/journal/journal_screen.dart';
import 'package:nudge/features/profile/profile_screen.dart';
import 'package:nudge/features/settings/settings_screen.dart';

import 'package:nudge/features/splash/splash_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String home = '/home';
  static const String favorites = '/favorites';
  static const String history = '/history';
  static const String search = '/search';
  static const String mood = '/mood';
  static const String journal = '/journal';
  static const String profile = '/profile';
  static const String settings = '/settings';

  static Map<String, WidgetBuilder> get routes => {
        splash: (context) => const SplashScreen(),
        onboarding: (context) => const OnboardingScreen(),
        home: (context) => const HomeScreen(),
        favorites: (context) => const FavoritesScreen(),
        history: (context) => const HistoryScreen(),
        search: (context) => const SearchScreen(),
        mood: (context) => const MoodScreen(),
        journal: (context) => const JournalScreen(),
        profile: (context) => const ProfileScreen(),
        settings: (context) => const SettingsScreen(),
      };
}
