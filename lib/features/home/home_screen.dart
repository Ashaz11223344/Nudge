import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:nudge/core/constants/colors.dart';
import 'package:nudge/core/constants/strings.dart';
import 'package:nudge/core/theme/theme_provider.dart';
import 'package:nudge/core/utils/date_utils.dart';
import 'package:nudge/shared/providers/app_provider.dart';


import 'package:nudge/shared/widgets/share_bottom_sheet.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<AppProvider>(
          builder: (context, appProvider, _) {
            final themeProvider = context.watch<ThemeProvider>();
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header: Greeting + Profile
                  _buildHeader(context, appProvider),
                  const SizedBox(height: 40),

                  // Streak
                  if (appProvider.streaksEnabled) ...[
                    _buildStreakCard(context, appProvider),
                    const SizedBox(height: 40),
                  ],

                  // Daily Quote
                  _buildQuoteSection(context, appProvider, themeProvider),
                  const SizedBox(height: 24),

                  // Action Buttons
                  _buildActionButtons(context, appProvider),
                  const SizedBox(height: 40),

                  // Quick Access
                  _buildQuickAccess(context),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppProvider appProvider) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppDateUtils.getGreeting(),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.dustGrey,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                appProvider.userName.isNotEmpty
                    ? appProvider.userName
                    : 'Friend',
                style: Theme.of(context).textTheme.displayMedium,
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/profile'),
          child: CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.dustGrey.withValues(alpha: 0.3),
            backgroundImage: appProvider.getProfileImage(),
            child: appProvider.getProfileImage() == null
                ? const Icon(Icons.person, color: AppColors.dustGrey)
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildStreakCard(BuildContext context, AppProvider appProvider) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.spicyPaprika.withValues(alpha: 0.3),
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.local_fire_department,
                color: AppColors.spicyPaprika, size: 28),
            const SizedBox(width: 8),
            Text(
              '${appProvider.streakCount}',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.spicyPaprika,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(width: 8),
            Text(
              AppStrings.streak,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.dustGrey,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuoteSection(
      BuildContext context, AppProvider appProvider, ThemeProvider themeProvider) {
    final quote = appProvider.currentQuote;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.dustGrey.withValues(alpha: 0.3),
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.format_quote,
            color: AppColors.spicyPaprika,
            size: 32,
          ),
          const SizedBox(height: 16),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            transitionBuilder: (child, animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: Text(
              quote?.text ?? 'Loading...',
              key: ValueKey<String>(quote?.text ?? 'Loading'),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontSize: themeProvider.quoteFontSize,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
          if (quote != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.spicyPaprika.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                quote.category.toUpperCase(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.spicyPaprika,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, AppProvider appProvider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _actionButton(
          context,
          icon: Icons.refresh,
          label: 'Refresh',
          onTap: () => appProvider.refreshQuote(),
        ),
        _actionButton(
          context,
          icon: appProvider.isFavorite
              ? Icons.favorite
              : Icons.favorite_border,
          label: 'Favorite',
          onTap: () {
            HapticFeedback.lightImpact();
            appProvider.toggleFavorite();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  appProvider.isFavorite
                      ? AppStrings.removedFromFavorites
                      : AppStrings.addedToFavorites,
                ),
                duration: const Duration(seconds: 1),
              ),
            );
          },
          isActive: appProvider.isFavorite,
        ),
        _actionButton(
          context,
          icon: Icons.share_outlined,
          label: 'Share',
          onTap: () {
            HapticFeedback.lightImpact();
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => ShareBottomSheet(
                quote: appProvider.currentQuote!,
                userName: appProvider.userName,
              ),
            );
          },
        ),
        _actionButton(
          context,
          icon: Icons.copy_outlined,
          label: 'Copy',
          onTap: () {
            if (appProvider.currentQuote != null) {
              Clipboard.setData(
                ClipboardData(text: appProvider.currentQuote!.text),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(AppStrings.quoteCopied),
                  duration: Duration(seconds: 1),
                ),
              );
            }
          },
        ),
      ],
    );
  }

  Widget _actionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Column(
        children: [
          Icon(
            icon,
            color: isActive ? AppColors.spicyPaprika : AppColors.dustGrey,
            size: 26,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.dustGrey,
                  fontSize: 12,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccess(BuildContext context) {
    final items = [
      _QuickItem(Icons.favorite_border, 'Favorites', '/favorites'),
      _QuickItem(Icons.history, 'History', '/history'),
      _QuickItem(Icons.search, 'Search', '/search'),
      _QuickItem(Icons.emoji_emotions_outlined, 'Mood', '/mood'),
      _QuickItem(Icons.book_outlined, 'Journal', '/journal'),
      _QuickItem(Icons.settings_outlined, 'Settings', '/settings'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Explore',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.1,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.pushNamed(context, item.route);
              },
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.dustGrey.withValues(alpha: 0.3),
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(item.icon, color: AppColors.spicyPaprika, size: 28),
                    const SizedBox(height: 8),
                    Text(
                      item.label,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _QuickItem {
  final IconData icon;
  final String label;
  final String route;

  _QuickItem(this.icon, this.label, this.route);
}
