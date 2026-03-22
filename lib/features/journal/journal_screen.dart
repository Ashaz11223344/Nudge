import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nudge/core/constants/colors.dart';
import 'package:nudge/core/utils/date_utils.dart';
import 'package:nudge/data/models/journal_model.dart';
import 'package:nudge/data/repositories/journal_repository.dart';
import 'package:nudge/shared/widgets/app_bar.dart';
import 'package:nudge/shared/widgets/empty_state.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  List<JournalModel> _entries = [];

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  void _loadEntries() {
    setState(() {
      _entries = context.read<JournalRepository>().getAllEntries();
    });
  }

  void _openEditor({JournalModel? entry}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _JournalEditorScreen(
          entry: entry,
          onSaved: _loadEntries,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Journal'),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openEditor(),
        child: const Icon(Icons.add),
      ),
      body: _entries.isEmpty
          ? const CustomEmptyState(
              icon: Icons.book_outlined,
              title: 'No journal entries yet',
              subtitle: 'Tap + to write your first entry',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(24),
              itemCount: _entries.length,
              separatorBuilder: (context2, index2) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final entry = _entries[index];
                return GestureDetector(
                  onTap: () => _openEditor(entry: entry),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.dustGrey.withValues(alpha: 0.3),
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              AppDateUtils.getRelativeDate(entry.date),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: AppColors.spicyPaprika,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  size: 18),
                              color: AppColors.dustGrey,
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Delete Entry'),
                                    content: const Text(
                                        'Are you sure you want to delete this entry?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(ctx, false),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(ctx, true),
                                        child: const Text('Delete'),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirm == true && context.mounted) {
                                  await context
                                      .read<JournalRepository>()
                                      .deleteEntry(entry.id);
                                  _loadEntries();
                                }
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          entry.text,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(height: 1.5),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _JournalEditorScreen extends StatefulWidget {
  final JournalModel? entry;
  final VoidCallback onSaved;

  const _JournalEditorScreen({
    this.entry,
    required this.onSaved,
  });

  @override
  State<_JournalEditorScreen> createState() => _JournalEditorScreenState();
}

class _JournalEditorScreenState extends State<_JournalEditorScreen> {
  late TextEditingController _controller;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.entry != null;
    _controller = TextEditingController(text: widget.entry?.text ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write something')),
      );
      return;
    }

    final journalRepo = context.read<JournalRepository>();

    if (_isEditing && widget.entry != null) {
      widget.entry!.text = text;
      widget.entry!.lastEdited = DateTime.now();
      await journalRepo.updateEntry(widget.entry!);
    } else {
      final entry = JournalModel(
        text: text,
        date: DateTime.now(),
      );
      await journalRepo.addEntry(entry);
    }

    widget.onSaved();
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Entry' : 'New Entry'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('Save'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppDateUtils.formatDate(
                  widget.entry?.date ?? DateTime.now()),
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.dustGrey),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: _controller,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: const InputDecoration(
                  hintText: 'Write your thoughts...',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(height: 1.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
