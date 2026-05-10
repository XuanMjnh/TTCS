import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class ScanTipsCard extends StatelessWidget {
  const ScanTipsCard({super.key});

  @override
  Widget build(BuildContext context) {
    const tips = [
      'Chụp lá rõ, đủ sáng và không quá xa.',
      'Đặt vùng nghi bị bệnh ở giữa khung hình.',
      'Tránh nền quá rối hoặc lá bị che khuất.',
      'Nếu có nhiều lá, chọn lá có triệu chứng rõ nhất.',
    ];
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: EdgeInsets.zero,
      color: const Color(0xFFEAF2FF),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: AppTheme.sky.withValues(alpha: .14)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.sky.withValues(alpha: .14),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Icon(
                    Icons.tips_and_updates_rounded,
                    color: AppTheme.sky,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Mẹo chụp ảnh',
                  style: textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
              ],
            ),
            const SizedBox(height: 14),
            for (final tip in tips)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      size: 18,
                      color: AppTheme.leaf,
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Text(tip)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
