import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/journal_entry.dart';
import '../../data/repositories/journal_repository.dart';

class JournalEditorScreen extends StatefulWidget {
  const JournalEditorScreen({super.key, required this.uid, this.entry});
  final String uid;
  final JournalEntry? entry;

  @override
  State<JournalEditorScreen> createState() => _JournalEditorScreenState();
}

class _JournalEditorScreenState extends State<JournalEditorScreen> {
  final _repo = JournalRepository();
  late final TextEditingController _title;
  late final TextEditingController _note;
  String _cropKey = 'auto';
  String _cropName = 'Tự động';
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.entry?.title ?? '');
    _note = TextEditingController(text: widget.entry?.note ?? '');
    _cropKey = widget.entry?.cropKey ?? 'auto';
    _cropName = widget.entry?.cropNameVi ?? 'Tự động';
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      if (widget.entry == null) {
        await _repo.create(
          widget.uid,
          title: _title.text,
          note: _note.text,
          cropKey: _cropKey,
          cropNameVi: _cropName,
        );
      } else {
        final entry = JournalEntry(
          id: widget.entry!.id,
          title: _title.text,
          note: _note.text,
          cropKey: _cropKey,
          cropNameVi: _cropName,
          createdAt: widget.entry!.createdAt,
          updatedAt: DateTime.now(),
        );
        await _repo.update(widget.uid, entry);
      }
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final creating = widget.entry == null;

    return Scaffold(
      appBar: AppBar(title: Text(creating ? 'Tạo nhật ký' : 'Sửa nhật ký')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppTheme.sand,
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Row(
              children: [
                Icon(Icons.event_note_rounded, color: AppTheme.amber),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                      'Lưu lại các quan sát thực tế để so sánh với kết quả quét AI theo thời gian.'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _title,
            decoration: const InputDecoration(
              labelText: 'Tiêu đề',
              prefixIcon: Icon(Icons.title_rounded),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _note,
            minLines: 5,
            maxLines: 10,
            decoration: const InputDecoration(
              labelText: 'Ghi chú chăm sóc',
              alignLabelWithHint: true,
              prefixIcon: Icon(Icons.notes_rounded),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_rounded),
            label: Text(_saving ? 'Đang lưu...' : 'Lưu nhật ký'),
          ),
        ],
      ),
    );
  }
}
