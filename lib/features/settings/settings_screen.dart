import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nudge/core/constants/app_config.dart';
import 'package:nudge/core/constants/colors.dart';
import 'package:nudge/core/theme/theme_provider.dart';
import 'package:nudge/shared/providers/app_provider.dart';
import 'package:nudge/shared/widgets/app_bar.dart';
import 'package:flutter/services.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Settings'),
      body: Consumer2<AppProvider, ThemeProvider>(
        builder: (context, appProvider, themeProvider, _) {
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              // --- Appearance ---
              _sectionHeader(context, 'Appearance'),
              _switchTile(
                context,
                icon: Icons.dark_mode_outlined,
                title: 'Dark Mode',
                value: themeProvider.isDarkMode,
                onChanged: (_) {
                  HapticFeedback.lightImpact();
                  themeProvider.toggleDarkMode();
                },
              ),
              _fontSizeTile(context, themeProvider),
              const Divider(height: 32),

              // --- Notifications ---
              _sectionHeader(context, 'Notifications'),
              _notificationFrequencyTile(context, appProvider),
              _switchTile(
                context,
                icon: Icons.do_not_disturb_on_outlined,
                title: 'Quiet Hours',
                subtitle: appProvider.quietHoursEnabled
                    ? '${_formatTimeOfDay(appProvider.quietHoursStart)} – ${_formatTimeOfDay(appProvider.quietHoursEnd)}'
                    : null,
                value: appProvider.quietHoursEnabled,
                onChanged: (val) {
                  HapticFeedback.lightImpact();
                  appProvider.setQuietHoursEnabled(val);
                },
              ),
              if (appProvider.quietHoursEnabled) ...[
                _timeTile(
                  context,
                  icon: Icons.bedtime_outlined,
                  title: 'Quiet Start',
                  time: appProvider.quietHoursStart,
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: appProvider.quietHoursStart,
                    );
                    if (time != null) {
                      appProvider.setQuietHoursStart(time);
                    }
                  },
                ),
                _timeTile(
                  context,
                  icon: Icons.wb_sunny_outlined,
                  title: 'Quiet End',
                  time: appProvider.quietHoursEnd,
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: appProvider.quietHoursEnd,
                    );
                    if (time != null) {
                      appProvider.setQuietHoursEnd(time);
                    }
                  },
                ),
              ],
              _actionTile(
                context,
                icon: Icons.notification_add_outlined,
                title: 'Test Notification',
                onTap: () {
                  appProvider.sendTestNotification();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Test notification sent!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
              const Divider(height: 32),

              // --- Quotes ---
              _sectionHeader(context, 'Quotes'),
              _timeTile(
                context,
                icon: Icons.schedule_outlined,
                title: 'Daily Refresh Time',
                time: appProvider.dailyRefreshTime,
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: appProvider.dailyRefreshTime,
                  );
                  if (time != null) {
                    appProvider.setDailyRefreshTime(time);
                  }
                },
              ),
              _categoryToggleTile(context, appProvider),
              const Divider(height: 32),

              // --- Profile ---
              _sectionHeader(context, 'Profile'),
              _actionTile(
                context,
                icon: Icons.person_outline,
                title: 'Change Name',
                subtitle: appProvider.userName,
                onTap: () => _showNameDialog(context, appProvider),
              ),
              _actionTile(
                context,
                icon: Icons.photo_camera_outlined,
                title: 'Change Profile Photo',
                onTap: () => Navigator.pushNamed(context, '/profile'),
              ),
              const Divider(height: 32),

              // --- Streaks ---
              _sectionHeader(context, 'Streaks'),
              _switchTile(
                context,
                icon: Icons.local_fire_department_outlined,
                title: 'Enable Streaks',
                value: appProvider.streaksEnabled,
                onChanged: (val) => appProvider.setStreaksEnabled(val),
              ),
              const Divider(height: 32),

              // --- Backup & Restore ---
              _sectionHeader(context, 'Backup & Restore'),
              _actionTile(
                context,
                icon: Icons.upload_outlined,
                title: 'Export Data',
                onTap: () async {
                  try {
                    final path = await appProvider.exportData();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Data exported to: $path')),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Export failed: $e')),
                      );
                    }
                  }
                },
              ),
              _actionTile(
                context,
                icon: Icons.download_outlined,
                title: 'Import Data',
                onTap: () => _showImportDialog(context, appProvider),
              ),
              const Divider(height: 32),

              // --- Clear Data ---
              _sectionHeader(context, 'Clear Data'),
              _actionTile(
                context,
                icon: Icons.favorite_border,
                title: 'Clear Favorites',
                isDestructive: true,
                onTap: () => _confirmClear(
                  context,
                  'Clear Favorites',
                  'This will remove all your saved favorites.',
                  () => appProvider.clearFavorites(),
                ),
              ),
              _actionTile(
                context,
                icon: Icons.history,
                title: 'Clear History',
                isDestructive: true,
                onTap: () => _confirmClear(
                  context,
                  'Clear History',
                  'This will remove all quote history.',
                  () => appProvider.clearHistory(),
                ),
              ),
              _actionTile(
                context,
                icon: Icons.delete_forever_outlined,
                title: 'Clear All Data',
                isDestructive: true,
                onTap: () => _confirmClear(
                  context,
                  'Clear All Data',
                  'This will reset the app to its initial state.',
                  () async {
                    await appProvider.clearAllData();
                    if (context.mounted) {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/onboarding',
                        (route) => false,
                      );
                    }
                  },
                ),
              ),
              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 4),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.spicyPaprika,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
      ),
    );
  }

  Widget _switchTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.dustGrey),
      title: Text(title),
      subtitle: subtitle != null
          ? Text(subtitle,
              style: const TextStyle(color: AppColors.dustGrey, fontSize: 12))
          : null,
      trailing: Switch(value: value, onChanged: onChanged),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
    );
  }

  Widget _actionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(icon,
          color: isDestructive ? AppColors.spicyPaprika : AppColors.dustGrey),
      title: Text(
        title,
        style: isDestructive
            ? const TextStyle(color: AppColors.spicyPaprika)
            : null,
      ),
      subtitle: subtitle != null
          ? Text(subtitle,
              style: const TextStyle(color: AppColors.dustGrey, fontSize: 12))
          : null,
      trailing: const Icon(Icons.chevron_right, color: AppColors.dustGrey),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
    );
  }

  Widget _timeTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required TimeOfDay time,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.dustGrey),
      title: Text(title),
      trailing: Text(
        _formatTimeOfDay(time),
        style: Theme.of(context)
            .textTheme
            .bodyLarge
            ?.copyWith(color: AppColors.spicyPaprika),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
    );
  }

  Widget _notificationFrequencyTile(
      BuildContext context, AppProvider appProvider) {
    return ListTile(
      leading:
          const Icon(Icons.notifications_outlined, color: AppColors.dustGrey),
      title: const Text('Notification Frequency'),
      subtitle: Text(
        appProvider.notificationFrequency == 0
            ? 'Off'
            : '${appProvider.notificationFrequency} per day',
        style: const TextStyle(color: AppColors.dustGrey, fontSize: 12),
      ),
      trailing: SizedBox(
        width: 180,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              appProvider.notificationFrequency == 0
                  ? 'Off'
                  : '${appProvider.notificationFrequency}',
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(color: AppColors.spicyPaprika),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Slider(
                value: appProvider.notificationFrequency.toDouble(),
                min: 0,
                max: 10,
                divisions: 10,
                onChanged: (val) {
                  HapticFeedback.selectionClick();
                  appProvider.setNotificationFrequency(val.toInt(), shouldReschedule: false);
                },
                onChangeEnd: (val) {
                  appProvider.setNotificationFrequency(val.toInt(), shouldReschedule: true);
                },
              ),
            ),
          ],
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
    );
  }

  Widget _fontSizeTile(BuildContext context, ThemeProvider themeProvider) {
    return ListTile(
      leading: const Icon(Icons.text_fields, color: AppColors.dustGrey),
      title: const Text('Font Size'),
      trailing: SegmentedButton<String>(
        segments: const [
          ButtonSegment(value: 'Small', label: Text('S')),
          ButtonSegment(value: 'Medium', label: Text('M')),
          ButtonSegment(value: 'Large', label: Text('L')),
        ],
        selected: {themeProvider.fontSize},
        onSelectionChanged: (val) {
          HapticFeedback.lightImpact();
          themeProvider.setFontSize(val.first);
        },
        style: ButtonStyle(
          visualDensity: VisualDensity.compact,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
    );
  }

  Widget _categoryToggleTile(BuildContext context, AppProvider appProvider) {
    return ExpansionTile(
      leading: const Icon(Icons.category_outlined, color: AppColors.dustGrey),
      title: const Text('Quote Categories'),
      tilePadding: const EdgeInsets.symmetric(horizontal: 24),
      childrenPadding: const EdgeInsets.symmetric(horizontal: 24),
      children: AppConfig.quoteCategories.map((cat) {
        final isEnabled = appProvider.enabledCategories.contains(cat);
        return CheckboxListTile(
          title:
              Text(cat[0].toUpperCase() + cat.substring(1)),
          value: isEnabled,
          activeColor: AppColors.spicyPaprika,
          onChanged: (_) {
            HapticFeedback.lightImpact();
            appProvider.toggleCategory(cat);
          },
        );
      }).toList(),
    );
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '${hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} $period';
  }

  void _showNameDialog(BuildContext context, AppProvider appProvider) {
    final controller = TextEditingController(text: appProvider.userName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Change Name'),
        content: TextField(
          controller: controller,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(hintText: 'Enter your name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                appProvider.updateUserName(name);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showImportDialog(BuildContext context, AppProvider appProvider) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Import Data'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter the path to your backup file:'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: '/path/to/nudge_backup.json',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final path = controller.text.trim();
              if (path.isNotEmpty) {
                try {
                  await appProvider.importData(path);
                  if (ctx.mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Data imported successfully')),
                    );
                  }
                } catch (e) {
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Import failed: $e')),
                    );
                  }
                }
              }
            },
            child: const Text('Import'),
          ),
        ],
      ),
    );
  }

  void _confirmClear(
    BuildContext context,
    String title,
    String message,
    VoidCallback onConfirm,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              onConfirm();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$title completed')),
              );
            },
            child: const Text('Confirm',
                style: TextStyle(color: AppColors.spicyPaprika)),
          ),
        ],
      ),
    );
  }
}
