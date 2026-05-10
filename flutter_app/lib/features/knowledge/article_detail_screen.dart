import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/plant_article.dart';

class ArticleDetailScreen extends StatelessWidget {
  const ArticleDetailScreen({super.key, required this.article});

  final PlantArticle article;

  Widget _section(
    BuildContext context,
    String title,
    IconData icon,
    List<String> items,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppTheme.forest),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
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
                    const SizedBox(width: 10),
                    Expanded(child: Text(item)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(article.cropName)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.field,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  article.title,
                  style: textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 10),
                Text(
                  article.note,
                  style: textTheme.bodyMedium?.copyWith(height: 1.45),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _section(
            context,
            'Triệu chứng',
            Icons.visibility_rounded,
            article.symptoms,
          ),
          _section(
            context,
            'Nguyên nhân có thể',
            Icons.science_rounded,
            article.possibleCauses,
          ),
          _section(
            context,
            'Xử lý gợi ý',
            Icons.healing_rounded,
            article.treatment,
          ),
          _section(
            context,
            'Chăm sóc',
            Icons.water_drop_rounded,
            article.care,
          ),
          _section(
            context,
            'Phòng bệnh',
            Icons.shield_rounded,
            article.prevention,
          ),
          _section(
            context,
            'Khi nào cần hỏi chuyên gia',
            Icons.support_agent_rounded,
            article.whenToAskExpert,
          ),
        ],
      ),
    );
  }
}
