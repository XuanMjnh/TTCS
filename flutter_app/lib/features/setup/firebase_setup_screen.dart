import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class FirebaseSetupScreen extends StatelessWidget {
  const FirebaseSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Cấu hình Firebase')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: AppTheme.field,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.cloud_off_rounded,
                          size: 34, color: AppTheme.forest),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Firebase chưa sẵn sàng',
                      style: textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Hoàn tất cấu hình Firebase để bật đăng nhập, lưu lịch sử và đồng bộ dữ liệu.',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(
                          color: AppTheme.ink.withOpacity(.68), height: 1.45),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Các bước cần làm',
                          style: TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 18)),
                      SizedBox(height: 12),
                      Text('• Chạy `flutterfire configure`.'),
                      SizedBox(height: 8),
                      Text(
                          '• Thay file `lib/firebase/firebase_options.dart` bằng cấu hình thật.'),
                      SizedBox(height: 8),
                      Text(
                          '• Deploy lại `firestore.rules` và `storage.rules`.'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
