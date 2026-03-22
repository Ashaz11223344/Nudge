import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nudge/core/constants/strings.dart';
import 'package:nudge/core/theme/theme_provider.dart';
import 'package:nudge/data/repositories/journal_repository.dart';
import 'package:nudge/data/repositories/mood_repository.dart';
import 'package:nudge/data/repositories/quote_repository.dart';
import 'package:nudge/data/repositories/user_repository.dart';
import 'package:nudge/data/services/file_service.dart';
import 'package:nudge/data/services/local_storage_service.dart';
import 'package:nudge/data/services/notification_service.dart';
import 'package:nudge/data/services/quote_service.dart';
import 'package:nudge/data/services/widget_service.dart';
import 'package:nudge/routes/app_routes.dart';
import 'package:nudge/shared/providers/app_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  final storageService = LocalStorageService();
  await storageService.init();

  final quoteService = QuoteService();
  final notificationService = NotificationService();
  await notificationService.init();
  await notificationService.requestPermissions();
  
  await WidgetService.init();

  final fileService = FileService();

  // Initialize repositories
  final quoteRepository = QuoteRepository(storageService);
  final userRepository = UserRepository(storageService);
  final moodRepository = MoodRepository(storageService);
  final journalRepository = JournalRepository(storageService);

  // Initialize providers
  final themeProvider = ThemeProvider(notificationService: notificationService);
  await themeProvider.loadPreferences();

  final appProvider = AppProvider(
    storageService: storageService,
    quoteService: quoteService,
    notificationService: notificationService,
    fileService: fileService,
    quoteRepository: quoteRepository,
    userRepository: userRepository,
    moodRepository: moodRepository,
  );

  // Initial route is always splash
  const initialRoute = AppRoutes.splash;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider.value(value: appProvider),
        Provider.value(value: storageService),
        Provider.value(value: quoteService),
        Provider.value(value: notificationService),
        Provider.value(value: fileService),
        Provider.value(value: quoteRepository),
        Provider.value(value: userRepository),
        Provider.value(value: moodRepository),
        Provider.value(value: journalRepository),
      ],
      child: NudgeApp(initialRoute: initialRoute),
    ),
  );
}

class NudgeApp extends StatelessWidget {
  final String initialRoute;

  const NudgeApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp(
          title: AppStrings.appName,
          debugShowCheckedModeBanner: false,
          theme: themeProvider.currentTheme,
          initialRoute: initialRoute,
          routes: AppRoutes.routes,
        );
      },
    );
  }
}
