import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme/app_theme.dart';
import '../../services/scan_image_service.dart';
import 'crop_picker_sheet.dart';
import 'image_crop_screen.dart';
import 'leaf_camera_capture_screen.dart';
import 'scan_result_screen.dart';
import 'scan_tips_card.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final _picker = ImagePicker();
  final _service = ScanImageService();
  String _cropKey = 'auto';
  String _cropName = 'Tự động';
  bool _loading = false;
  String? _error;

  Future<void> _pick(ImageSource source) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final bytes = source == ImageSource.camera
          ? await _captureWithGuidance()
          : await _pickFromGallery();
      if (bytes == null) return;
      if (!mounted) return;
      final croppedBytes = await Navigator.of(context).push<Uint8List>(
        MaterialPageRoute(
          builder: (_) => ImageCropScreen(imageBytes: bytes),
        ),
      );
      if (croppedBytes == null) return;
      final diagnosis = await _service.scanAndSave(
        croppedBytes,
        cropHint: _cropKey == 'auto' ? null : _cropKey,
      );
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) =>
              ScanResultScreen(imageBytes: croppedBytes, diagnosis: diagnosis),
        ),
      );
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<Uint8List?> _captureWithGuidance() {
    return Navigator.of(context).push<Uint8List>(
      MaterialPageRoute(builder: (_) => const LeafCameraCaptureScreen()),
    );
  }

  Future<Uint8List?> _pickFromGallery() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 92,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    return file?.readAsBytes();
  }

  Future<void> _chooseCrop() async {
    final selected = await CropPickerSheet.show(context, _cropKey);
    if (selected != null) {
      setState(() {
        _cropKey = selected.cropKey;
        _cropName = selected.cropNameVi;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Quét bệnh cây')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                colors: [Color(0xFF1F6F43), Color(0xFF14B8A6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.forest.withValues(alpha: .18),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .18),
                    borderRadius: BorderRadius.circular(17),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: .28),
                    ),
                  ),
                  child: const Icon(
                    Icons.document_scanner_rounded,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Phân tích lá cây bằng AI',
                  style: textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Chụp hoặc chọn ảnh lá cây rõ nét để nhận diện bệnh, độ tin cậy và gợi ý chăm sóc.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: .9),
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: _loading ? null : () => _pick(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt_rounded),
                  label: const Text('Chụp ảnh'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.forest,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            margin: EdgeInsets.zero,
            color: const Color(0xFFEAF6E9),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: BorderSide(color: AppTheme.forest.withValues(alpha: .12)),
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
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.spa_rounded,
                          color: AppTheme.forest,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Thông tin cây trồng',
                        style: textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _loading ? null : _chooseCrop,
                    icon: const Icon(Icons.eco_rounded),
                    label: Text(_cropName),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'AI vẫn tự kiểm tra độ phù hợp của ảnh. Lựa chọn này giúp hệ thống ưu tiên đúng nhóm cây.',
                    style: textTheme.bodySmall?.copyWith(
                      color: AppTheme.ink.withValues(alpha: .64),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          const ScanTipsCard(),
          if (_error != null)
            Card(
              margin: const EdgeInsets.only(top: 10),
              color: const Color(0xFFFFEBEE),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: _loading ? null : () => _pick(ImageSource.gallery),
            icon: const Icon(Icons.photo_library_rounded),
            label: const Text('Chọn từ thư viện'),
          ),
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(18),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
