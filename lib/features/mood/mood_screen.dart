import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nudge/core/constants/colors.dart';
import 'package:nudge/core/utils/date_utils.dart';
import 'package:nudge/data/models/mood_model.dart';
import 'package:nudge/data/repositories/mood_repository.dart';
import 'package:nudge/shared/widgets/app_bar.dart';
import 'package:nudge/shared/providers/app_provider.dart';

class MoodScreen extends StatefulWidget {
  const MoodScreen({super.key});

  @override
  State<MoodScreen> createState() => _MoodScreenState();
}

class _MoodScreenState extends State<MoodScreen> {
  MoodModel? _todaysMood;
  List<MoodModel> _moodHistory = [];

  @override
  void initState() {
    super.initState();
    _loadMoodData();
  }

  void _loadMoodData() {
    final moodRepo = context.read<MoodRepository>();
    setState(() {
      _todaysMood = moodRepo.getTodaysMood();
      _moodHistory = moodRepo.getAllMoods();
    });
  }

  Future<void> _selectMood(String emoji, String label) async {
    final moodRepo = context.read<MoodRepository>();
    final mood = MoodModel(
      emoji: emoji,
      label: label,
      date: DateTime.now(),
    );
    await moodRepo.addMood(mood);
    _loadMoodData();
    if (mounted) {
      context.read<AppProvider>().notifyMoodChanged();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Mood Tracker'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Today's mood section
            Text(
              'How are you feeling today?',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),

            // Emoji grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
              ),
              itemCount: MoodModel.availableMoods.length,
              itemBuilder: (context, index) {
                final mood = MoodModel.availableMoods[index];
                final isSelected =
                    _todaysMood?.emoji == mood['emoji'];
                return GestureDetector(
                  onTap: () =>
                      _selectMood(mood['emoji']!, mood['label']!),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected
                            ? AppColors.spicyPaprika
                            : AppColors.dustGrey.withValues(alpha: 0.3),
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          mood['emoji']!,
                          style: const TextStyle(fontSize: 24),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          mood['label']!,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(fontSize: 9),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            if (_todaysMood != null) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.spicyPaprika.withValues(alpha: 0.3),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Text(_todaysMood!.emoji,
                        style: const TextStyle(fontSize: 32)),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Today you\'re feeling',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: AppColors.dustGrey),
                        ),
                        Text(
                          _todaysMood!.label,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                color: AppColors.spicyPaprika,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],

            // History
            if (_moodHistory.isNotEmpty) ...[
              const SizedBox(height: 40),
              Text(
                'Mood History',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _moodHistory.length,
                separatorBuilder: (context2, index2) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final mood = _moodHistory[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      children: [
                        Text(mood.emoji,
                            style: const TextStyle(fontSize: 28)),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                mood.label,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                        fontWeight: FontWeight.w500),
                              ),
                              Text(
                                AppDateUtils.getRelativeDate(mood.date),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                        color: AppColors.dustGrey,
                                        fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
