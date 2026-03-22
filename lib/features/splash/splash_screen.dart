import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nudge/core/constants/colors.dart';
import 'package:nudge/data/repositories/user_repository.dart';
import 'package:nudge/routes/app_routes.dart';
import 'package:nudge/shared/providers/app_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    // Show splash for at least 2 seconds for premium feel
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;

    final userRepo = context.read<UserRepository>();
    final appProvider = context.read<AppProvider>();
    
    final isOnboardingComplete = userRepo.isOnboardingComplete();
    
    if (isOnboardingComplete) {
      // Initialize app data if not already done
      await appProvider.init();
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      }
    } else {
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.blur_on, // Or any premium-looking icon from the app
              size: 80,
              color: AppColors.spicyPaprika,
            ),
            const SizedBox(height: 24),
            Text(
              'NUDGE',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    letterSpacing: 8.0,
                    fontWeight: FontWeight.w900,
                    color: AppColors.spicyPaprika,
                  ),
            ),
            const SizedBox(height: 48),
            const SizedBox(
              width: 40,
              child: LinearProgressIndicator(
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.spicyPaprika),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
