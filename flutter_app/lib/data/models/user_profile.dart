import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  const UserProfile({
    required this.uid,
    required this.email,
    required this.fullName,
    required this.birthDate,
    required this.phoneNumber,
    required this.province,
    required this.createdAt,
    required this.updatedAt,
  });

  final String uid;
  final String email;
  final String fullName;
  final DateTime? birthDate;
  final String phoneNumber;
  final String province;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'email': email,
        'fullName': fullName,
        'birthDate': birthDate == null ? null : Timestamp.fromDate(birthDate!),
        'phoneNumber': phoneNumber,
        'province': province,
        'updatedAt': FieldValue.serverTimestamp(),
      };

  factory UserProfile.fromMap(Map<String, dynamic> data) {
    DateTime? readDate(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      if (value is String) return DateTime.tryParse(value);
      return null;
    }

    return UserProfile(
      uid: data['uid']?.toString() ?? '',
      email: data['email']?.toString() ?? '',
      fullName: data['fullName']?.toString() ?? '',
      birthDate: readDate(data['birthDate']),
      phoneNumber: data['phoneNumber']?.toString() ?? '',
      province: data['province']?.toString() ?? '',
      createdAt:
          readDate(data['createdAt']) ?? DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt:
          readDate(data['updatedAt']) ?? DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}
