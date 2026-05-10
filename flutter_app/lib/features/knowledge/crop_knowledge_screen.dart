import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/plant_article.dart';
import 'article_detail_screen.dart';

class CropKnowledgeScreen extends StatelessWidget {
  const CropKnowledgeScreen({
    super.key,
    required this.cropName,
    required this.articles,
    this.leadingIcon = Icons.bug_report_rounded,
    this.accentColor = const Color(0xFFC2410C),
  });

  final String cropName;
  final List<PlantArticle> articles;
  final IconData leadingIcon;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(cropName)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          for (var i = 0; i < articles.length; i++)
            Card(
              margin: const EdgeInsets.only(bottom: 10),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: accentColor.withValues(alpha: .12)),
              ),
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: .1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    leadingIcon,
                    color: accentColor,
                  ),
                ),
                title: Text(
                  articles[i].title,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    articles[i].diseaseName,
                    style: TextStyle(
                      color: AppTheme.ink.withValues(alpha: .66),
                    ),
                  ),
                ),
                trailing: Icon(
                  Icons.chevron_right_rounded,
                  color: accentColor,
                ),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ArticleDetailScreen(article: articles[i]),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
