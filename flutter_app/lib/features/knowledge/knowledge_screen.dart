import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/crop_info_article.dart';
import '../../data/models/farming_tip_article.dart';
import '../../data/models/knowledge_section.dart';
import '../../data/models/plant_article.dart';
import '../../data/repositories/knowledge_repository.dart';
import 'crop_knowledge_screen.dart';

class KnowledgeScreen extends StatelessWidget {
  const KnowledgeScreen({super.key});

  Future<_KnowledgeData> _loadData() async {
    final repository = KnowledgeRepository();
    final results = await Future.wait([
      repository.cropInfoArticles(),
      repository.allArticles(),
      repository.farmingTips(),
    ]);
    return _KnowledgeData(
      crops: results[0] as List<CropInfoArticle>,
      articles: results[1] as List<PlantArticle>,
      tips: results[2] as List<FarmingTipArticle>,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Kiến thức cây trồng'),
          bottom: const TabBar(
            isScrollable: false,
            tabAlignment: TabAlignment.fill,
            labelPadding: EdgeInsets.zero,
            indicatorSize: TabBarIndicatorSize.tab,
            labelStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              height: 1.1,
            ),
            unselectedLabelStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              height: 1.1,
            ),
            tabs: [
              Tab(icon: Icon(Icons.eco_rounded), text: 'Cây trồng'),
              Tab(icon: Icon(Icons.bug_report_rounded), text: 'Cây bệnh'),
              Tab(icon: Icon(Icons.verified_rounded), text: 'Cây khỏe'),
              Tab(icon: Icon(Icons.tips_and_updates_rounded), text: 'Mẹo'),
            ],
          ),
        ),
        body: FutureBuilder<_KnowledgeData>(
          future: _loadData(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final data = snapshot.data!;
            return TabBarView(
              children: [
                _CropInfoTab(articles: data.crops),
                _ArticleGroupTab.disease(articles: data.diseaseArticles),
                _ArticleGroupTab.healthy(articles: data.healthyArticles),
                _FarmingTipsTab(articles: data.tips),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CropInfoTab extends StatelessWidget {
  const _CropInfoTab({required this.articles});

  final List<CropInfoArticle> articles;

  @override
  Widget build(BuildContext context) {
    const palette = _KnowledgePalette(
      primary: Color(0xFF2E7D32),
      secondary: Color(0xFF8BC34A),
      surface: Color(0xFFEAF6E9),
      accent: Color(0xFFFFB74D),
    );

    return _KnowledgeList(
      palette: palette,
      headerIcon: Icons.agriculture_rounded,
      title: 'Tìm hiểu thông tin về cây trồng',
      subtitle:
          'Điều kiện sinh trưởng, chăm sóc, rủi ro thường gặp và ghi chép theo VietGAP.',
      children: [
        for (var i = 0; i < articles.length; i++)
          _KnowledgeTile(
            palette: palette,
            icon: _cropIcon(articles[i].cropKey, i),
            imageAsset: _cropImageAsset(articles[i].cropKey),
            title: articles[i].cropName,
            subtitle: articles[i].summary,
            badge: '${articles[i].sections.length} mục',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => _KnowledgeDetailScreen(
                  title: articles[i].cropName,
                  summary: articles[i].summary,
                  sections: articles[i].sections,
                  sources: articles[i].sources,
                  palette: palette,
                  heroIcon: _cropIcon(articles[i].cropKey, i),
                ),
              ),
            ),
          ),
      ],
    );
  }

  IconData _cropIcon(String cropKey, int index) {
    const fallback = [
      Icons.eco_rounded,
      Icons.grass_rounded,
      Icons.local_florist_rounded,
      Icons.yard_rounded,
      Icons.spa_rounded,
    ];
    return switch (cropKey) {
      'tomato' => Icons.local_pizza_rounded,
      'potato' => Icons.egg_alt_rounded,
      'corn' || 'maize' => Icons.grass_rounded,
      'rice' => Icons.rice_bowl_rounded,
      'wheat' => Icons.grain_rounded,
      'groundnut' => Icons.scatter_plot_rounded,
      'sugarcane' => Icons.forest_rounded,
      'cassava' => Icons.energy_savings_leaf_rounded,
      'cashew' => Icons.spa_rounded,
      'papaya' => Icons.local_florist_rounded,
      'cotton' => Icons.cloud_rounded,
      'chili' => Icons.whatshot_rounded,
      'bell_pepper' => Icons.emoji_food_beverage_rounded,
      'citrus' => Icons.brightness_5_rounded,
      'grape' => Icons.scatter_plot_rounded,
      'apple' => Icons.apple_rounded,
      'strawberry' => Icons.favorite_rounded,
      'soyabean' || 'soybean' => Icons.bubble_chart_rounded,
      'squash' => Icons.energy_savings_leaf_rounded,
      _ => fallback[index % fallback.length],
    };
  }

  String _cropImageAsset(String cropKey) {
    return 'assets/images/crops/$cropKey.png';
  }
}

class _ArticleGroupTab extends StatelessWidget {
  const _ArticleGroupTab._({
    required this.articles,
    required this.palette,
    required this.headerIcon,
    required this.tileIcon,
    required this.title,
    required this.subtitle,
    required this.badge,
  });

  factory _ArticleGroupTab.disease({required List<PlantArticle> articles}) =>
      _ArticleGroupTab._(
        articles: articles,
        palette: const _KnowledgePalette(
          primary: Color(0xFFC2410C),
          secondary: Color(0xFFF97316),
          surface: Color(0xFFFFF1E7),
          accent: Color(0xFFDC2626),
        ),
        headerIcon: Icons.bug_report_rounded,
        tileIcon: Icons.bug_report_rounded,
        title: 'Tìm hiểu về cây bệnh',
        subtitle:
            'Triệu chứng, nguyên nhân có thể, xử lý gợi ý, chăm sóc và phòng bệnh theo từng cây.',
        badge: 'Cây bệnh',
      );

  factory _ArticleGroupTab.healthy({required List<PlantArticle> articles}) =>
      _ArticleGroupTab._(
        articles: articles,
        palette: const _KnowledgePalette(
          primary: Color(0xFF15803D),
          secondary: Color(0xFF22C55E),
          surface: Color(0xFFEAF6E9),
          accent: Color(0xFF16A34A),
        ),
        headerIcon: Icons.verified_rounded,
        tileIcon: Icons.verified_rounded,
        title: 'Tìm hiểu về cây khỏe mạnh',
        subtitle:
            'Dấu hiệu cây khỏe, chăm sóc duy trì và các điểm cần tiếp tục theo dõi ngoài thực tế.',
        badge: 'Cây khỏe',
      );

  final List<PlantArticle> articles;
  final _KnowledgePalette palette;
  final IconData headerIcon;
  final IconData tileIcon;
  final String title;
  final String subtitle;
  final String badge;

  @override
  Widget build(BuildContext context) {
    final grouped = <String, List<PlantArticle>>{};
    for (final article in articles) {
      grouped.putIfAbsent(article.cropName, () => []).add(article);
    }
    final entries = grouped.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return _KnowledgeList(
      palette: palette,
      headerIcon: headerIcon,
      title: title,
      subtitle: subtitle,
      children: [
        for (final entry in entries)
          _KnowledgeTile(
            palette: palette,
            icon: tileIcon,
            title: entry.key,
            subtitle: '${entry.value.length} bài kiến thức',
            badge: badge,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => CropKnowledgeScreen(
                  cropName: entry.key,
                  articles: entry.value,
                  leadingIcon: tileIcon,
                  accentColor: palette.primary,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _FarmingTipsTab extends StatelessWidget {
  const _FarmingTipsTab({required this.articles});

  final List<FarmingTipArticle> articles;

  @override
  Widget build(BuildContext context) {
    const palette = _KnowledgePalette(
      primary: Color(0xFF2563EB),
      secondary: Color(0xFF14B8A6),
      surface: Color(0xFFEAF2FF),
      accent: Color(0xFFF59E0B),
    );

    return _KnowledgeList(
      palette: palette,
      headerIcon: Icons.tips_and_updates_rounded,
      title: 'Mẹo canh tác',
      subtitle:
          'Thực hành nền tảng về VietGAP, IPM, đất nước dinh dưỡng, thuốc an toàn và sau thu hoạch.',
      children: [
        for (var i = 0; i < articles.length; i++)
          _KnowledgeTile(
            palette: palette,
            icon: _tipIcon(articles[i].id, i),
            title: articles[i].title,
            subtitle: articles[i].summary,
            badge: '${articles[i].sections.length} nhóm việc',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => _KnowledgeDetailScreen(
                  title: articles[i].title,
                  summary: articles[i].summary,
                  sections: articles[i].sections,
                  sources: articles[i].sources,
                  palette: palette,
                  heroIcon: _tipIcon(articles[i].id, i),
                ),
              ),
            ),
          ),
      ],
    );
  }

  IconData _tipIcon(String id, int index) {
    const fallback = [
      Icons.checklist_rounded,
      Icons.water_drop_rounded,
      Icons.compost_rounded,
      Icons.inventory_2_rounded,
    ];
    return switch (id) {
      'vietgap_records' => Icons.fact_check_rounded,
      'ipm' => Icons.shield_rounded,
      'soil_water' => Icons.water_drop_rounded,
      'safe_pesticide' => Icons.science_rounded,
      'crop_rotation_sanitation' => Icons.recycling_rounded,
      'harvest_postharvest' => Icons.inventory_2_rounded,
      _ => fallback[index % fallback.length],
    };
  }
}

class _KnowledgeList extends StatelessWidget {
  const _KnowledgeList({
    required this.palette,
    required this.headerIcon,
    required this.title,
    required this.subtitle,
    required this.children,
  });

  final _KnowledgePalette palette;
  final IconData headerIcon;
  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 96),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [palette.primary, palette.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: palette.primary.withValues(alpha: .18),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .18),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: .28),
                  ),
                ),
                child: Icon(headerIcon, color: Colors.white, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: .9),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        ...children,
      ],
    );
  }
}

class _KnowledgeTile extends StatelessWidget {
  const _KnowledgeTile({
    required this.palette,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.onTap,
    this.imageAsset,
  });

  final _KnowledgePalette palette;
  final IconData icon;
  final String? imageAsset;
  final String title;
  final String subtitle;
  final String badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: palette.primary.withValues(alpha: .1)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: palette.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                clipBehavior: Clip.antiAlias,
                child: imageAsset == null
                    ? Icon(icon, color: palette.primary, size: 27)
                    : Image.asset(
                        imageAsset!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            icon,
                            color: palette.primary,
                            size: 27,
                          );
                        },
                      ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _Badge(label: badge, color: palette.accent),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppTheme.ink.withValues(alpha: .66),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Icon(Icons.chevron_right_rounded, color: palette.primary),
            ],
          ),
        ),
      ),
    );
  }
}

class _KnowledgeDetailScreen extends StatelessWidget {
  const _KnowledgeDetailScreen({
    required this.title,
    required this.summary,
    required this.sections,
    required this.sources,
    required this.palette,
    required this.heroIcon,
  });

  final String title;
  final String summary;
  final List<KnowledgeSection> sections;
  final List<String> sources;
  final _KnowledgePalette palette;
  final IconData heroIcon;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [palette.primary, palette.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .18),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(heroIcon, color: Colors.white, size: 28),
                ),
                const SizedBox(height: 14),
                Text(
                  title,
                  style: textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  summary,
                  style: textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: .9),
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          for (var i = 0; i < sections.length; i++)
            _DetailSection(
              section: sections[i],
              palette: palette,
              icon: _sectionIcon(sections[i].title, i),
            ),
          if (sources.isNotEmpty)
            _DetailSection(
              section: KnowledgeSection(
                title: 'Nguồn tham khảo',
                items: sources,
              ),
              palette: palette,
              icon: Icons.source_rounded,
            ),
        ],
      ),
    );
  }

  IconData _sectionIcon(String title, int index) {
    if (title.contains('Điều kiện')) return Icons.thermostat_rounded;
    if (title.contains('Chăm sóc')) return Icons.volunteer_activism_rounded;
    if (title.contains('Rủi ro')) return Icons.warning_amber_rounded;
    if (title.contains('VietGAP') || title.contains('ghi')) {
      return Icons.fact_check_rounded;
    }
    if (title.contains('nước') || title.contains('Nước')) {
      return Icons.water_drop_rounded;
    }
    if (title.contains('thuốc') || title.contains('phun')) {
      return Icons.science_rounded;
    }
    const fallback = [
      Icons.task_alt_rounded,
      Icons.spa_rounded,
      Icons.shield_rounded,
      Icons.recycling_rounded,
    ];
    return fallback[index % fallback.length];
  }
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({
    required this.section,
    required this.palette,
    required this.icon,
  });

  final KnowledgeSection section;
  final _KnowledgePalette palette;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: palette.primary.withValues(alpha: .1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: palette.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: palette.primary, size: 22),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    section.title,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            for (final item in section.items)
              Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check_circle_rounded,
                        size: 18, color: palette.secondary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item,
                        style: const TextStyle(height: 1.35),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _KnowledgePalette {
  const _KnowledgePalette({
    required this.primary,
    required this.secondary,
    required this.surface,
    required this.accent,
  });

  final Color primary;
  final Color secondary;
  final Color surface;
  final Color accent;
}

class _KnowledgeData {
  const _KnowledgeData({
    required this.crops,
    required this.articles,
    required this.tips,
  });

  final List<CropInfoArticle> crops;
  final List<PlantArticle> articles;
  final List<FarmingTipArticle> tips;

  List<PlantArticle> get diseaseArticles => articles
      .where((article) => article.diseaseName.toLowerCase() != 'khỏe mạnh')
      .toList(growable: false);

  List<PlantArticle> get healthyArticles => articles
      .where((article) => article.diseaseName.toLowerCase() == 'khỏe mạnh')
      .toList(growable: false);
}
