import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_formatters.dart';
import '../../core/utils/result_utils.dart';
import '../../data/models/plant_article.dart';
import '../../data/models/scan_diagnosis.dart';
import '../../data/repositories/knowledge_repository.dart';

class ScanResultScreen extends StatefulWidget {
  const ScanResultScreen({
    super.key,
    required this.imageBytes,
    required this.diagnosis,
  });

  final Uint8List imageBytes;
  final ScanDiagnosis diagnosis;

  @override
  State<ScanResultScreen> createState() => _ScanResultScreenState();
}

class _ScanResultScreenState extends State<ScanResultScreen> {
  late final Future<PlantArticle?> _articleFuture;

  @override
  void initState() {
    super.initState();
    final articleLabel = widget.diagnosis.taxonomy.articleLabel.isNotEmpty
        ? widget.diagnosis.taxonomy.articleLabel
        : widget.diagnosis.predictedLabel;
    _articleFuture = KnowledgeRepository().articleByLabel(articleLabel);
  }

  bool get _shouldShowArticle {
    return widget.diagnosis.status == 'confident' ||
        widget.diagnosis.status == 'healthy';
  }

  @override
  Widget build(BuildContext context) {
    final diagnosis = widget.diagnosis;
    final isPositive =
        diagnosis.status == 'confident' || diagnosis.status == 'healthy';
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Kết quả quét')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Image.memory(
              widget.imageBytes,
              fit: BoxFit.cover,
              height: 280,
              width: double.infinity,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isPositive
                    ? const [AppTheme.forest, AppTheme.leaf]
                    : const [Color(0xFFC2410C), AppTheme.amber],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .18),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.circle, color: Colors.white, size: 12),
                      const SizedBox(width: 8),
                      Text(
                        ResultUtils.statusVi(diagnosis.status),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  diagnosis.displayTitle,
                  style: textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                _MetricRow(
                  label: 'Độ tin cậy',
                  value: AppFormatters.percent(diagnosis.confidence),
                  progress: diagnosis.confidence.clamp(0, 1).toDouble(),
                  color: Colors.white,
                  trackColor: Colors.white.withValues(alpha: .2),
                ),
                const SizedBox(height: 10),
                _MetricRow(
                  label: 'Độ tách biệt dự đoán',
                  value: AppFormatters.percent(diagnosis.margin),
                  progress: diagnosis.margin.clamp(0, 1).toDouble(),
                  color: Colors.white,
                  trackColor: Colors.white.withValues(alpha: .2),
                ),
                const SizedBox(height: 14),
                Text(
                  diagnosis.message,
                  style: textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: .92),
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Card(
            margin: EdgeInsets.zero,
            color: const Color(0xFFEAF2FF),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.leaderboard_rounded,
                        color: AppTheme.sky,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Top dự đoán',
                        style: textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  for (final p in diagnosis.topPredictions)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _MetricRow(
                        label: p.label,
                        value: AppFormatters.percent(p.confidence),
                        progress: p.confidence.clamp(0, 1).toDouble(),
                        color: AppTheme.sky,
                        trackColor: AppTheme.sky.withValues(alpha: .12),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (_shouldShowArticle) ...[
            const SizedBox(height: 10),
            FutureBuilder<PlantArticle?>(
              future: _articleFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const _ArticleLoadingCard();
                }

                final article = snapshot.data;
                if (article == null) {
                  return const SizedBox.shrink();
                }

                return _DiagnosisInfoCard(article: article);
              },
            ),
          ],
          const SizedBox(height: 10),
          const Card(
            margin: EdgeInsets.zero,
            color: Color(0xFFFFF1E7),
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

class _DiagnosisInfoCard extends StatelessWidget {
  const _DiagnosisInfoCard({required this.article});

  final PlantArticle article;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isHealthy = article.label.endsWith('__healthy');

    return Card(
      margin: EdgeInsets.zero,
      color: AppTheme.field,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isHealthy
                      ? Icons.eco_rounded
                      : Icons.medical_information_rounded,
                  color: AppTheme.forest,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    isHealthy ? 'Thông tin cây trồng' : 'Thông tin bệnh',
                    style: textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              article.title,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            _InfoSection(
              title: isHealthy ? 'Dấu hiệu ghi nhận' : 'Triệu chứng',
              icon: Icons.visibility_rounded,
              items: article.symptoms,
            ),
            _InfoSection(
              title: isHealthy ? 'Nhận định' : 'Nguyên nhân có thể',
              icon: Icons.science_rounded,
              items: article.possibleCauses,
            ),
            _InfoSection(
              title: isHealthy ? 'Khuyến nghị' : 'Xử lý gợi ý',
              icon: Icons.healing_rounded,
              items: article.treatment,
            ),
            _InfoSection(
              title: 'Chăm sóc',
              icon: Icons.water_drop_rounded,
              items: article.care,
            ),
            _InfoSection(
              title: 'Phòng bệnh',
              icon: Icons.shield_rounded,
              items: article.prevention,
            ),
            _InfoSection(
              title: 'Khi nào cần hỏi chuyên gia',
              icon: Icons.support_agent_rounded,
              items: article.whenToAskExpert,
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({
    required this.title,
    required this.icon,
    required this.items,
  });

  final String title;
  final IconData icon;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppTheme.forest),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_rounded,
                    size: 18,
                    color: AppTheme.leaf,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(height: 1.35),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ArticleLoadingCard extends StatelessWidget {
  const _ArticleLoadingCard();

  @override
  Widget build(BuildContext context) {
    return const Card(
      margin: EdgeInsets.zero,
      color: AppTheme.field,
      child: Padding(
        padding: EdgeInsets.all(18),
        child: Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Expanded(child: Text('Đang tải thông tin bệnh...')),
          ],
        ),
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({
    required this.label,
    required this.value,
    required this.progress,
    required this.color,
    required this.trackColor,
  });

  final String label;
  final String value;
  final double progress;
  final Color color;
  final Color trackColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: color, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              value,
              style: TextStyle(color: color, fontWeight: FontWeight.w800),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: trackColor,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
