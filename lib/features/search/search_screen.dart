import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:nudge/core/constants/app_config.dart';
import 'package:nudge/core/constants/colors.dart';
import 'package:nudge/data/models/quote_model.dart';
import 'package:nudge/data/services/quote_service.dart';
import 'package:nudge/shared/widgets/app_bar.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  String? _selectedCategory;
  List<QuoteModel> _results = [];
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch() {
    _performSearch();
  }

  void _performSearch() {
    final quoteService = context.read<QuoteService>();
    final query = _searchController.text.trim();

    setState(() {
      _hasSearched = query.isNotEmpty || _selectedCategory != null;
      _results = quoteService.searchAndFilter(query, _selectedCategory);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Search Quotes'),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search quotes...',
                prefixIcon:
                    const Icon(Icons.search, color: AppColors.dustGrey),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: AppColors.dustGrey),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _selectedCategory = null;
                            _hasSearched = false;
                            _results = [];
                          });
                        },
                      )
                    : null,
              ),
            ),
          ),

          // Category chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: AppConfig.quoteCategories.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(
                        cat[0].toUpperCase() + cat.substring(1),
                        style: TextStyle(
                          color: isSelected
                              ? AppColors.floralWhite
                              : Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.color,
                          fontSize: 13,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: AppColors.spicyPaprika,
                      backgroundColor: Colors.transparent,
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.spicyPaprika
                            : AppColors.dustGrey.withValues(alpha: 0.5),
                      ),
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = selected ? cat : null;
                        });
                        _performSearch();
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Results
          Expanded(
            child: !_hasSearched
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search,
                            size: 64,
                            color:
                                AppColors.dustGrey.withValues(alpha: 0.5)),
                        const SizedBox(height: 16),
                        Text(
                          'Search or filter quotes',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(color: AppColors.dustGrey),
                        ),
                      ],
                    ),
                  )
                : _results.isEmpty
                    ? Center(
                        child: Text(
                          'No quotes found',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(color: AppColors.dustGrey),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(24),
                        itemCount: _results.length,
                        separatorBuilder: (context2, index2) =>
                            const Divider(height: 32),
                        itemBuilder: (context, index) {
                          final quote = _results[index];
                          return _buildQuoteItem(context, quote);
                        },
                      ),
          ),
        ],
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
          const SizedBox(height: 8),
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
            ],
          ),
        ],
      ),
    );
  }
}
