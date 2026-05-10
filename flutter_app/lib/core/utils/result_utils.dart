class ResultUtils {
  static String statusVi(String status) {
    switch (status) {
      case 'confident':
        return 'Đủ tin cậy';
      case 'healthy':
        return 'Khỏe mạnh';
      case 'uncertain':
        return 'Chưa chắc chắn';
      case 'unknown':
        return 'Không xác định';
      case 'crop_mismatch':
        return 'Không khớp cây trồng';
      case 'low_quality':
        return 'Ảnh chưa đạt';
      case 'error':
        return 'Lỗi';
      default:
        return status;
    }
  }
}
