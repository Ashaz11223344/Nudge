import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:home_widget/home_widget.dart';
import 'package:nudge/core/constants/app_config.dart';
import 'package:nudge/data/models/quote_model.dart';
import 'package:nudge/data/services/quote_service.dart';
import 'package:nudge/data/services/local_storage_service.dart';
import 'package:nudge/data/repositories/user_repository.dart';
import 'package:nudge/data/repositories/mood_repository.dart';

class WidgetService {
  static const String _groupId = 'group.com.nudgeapp.nudge';
  static const String _androidWidgetName = 'NudgeWidgetProvider';
  static const String _iosWidgetName = 'NudgeWidget';

  static Future<void> init() async {
    await HomeWidget.setAppGroupId(_groupId);
    HomeWidget.registerBackgroundCallback(backgroundCallback);
  }

  static Future<void> updateWidgetData({
    String? quote,
    int? streak,
    String? mood,
  }) async {
    if (quote != null) {
      await HomeWidget.saveWidgetData(AppConfig.keyWidgetQuote, quote);
    }
    if (streak != null) {
      await HomeWidget.saveWidgetData(AppConfig.keyWidgetStreak, streak);
    }
    if (mood != null) {
      await HomeWidget.saveWidgetData(AppConfig.keyWidgetMood, mood);
    }
    
    await HomeWidget.saveWidgetData(
      AppConfig.keyWidgetLastUpdated, 
      DateTime.now().toIso8601String()
    );

    await HomeWidget.updateWidget(
      androidName: _androidWidgetName,
      iOSName: _iosWidgetName,
    );
  }

  static Future<void> syncAllData(
    UserRepository userRepo, 
    MoodRepository moodRepo,
    {String? currentQuote}
  ) async {
    final streak = userRepo.getStreakCount();
    final mood = moodRepo.getTodaysMood()?.label ?? 'No mood yet';
    
    await updateWidgetData(
      quote: currentQuote,
      streak: streak,
      mood: mood,
    );
  }
}

@pragma('vm:entry-point')
Future<void> backgroundCallback(Uri? uri) async {
  if (uri?.host == 'refresh') {
    // 1. Initialize core services
    final storage = LocalStorageService();
    await storage.init();
    
    final quoteService = QuoteService();
    await quoteService.loadQuotes();
    
    // 2. Get recent indices from storage
    final recentIndicesStr = storage.getString(AppConfig.keyRecentQuoteIndices) ?? '[]';
    // Note: LocalStorageService doesn't have a direct getIntList, but it has getJsonData
    final recentIndices = (storage.getJsonData(AppConfig.keyRecentQuoteIndices) as List?)?.cast<int>() ?? [];
    
    // 3. Pick fresh quote
    final quote = quoteService.getRandomQuote(recentIndices);
    
    // 4. Update storage (app state)
    await storage.setString(AppConfig.keyCurrentQuote, quote.text);
    
    // Update recent indices
    recentIndices.add(quote.index);
    if (recentIndices.length > AppConfig.recentQuoteBufferSize) {
      recentIndices.removeAt(0);
    }
    await storage.setJsonData(AppConfig.keyRecentQuoteIndices, recentIndices);

    // 5. Update Widget
    await HomeWidget.setAppGroupId('group.com.nudgeapp.nudge');
    await HomeWidget.saveWidgetData(AppConfig.keyWidgetQuote, quote.text);
    await HomeWidget.updateWidget(
      androidName: 'NudgeWidgetProvider',
      iOSName: 'NudgeWidget',
    );
  }
}
