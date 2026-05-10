import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/crop_catalog_item.dart';
import '../../services/taxonomy_loader.dart';

class CropPickerSheet extends StatelessWidget {
  const CropPickerSheet({super.key, required this.selectedCropKey});
  final String selectedCropKey;

  static Future<CropCatalogItem?> show(
      BuildContext context, String selectedCropKey) {
    return showModalBottomSheet<CropCatalogItem>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => CropPickerSheet(selectedCropKey: selectedCropKey),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<CropCatalogItem>>(
      future: TaxonomyLoader().loadCropCatalog(),
      builder: (context, snapshot) {
        final items = snapshot.data ?? const <CropCatalogItem>[];
        if (items.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        return ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text(
                'Chọn loại cây',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
            ),
            Text(
              'Lựa chọn này giúp AI ưu tiên nhóm cây phù hợp hơn khi phân tích ảnh.',
              style: TextStyle(color: AppTheme.ink.withOpacity(.66)),
            ),
            const SizedBox(height: 12),
            for (final item in items)
              Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Icon(
                    item.cropKey == selectedCropKey
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_off_rounded,
                    color: item.cropKey == selectedCropKey
                        ? AppTheme.forest
                        : AppTheme.ink.withOpacity(.42),
                  ),
                  title: Text(item.cropNameVi),
                  onTap: () => Navigator.of(context).pop(item),
                ),
              ),
          ],
        );
      },
    );
  }
}
