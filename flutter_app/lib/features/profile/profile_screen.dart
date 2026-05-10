import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/user_profile.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/history_repository.dart';
import '../../data/repositories/user_repository.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key, required this.user});

  final User user;
  final _auth = AuthRepository();
  final _users = UserRepository();
  final _history = HistoryRepository();

  Future<_ProfileData> _loadProfileData() async {
    final results = await Future.wait([
      _users.profile(user.uid),
      _users.profileStats(user.uid),
    ]);
    return _ProfileData(
      profile: results[0] as UserProfile?,
      statsData: results[1] as Map<String, dynamic>,
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Hồ sơ')),
      body: FutureBuilder<_ProfileData>(
        future: _loadProfileData(),
        builder: (context, snapshot) {
          final data = snapshot.data;
          final profile = data?.profile;
          final statsData = data?.statsData;
          final stats =
              Map<String, int>.from((statsData?['stats'] as Map?) ?? {});
          final displayName = _displayName(profile);
          final subtitle = profile == null
              ? 'Theo dõi sức khỏe cây trồng và lịch sử phân tích AI'
              : '${profile.province} • ${profile.phoneNumber}';

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.forest, AppTheme.leaf],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.forest.withValues(alpha: .18),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 31,
                      backgroundColor: Colors.white.withValues(alpha: .18),
                      child: Text(
                        displayName.isNotEmpty
                            ? displayName[0].toUpperCase()
                            : 'A',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user.email ?? 'Không có email',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withValues(alpha: .84),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.bodySmall?.copyWith(
                              color: Colors.white.withValues(alpha: .74),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (profile != null) ...[
                const SizedBox(height: 10),
                Card(
                  margin: EdgeInsets.zero,
                  color: const Color(0xFFEAF6E9),
                  child: Column(
                    children: [
                      _ProfileTile(
                        icon: Icons.cake_outlined,
                        label: 'Ngày sinh',
                        value: _formatBirthDate(profile.birthDate),
                        color: AppTheme.amber,
                      ),
                      const Divider(height: 1),
                      _ProfileTile(
                        icon: Icons.phone_outlined,
                        label: 'Số điện thoại',
                        value: profile.phoneNumber,
                        color: AppTheme.sky,
                      ),
                      const Divider(height: 1),
                      _ProfileTile(
                        icon: Icons.location_on_outlined,
                        label: 'Tỉnh/Thành phố',
                        value: profile.province,
                        color: AppTheme.forest,
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 14),
              GridView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1.35,
                ),
                children: [
                  _StatCard(
                    label: 'Tổng lần quét',
                    value: '${statsData?['total'] ?? 0}',
                    icon: Icons.document_scanner_rounded,
                    color: AppTheme.sky,
                  ),
                  _StatCard(
                    label: 'Đủ tin cậy',
                    value: '${stats['confident'] ?? 0}',
                    icon: Icons.verified_rounded,
                    color: AppTheme.forest,
                  ),
                  _StatCard(
                    label: 'Khỏe mạnh',
                    value: '${stats['healthy'] ?? 0}',
                    icon: Icons.eco_rounded,
                    color: AppTheme.leaf,
                  ),
                  _StatCard(
                    label: 'Cần kiểm tra',
                    value:
                        '${(stats['uncertain'] ?? 0) + (stats['unknown'] ?? 0) + (stats['low_quality'] ?? 0)}',
                    icon: Icons.warning_amber_rounded,
                    color: AppTheme.amber,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Card(
                margin: EdgeInsets.zero,
                color: const Color(0xFFFFF1E7),
                child: ListTile(
                  leading: const Icon(Icons.spa_rounded, color: AppTheme.amber),
                  title: const Text(
                    'Cây quét nhiều nhất',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: Text('${statsData?['topCrop'] ?? 'Chưa có'}'),
                ),
              ),
              const SizedBox(height: 18),
              OutlinedButton.icon(
                onPressed: () => _history.deleteAll(user.uid),
                icon: const Icon(Icons.delete_sweep_rounded),
                label: const Text('Xóa toàn bộ lịch sử'),
              ),
              const SizedBox(height: 10),
              FilledButton.icon(
                onPressed: _auth.signOut,
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Đăng xuất'),
              ),
            ],
          );
        },
      ),
    );
  }

  String _displayName(UserProfile? profile) {
    final fullName = profile?.fullName.trim() ?? '';
    if (fullName.isNotEmpty) return fullName;
    return user.displayName?.trim().isNotEmpty == true
        ? user.displayName!.trim()
        : user.email ?? 'Người dùng';
  }

  String _formatBirthDate(DateTime? birthDate) {
    if (birthDate == null) return 'Chưa cập nhật';
    return DateFormat('dd/MM/yyyy').format(birthDate);
  }
}

class _ProfileData {
  const _ProfileData({required this.profile, required this.statsData});

  final UserProfile? profile;
  final Map<String, dynamic> statsData;
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: .12),
        child: Icon(icon, color: color),
      ),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
      subtitle: Text(value.isEmpty ? 'Chưa cập nhật' : value),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      color: color.withValues(alpha: .06),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: color.withValues(alpha: .14)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: .12),
              child: Icon(icon, color: color),
            ),
            Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w800, color: color),
            ),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppTheme.ink.withValues(alpha: .64),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
