import 'package:flutter/material.dart';
import 'package:nudge/core/constants/colors.dart';

ThemeData darkTheme(double baseFontSize) {
  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.carbonBlack,
    primaryColor: AppColors.spicyPaprika,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.spicyPaprika,
      secondary: AppColors.spicyPaprika,
      surface: AppColors.carbonBlack,
      onPrimary: AppColors.floralWhite,
      onSecondary: AppColors.floralWhite,
      onSurface: AppColors.floralWhite,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.carbonBlack,
      foregroundColor: AppColors.floralWhite,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
    ),
    textTheme: TextTheme(
      displayLarge: TextStyle(
        color: AppColors.floralWhite,
        fontSize: baseFontSize + 16,
        fontWeight: FontWeight.w700,
      ),
      displayMedium: TextStyle(
        color: AppColors.floralWhite,
        fontSize: baseFontSize + 10,
        fontWeight: FontWeight.w600,
      ),
      headlineMedium: TextStyle(
        color: AppColors.floralWhite,
        fontSize: baseFontSize + 6,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: TextStyle(
        color: AppColors.floralWhite,
        fontSize: baseFontSize + 4,
        fontWeight: FontWeight.w600,
      ),
      titleMedium: TextStyle(
        color: AppColors.floralWhite,
        fontSize: baseFontSize + 2,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: TextStyle(
        color: AppColors.floralWhite,
        fontSize: baseFontSize,
        fontWeight: FontWeight.w400,
      ),
      bodyMedium: TextStyle(
        color: AppColors.floralWhite,
        fontSize: baseFontSize - 2,
        fontWeight: FontWeight.w400,
      ),
      labelLarge: TextStyle(
        color: AppColors.floralWhite,
        fontSize: baseFontSize,
        fontWeight: FontWeight.w600,
      ),
    ),
    iconTheme: const IconThemeData(
      color: AppColors.floralWhite,
    ),
    dividerColor: AppColors.dustGrey.withValues(alpha: 0.3),
    cardTheme: const CardThemeData(
      color: AppColors.charcoalBrown,
      elevation: 0,
      margin: EdgeInsets.zero,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.spicyPaprika,
        foregroundColor: AppColors.floralWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.spicyPaprika,
        side: const BorderSide(color: AppColors.spicyPaprika),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.spicyPaprika,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.charcoalBrown,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.dustGrey),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.dustGrey.withValues(alpha: 0.5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.spicyPaprika, width: 2),
      ),
      hintStyle: TextStyle(
        color: AppColors.dustGrey,
        fontSize: baseFontSize,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.carbonBlack,
      selectedItemColor: AppColors.spicyPaprika,
      unselectedItemColor: AppColors.dustGrey,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.spicyPaprika,
      foregroundColor: AppColors.floralWhite,
      elevation: 0,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.spicyPaprika;
        }
        return AppColors.dustGrey;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.spicyPaprika.withValues(alpha: 0.3);
        }
        return AppColors.dustGrey.withValues(alpha: 0.3);
      }),
    ),
    sliderTheme: const SliderThemeData(
      activeTrackColor: AppColors.spicyPaprika,
      inactiveTrackColor: AppColors.dustGrey,
      thumbColor: AppColors.spicyPaprika,
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );
}
