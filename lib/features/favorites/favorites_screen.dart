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

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<QuoteModel> _favorites = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  void _loadFavorites() {
    final quoteRepo = context.read<QuoteRepository>();
    setState(() {
      _favorites = quoteRepo.getFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Favorites'),
      body: _favorites.isEmpty
          ? const CustomEmptyState(
              icon: Icons.favorite_border,
              title: 'No favorites yet',
              subtitle: 'Tap the heart icon on quotes you love',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(24),
              itemCount: _favorites.length,
              separatorBuilder: (context2, index2) => const Divider(height: 32),
              itemBuilder: (context, index) {
                final quote = _favorites[index];
                return _buildQuoteItem(context, quote);
              },
            ),
    );
  }

  Widget _buildQuoteItem(BuildContext context, QuoteModel quote) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '"${quote.text}"',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  height: 1.6,
                  fontStyle: FontStyle.italic,
                ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.spicyPaprika.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  quote.category.toUpperCase(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.spicyPaprika,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.copy_outlined, size: 18),
                color: AppColors.dustGrey,
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: quote.text));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Copied'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),
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
                icon: const Icon(Icons.delete_outline, size: 18),
                color: AppColors.dustGrey,
                onPressed: () async {
                  final appProvider = context.read<AppProvider>();
                  final quoteRepo = context.read<QuoteRepository>();
                  await quoteRepo.removeFavorite(quote);
                  // Update favorite state if current quote was unfavorited
                  if (appProvider.currentQuote?.text == quote.text) {
                    appProvider.refreshQuote();
                  }
                  _loadFavorites();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
