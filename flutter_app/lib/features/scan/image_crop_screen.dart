import 'dart:typed_data';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class ImageCropScreen extends StatefulWidget {
  const ImageCropScreen({super.key, required this.imageBytes});

  final Uint8List imageBytes;

  @override
  State<ImageCropScreen> createState() => _ImageCropScreenState();
}

class _ImageCropScreenState extends State<ImageCropScreen> {
  final _controller = CropController();
  bool _cropping = false;
  bool _undoEnabled = false;
  bool _redoEnabled = false;

  void _finishCrop() {
    setState(() => _cropping = true);
    _controller.crop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Căn vùng lá'),
        actions: [
          IconButton(
            onPressed: _cropping || !_undoEnabled ? null : _controller.undo,
            icon: const Icon(Icons.undo_rounded),
            tooltip: 'Hoàn tác',
          ),
          IconButton(
            onPressed: _cropping || !_redoEnabled ? null : _controller.redo,
            icon: const Icon(Icons.redo_rounded),
            tooltip: 'Làm lại',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              decoration: BoxDecoration(
                color: const Color(0xFF10251C),
                borderRadius: BorderRadius.circular(22),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  Crop(
                    image: widget.imageBytes,
                    controller: _controller,
                    aspectRatio: 1,
                    initialRectBuilder: InitialRectBuilder.withSizeAndRatio(
                      size: .82,
                      aspectRatio: 1,
                    ),
                    interactive: true,
                    fixCropRect: true,
                    baseColor: const Color(0xFF10251C),
                    maskColor: Colors.black.withValues(alpha: .48),
                    radius: 18,
                    cornerDotBuilder: (size, edgeAlignment) => const DotControl(
                      color: AppTheme.amber,
                      padding: 6,
                    ),
                    progressIndicator: const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                    onHistoryChanged: (history) {
                      setState(() {
                        _undoEnabled = history.undoCount > 0;
                        _redoEnabled = history.redoCount > 0;
                      });
                    },
                    onCropped: (result) {
                      switch (result) {
                        case CropSuccess(:final croppedImage):
                          Navigator.of(context).pop(croppedImage);
                        case CropFailure(:final cause):
                          setState(() => _cropping = false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Không crop được ảnh: $cause'),
                            ),
                          );
                      }
                    },
                  ),
                  Positioned(
                    left: 14,
                    right: 14,
                    bottom: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: .42),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Text(
                        'Kéo và phóng to ảnh để đặt lá hoặc vùng bệnh trong khung vuông.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _cropping
                        ? null
                        : () => Navigator.of(context).pop<Uint8List>(null),
                    icon: const Icon(Icons.close_rounded),
                    label: const Text('Hủy'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _cropping ? null : _finishCrop,
                    icon: _cropping
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.crop_rounded),
                    label: const Text('Dùng ảnh này'),
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
