import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class ErrorMapper {
  static String friendly(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'invalid-email':
          return 'Email không hợp lệ.';
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          return 'Email hoặc mật khẩu chưa đúng.';
        case 'email-already-in-use':
          return 'Email này đã được đăng ký.';
        case 'weak-password':
          return 'Mật khẩu quá yếu.';
        default:
          return 'Lỗi đăng nhập: ${error.code}';
      }
    }
    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return 'Bạn không có quyền thao tác dữ liệu này.';
        case 'unavailable':
          return 'Firebase tạm thời không khả dụng. Vui lòng thử lại.';
        case 'object-not-found':
          return 'Ảnh không còn tồn tại trên Storage.';
        default:
          return 'Lỗi Firebase: ${error.code}';
      }
    }
    return error.toString();
  }
}
