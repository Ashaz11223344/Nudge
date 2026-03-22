import 'package:flutter/material.dart';
import 'package:nudge/core/constants/colors.dart';
import 'package:nudge/data/models/quote_model.dart';
import 'package:nudge/data/services/share_service.dart';

class ShareBottomSheet extends StatefulWidget {
  final QuoteModel quote;
  final String? userName;

  const ShareBottomSheet({
    super.key,
    required this.quote,
    this.userName,
  });

  @override
  State<ShareBottomSheet> createState() => _ShareBottomSheetState();
}

class _ShareBottomSheetState extends State<ShareBottomSheet> {
  final ShareService _shareService = ShareService();
  bool _isDarkCard = false;
  bool _isGenerating = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.dustGrey.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Share Quote',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.spicyPaprika,
                ),
          ),
          const SizedBox(height: 32),

          // Share as Text
          _shareOption(
            icon: Icons.text_fields_rounded,
            title: 'Share as Text',
            onTap: _isGenerating
                ? null
                : () async {
                    Navigator.pop(context);
                    await _shareService.shareAsText(widget.quote);
                  },
          ),
          const SizedBox(height: 16),

          // Share as Card
          _shareOption(
            icon: Icons.image_outlined,
            title: 'Share as Card',
            onTap: _isGenerating ? null : _handleShareAsCard,
            trailing: _isGenerating
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.spicyPaprika),
                    ),
                  )
                : _cardThemeToggle(),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _shareOption({
    required IconData icon,
    required String title,
    required VoidCallback? onTap,
    Widget? trailing,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.dustGrey.withValues(alpha: 0.2)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.spicyPaprika),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }

  Widget _cardThemeToggle() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _themeIndicator(false),
        const SizedBox(width: 8),
        _themeIndicator(true),
      ],
    );
  }

  Widget _themeIndicator(bool isDark) {
    final isSelected = _isDarkCard == isDark;
    return GestureDetector(
      onTap: () => setState(() => _isDarkCard = isDark),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.spicyPaprika : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? null : Border.all(color: AppColors.dustGrey),
        ),
        child: Text(
          isDark ? 'Dark' : 'Light',
          style: TextStyle(
            fontSize: 10,
            color: isSelected ? Colors.white : AppColors.dustGrey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Future<void> _handleShareAsCard() async {
    if (_isGenerating) return; // Guard against double-taps

    setState(() => _isGenerating = true);

    try {
      await _shareService.shareAsCard(
        quote: widget.quote,
        userName: widget.userName,
        isDark: _isDarkCard,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not generate card. Please try again.'),
            backgroundColor: AppColors.spicyPaprika,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
        Navigator.pop(context);
      }
    }
  }
}
