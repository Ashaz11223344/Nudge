import 'package:flutter/material.dart';

class AppConfig {
  AppConfig._();

  // Notification defaults
  static const int defaultNotificationFrequency = 3;
  static const TimeOfDay defaultQuietHoursStart = TimeOfDay(hour: 22, minute: 0);
  static const TimeOfDay defaultQuietHoursEnd = TimeOfDay(hour: 7, minute: 0);
  static const TimeOfDay defaultDailyRefreshTime = TimeOfDay(hour: 8, minute: 0);

  // Font sizes
  static const double fontSizeSmall = 14.0;
  static const double fontSizeMedium = 16.0;
  static const double fontSizeLarge = 18.0;

  // Quote font sizes
  static const double quoteFontSizeSmall = 18.0;
  static const double quoteFontSizeMedium = 22.0;
  static const double quoteFontSizeLarge = 26.0;

  // Categories
  static const List<String> quoteCategories = [
    'motivation',
    'love',
    'focus',
    'life',
    'healing',
  ];

  // Recent quotes buffer size (to avoid repeating)
  static const int recentQuoteBufferSize = 50;

  // SharedPreferences keys
  static const String keyUserName = 'user_name';
  static const String keyProfileImagePath = 'profile_image_path';
  static const String keyOnboardingComplete = 'onboarding_complete';
  static const String keyDarkMode = 'dark_mode';
  static const String keyNotificationFrequency = 'notification_frequency';
  static const String keyQuietHoursEnabled = 'quiet_hours_enabled';
  static const String keyQuietHoursStart = 'quiet_hours_start';
  static const String keyQuietHoursEnd = 'quiet_hours_end';
  static const String keyFontSize = 'font_size';
  static const String keyStreaksEnabled = 'streaks_enabled';
  static const String keyStreakCount = 'streak_count';
  static const String keyLastActiveDate = 'last_active_date';
  static const String keyFavorites = 'favorites';
  static const String keyHistory = 'history';
  static const String keyRecentQuoteIndices = 'recent_quote_indices';
  static const String keyMoodEntries = 'mood_entries';
  static const String keyJournalEntries = 'journal_entries';
  static const String keyDailyRefreshTime = 'daily_refresh_time';
  static const String keyEnabledCategories = 'enabled_categories';
  static const String keyCurrentQuote = 'current_quote';
  static const String keyCurrentQuoteDate = 'current_quote_date';
  
  // Widget Keys
  static const String keyWidgetQuote = 'widget_quote';
  static const String keyWidgetAuthor = 'widget_author'; // if used, but Nudge seems to just have quote text
  static const String keyWidgetStreak = 'widget_streak';
  static const String keyWidgetMood = 'widget_mood';
  static const String keyWidgetLastUpdated = 'widget_last_updated';
}
