import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:nudge/core/constants/colors.dart';
import 'package:nudge/data/models/quote_model.dart';
import 'package:nudge/data/repositories/quote_repository.dart';
import 'package:nudge/shared/providers/app_provider.dart';
import 'package:nudge/shared/widgets/app_bar.dart';
import 'package:nudge/shared/widgets/empty_state.dart';
import 'package:nudge/shared/widgets/share_bottom_sheet.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<QuoteModel> _history = [];

  @override
  void initState() {
    super.initState();
    _history = context.read<QuoteRepository>().getHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'History'),
      body: _history.isEmpty
          ? const CustomEmptyState(
              icon: Icons.history,
              title: 'No history yet',
              subtitle: 'Your reading history will appear here',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(24),
              itemCount: _history.length,
              separatorBuilder: (context2, index2) => const Divider(height: 32),
              itemBuilder: (context, index) {
                final quote = _history[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '"${quote.text}"',
                        style:
                            Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  height: 1.6,
                                  fontStyle: FontStyle.italic,
                                ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.spicyPaprika
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              quote.category.toUpperCase(),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: AppColors.spicyPaprika,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1,
                                  ),
                            ),
                          ),
                          const Spacer(),
                           IconButton(
                            icon: const Icon(Icons.share_outlined, size: 18),
                            color: AppColors.dustGrey,
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (context) => ShareBottomSheet(
                                  quote: quote,
                                  userName: context.read<AppProvider>().userName,
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon:
                                const Icon(Icons.copy_outlined, size: 18),
                            color: AppColors.dustGrey,
                            onPressed: () {
                              Clipboard.setData(
                                  ClipboardData(text: quote.text));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Copied'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
