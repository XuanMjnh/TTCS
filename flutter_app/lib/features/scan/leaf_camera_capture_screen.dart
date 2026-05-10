import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class LeafCameraCaptureScreen extends StatefulWidget {
  const LeafCameraCaptureScreen({super.key});

  @override
  State<LeafCameraCaptureScreen> createState() =>
      _LeafCameraCaptureScreenState();
}

class _LeafCameraCaptureScreenState extends State<LeafCameraCaptureScreen> {
  CameraController? _controller;
  Future<void>? _initializeFuture;
  String? _error;
  bool _capturing = false;

  @override
  void initState() {
    super.initState();
    _initializeFuture = _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() => _error = 'Không tìm thấy camera trên thiết bị.');
        return;
      }
      final camera = cameras.firstWhere(
        (item) => item.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() => _controller = controller);
    } catch (e) {
      if (mounted) {
        setState(() => _error = 'Không mở được camera: $e');
      }
    }
  }

  Future<void> _capture() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized || _capturing) {
      return;
    }
    setState(() => _capturing = true);
    try {
      final file = await controller.takePicture();
      final bytes = await file.readAsBytes();
      if (mounted) Navigator.of(context).pop<Uint8List>(bytes);
    } catch (e) {
      if (mounted) {
        setState(() {
          _capturing = false;
          _error = 'Không chụp được ảnh: $e';
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<void>(
        future: _initializeFuture,
        builder: (context, snapshot) {
          final controller = _controller;
          if (_error != null) {
            return _CameraMessage(
              message: _error!,
              onClose: () => Navigator.of(context).pop<Uint8List>(null),
            );
          }
          if (controller == null || !controller.value.isInitialized) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }
          return Stack(
            fit: StackFit.expand,
            children: [
              Center(child: CameraPreview(controller)),
              const _LeafGuideOverlay(),
              Positioned(
                top: MediaQuery.of(context).padding.top + 8,
                left: 8,
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop<Uint8List>(null),
                  icon: const Icon(Icons.close_rounded),
                  color: Colors.white,
                  tooltip: 'Đóng',
                ),
              ),
              Positioned(
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).padding.bottom + 24,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: .42),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text(
                        'Đặt lá hoặc vùng bệnh vào giữa khung vuông',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    GestureDetector(
                      onTap: _capture,
                      child: Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.leaf,
                            width: 5,
                          ),
                        ),
                        child: _capturing
                            ? const Padding(
                                padding: EdgeInsets.all(22),
                                child:
                                    CircularProgressIndicator(strokeWidth: 3),
                              )
                            : const Icon(
                                Icons.camera_alt_rounded,
                                color: AppTheme.forest,
                                size: 34,
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _LeafGuideOverlay extends StatelessWidget {
  const _LeafGuideOverlay();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _LeafGuidePainter(),
      child: const SizedBox.expand(),
    );
  }
}

class _LeafGuidePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final side =
        size.width < size.height ? size.width * .76 : size.height * .62;
    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: side,
      height: side,
    );
    final overlay = Path()..addRect(Offset.zero & size);
    final cutout = Path()
      ..addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(22)));
    canvas.drawPath(
      Path.combine(PathOperation.difference, overlay, cutout),
      Paint()..color = Colors.black.withValues(alpha: .42),
    );
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = Colors.white;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(22)),
      borderPaint,
    );
    final accentPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..color = AppTheme.leaf;
    const corner = 42.0;
    canvas
      ..drawLine(
          rect.topLeft, rect.topLeft + const Offset(corner, 0), accentPaint)
      ..drawLine(
          rect.topLeft, rect.topLeft + const Offset(0, corner), accentPaint)
      ..drawLine(
          rect.topRight, rect.topRight + const Offset(-corner, 0), accentPaint)
      ..drawLine(
          rect.topRight, rect.topRight + const Offset(0, corner), accentPaint)
      ..drawLine(rect.bottomLeft, rect.bottomLeft + const Offset(corner, 0),
          accentPaint)
      ..drawLine(rect.bottomLeft, rect.bottomLeft + const Offset(0, -corner),
          accentPaint)
      ..drawLine(rect.bottomRight, rect.bottomRight + const Offset(-corner, 0),
          accentPaint)
      ..drawLine(rect.bottomRight, rect.bottomRight + const Offset(0, -corner),
          accentPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CameraMessage extends StatelessWidget {
  const _CameraMessage({required this.message, required this.onClose});

  final String message;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.no_photography_rounded,
                color: Colors.white, size: 46),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: onClose,
              child: const Text('Quay lại'),
            ),
          ],
        ),
      ),
    );
  }
}
