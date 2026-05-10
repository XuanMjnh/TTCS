import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/app_formatters.dart';
import '../../core/utils/result_utils.dart';
import '../../data/models/history_entry.dart';
import '../../data/repositories/history_repository.dart';
import 'history_scan_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key, required this.uid});

  final String uid;

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _repo = HistoryRepository();
  String _status = 'all';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch sử quét'),
        actions: [
          IconButton(
            onPressed: () => _repo.deleteAll(widget.uid),
            icon: const Icon(Icons.delete_sweep_rounded),
            tooltip: 'Xóa toàn bộ',
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF2FF),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppTheme.sky.withValues(alpha: .14)),
            ),
            child: DropdownButtonFormField<String>(
              initialValue: _status,
              decoration: const InputDecoration(
                labelText: 'Lọc trạng thái',
                prefixIcon: Icon(Icons.filter_alt_rounded),
              ),
              items: const [
                DropdownMenuItem(value: 'all', child: Text('Tất cả')),
                DropdownMenuItem(value: 'confident', child: Text('Đủ tin cậy')),
                DropdownMenuItem(value: 'healthy', child: Text('Khỏe mạnh')),
                DropdownMenuItem(
                    value: 'uncertain', child: Text('Chưa chắc chắn')),
                DropdownMenuItem(
                    value: 'unknown', child: Text('Không xác định')),
                DropdownMenuItem(
                    value: 'low_quality', child: Text('Ảnh chưa đạt')),
              ],
              onChanged: (v) => setState(() => _status = v ?? 'all'),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<HistoryEntry>>(
              stream: _repo.watchHistory(widget.uid, status: _status),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final items = snapshot.data ?? const <HistoryEntry>[];
                if (items.isEmpty) {
                  return const _EmptyHistory();
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final color = _statusColor(item.diagnosisStatus);
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: color.withValues(alpha: .12)),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        leading: CircleAvatar(
                          backgroundColor: color.withValues(alpha: .12),
                          child: Icon(_statusIcon(item.diagnosisStatus),
                              color: color),
                        ),
                        title: Text(
                          item.displayTitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            '${ResultUtils.statusVi(item.diagnosisStatus)} • ${AppFormatters.percent(item.confidence)} • ${AppFormatters.dateTime(item.createdAt)}',
                            style: TextStyle(
                              color: AppTheme.ink.withValues(alpha: .66),
                            ),
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline_rounded),
                          color: color,
                          onPressed: () => _repo.deleteOne(widget.uid, item),
                        ),
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => HistoryScanDetailScreen(
                              uid: widget.uid,
                              entry: item,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    return switch (status) {
      'confident' => AppTheme.forest,
      'healthy' => AppTheme.leaf,
      'low_quality' => const Color(0xFFDC2626),
      'crop_mismatch' => const Color(0xFFC2410C),
      'unknown' => AppTheme.sky,
      _ => AppTheme.amber,
    };
  }

  IconData _statusIcon(String status) {
    return switch (status) {
      'confident' => Icons.verified_rounded,
      'healthy' => Icons.eco_rounded,
      'low_quality' => Icons.image_not_supported_rounded,
      'crop_mismatch' => Icons.compare_arrows_rounded,
      'unknown' => Icons.help_outline_rounded,
      _ => Icons.warning_amber_rounded,
    };
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

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
                color: const Color(0xFFEAF2FF),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.history_rounded,
                color: AppTheme.sky,
                size: 34,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Chưa có lịch sử quét',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              'Các kết quả phân tích sẽ xuất hiện tại đây để bạn theo dõi sức khỏe cây trồng.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.ink.withValues(alpha: .64)),
            ),
          ],
        ),
      ),
    );
  }
}
