import 'dart:convert';
import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_formatters.dart';
import '../../core/utils/result_utils.dart';
import '../../data/models/history_entry.dart';
import '../../data/repositories/history_repository.dart';

class HistoryScanDetailScreen extends StatelessWidget {
  const HistoryScanDetailScreen(
      {super.key, required this.uid, required this.entry});
  final String uid;
  final HistoryEntry entry;

  @override
  Widget build(BuildContext context) {
    Widget placeholder() => Container(
      height: 260,
      width: double.infinity,
      color: AppTheme.field,
      alignment: Alignment.center,
      child: const Icon(Icons.image_not_supported_rounded,
          size: 40, color: AppTheme.forest),
    );
    Widget image = placeholder();
    if (entry.imageUrl != null && entry.imageUrl!.isNotEmpty) {
      image = Image.network(entry.imageUrl!,
          height: 260,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => placeholder());
    } else if (entry.imagePreviewBase64 != null &&
        entry.imagePreviewBase64!.isNotEmpty) {
      try {
        image = Image.memory(base64Decode(entry.imagePreviewBase64!),
            height: 260,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => placeholder());
      } catch (_) {}
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết lịch sử'),
        actions: [
          IconButton(
            onPressed: () async {
              await HistoryRepository().deleteOne(uid, entry);
              if (context.mounted) Navigator.pop(context);
            },
            icon: const Icon(Icons.delete_outline_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: image,
          ),
          const SizedBox(height: 16),
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(entry.displayTitle,
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 10),
                  Text(
                      'Trạng thái: ${ResultUtils.statusVi(entry.diagnosisStatus)}'),
                  Text(
                      'Độ tin cậy: ${AppFormatters.percent(entry.confidence)}'),
                  Text('Thời gian: ${AppFormatters.dateTime(entry.createdAt)}'),
                  if (entry.userNote != null && entry.userNote!.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text('Ghi chú: ${entry.userNote}'),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Card(
            margin: EdgeInsets.zero,
            color: AppTheme.sand,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline_rounded, color: AppTheme.amber),
                  SizedBox(width: 12),
                  Expanded(child: Text(AppConstants.disclaimer)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
