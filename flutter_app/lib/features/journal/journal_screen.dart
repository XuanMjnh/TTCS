import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/app_formatters.dart';
import '../../data/models/journal_entry.dart';
import '../../data/repositories/journal_repository.dart';
import 'journal_editor_screen.dart';

class JournalScreen extends StatelessWidget {
  JournalScreen({super.key, required this.uid});

  final String uid;
  final JournalRepository _repo = JournalRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nhật ký chăm sóc')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => JournalEditorScreen(uid: uid)),
        ),
        child: const Icon(Icons.add_rounded),
      ),
      body: StreamBuilder<List<JournalEntry>>(
        stream: _repo.watchJournals(uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snapshot.data ?? const <JournalEntry>[];
          if (items.isEmpty) return const _EmptyJournal();

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final color = _cardColor(index);
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                elevation: 0,
                color: color.withValues(alpha: .06),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: color.withValues(alpha: .16)),
                ),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  leading: CircleAvatar(
                    backgroundColor: color.withValues(alpha: .14),
                    child: Icon(_cardIcon(index), color: color),
                  ),
                  title: Text(
                    item.title,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      '${item.cropNameVi} • ${AppFormatters.dateTime(item.updatedAt)}\n${item.note}',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppTheme.ink.withValues(alpha: .68),
                        height: 1.35,
                      ),
                    ),
                  ),
                  isThreeLine: true,
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline_rounded),
                    color: color,
                    onPressed: () => _repo.delete(uid, item.id),
                  ),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          JournalEditorScreen(uid: uid, entry: item),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _cardColor(int index) {
    const colors = [
      AppTheme.amber,
      AppTheme.leaf,
      AppTheme.sky,
      Color(0xFF7C3AED),
    ];
    return colors[index % colors.length];
  }

  IconData _cardIcon(int index) {
    const icons = [
      Icons.edit_note_rounded,
      Icons.water_drop_rounded,
      Icons.compost_rounded,
      Icons.event_note_rounded,
    ];
    return icons[index % icons.length];
  }
}

class _EmptyJournal extends StatelessWidget {
  const _EmptyJournal();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1E7),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.edit_note_rounded,
                color: AppTheme.amber,
                size: 36,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Chưa có nhật ký',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              'Ghi lại lịch tưới, bón phân và tình trạng cây để theo dõi chăm sóc lâu dài.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.ink.withValues(alpha: .64)),
            ),
          ],
        ),
      ),
    );
  }
}
