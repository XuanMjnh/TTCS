class ImageQualityUtils {
  static String reasonVi(String reason) {
    switch (reason) {
      case 'too_blurry':
        return 'Ảnh quá mờ';
      case 'too_dark':
        return 'Ảnh quá tối';
      case 'too_bright':
        return 'Ảnh quá sáng';
      case 'too_small':
        return 'Vùng crop quá nhỏ';
      case 'decode_error':
        return 'Không đọc được ảnh';
      default:
        return reason;
    }
  }
}
