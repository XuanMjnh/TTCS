import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_profile.dart';

class RegistrationProfile {
  const RegistrationProfile({
    required this.fullName,
    required this.birthDate,
    required this.phoneNumber,
    required this.province,
  });

  final String fullName;
  final DateTime birthDate;
  final String phoneNumber;
  final String province;

  Map<String, dynamic> toMap() => {
        'fullName': fullName.trim(),
        'birthDate': Timestamp.fromDate(birthDate),
        'phoneNumber': phoneNumber.trim(),
        'province': province,
      };
}

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> upsertProfile(
    User user, {
    RegistrationProfile? registrationProfile,
  }) async {
    final ref = _firestore.collection('users').doc(user.uid);
    final snap = await ref.get();
    final data = {
      'uid': user.uid,
      'email': user.email,
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (registrationProfile != null) {
      data.addAll(registrationProfile.toMap());
    }
    if (!snap.exists) data['createdAt'] = FieldValue.serverTimestamp();
    await ref.set(data, SetOptions(merge: true));
  }

  Future<UserProfile?> profile(String uid) async {
    final snap = await _firestore.collection('users').doc(uid).get();
    final data = snap.data();
    if (data == null) return null;
    return UserProfile.fromMap(data);
  }

  Future<Map<String, dynamic>> profileStats(String uid) async {
    final history = await _firestore
        .collection('users')
        .doc(uid)
        .collection('history')
        .get();
    final stats = <String, int>{
      'confident': 0,
      'uncertain': 0,
      'healthy': 0,
      'unknown': 0,
      'low_quality': 0,
      'crop_mismatch': 0,
      'error': 0
    };
    final cropCounts = <String, int>{};
    for (final doc in history.docs) {
      final data = doc.data();
      final status = data['diagnosisStatus']?.toString() ?? 'uncertain';
      stats[status] = (stats[status] ?? 0) + 1;
      final crop = data['cropNameVi']?.toString() ?? '';
      if (crop.isNotEmpty) cropCounts[crop] = (cropCounts[crop] ?? 0) + 1;
    }
    String topCrop = 'Chưa có';
    if (cropCounts.isNotEmpty) {
      final entries = cropCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      topCrop = entries.first.key;
    }
    return {'total': history.docs.length, 'stats': stats, 'topCrop': topCrop};
  }
}
