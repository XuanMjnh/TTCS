import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/error_mapper.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/user_repository.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, required this.repository});
  final AuthRepository repository;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  static const _vietnamProvinces = [
    'An Giang',
    'Bà Rịa - Vũng Tàu',
    'Bạc Liêu',
    'Bắc Giang',
    'Bắc Kạn',
    'Bắc Ninh',
    'Bến Tre',
    'Bình Định',
    'Bình Dương',
    'Bình Phước',
    'Bình Thuận',
    'Cà Mau',
    'Cao Bằng',
    'Cần Thơ',
    'Đà Nẵng',
    'Đắk Lắk',
    'Đắk Nông',
    'Điện Biên',
    'Đồng Nai',
    'Đồng Tháp',
    'Gia Lai',
    'Hà Giang',
    'Hà Nam',
    'Hà Nội',
    'Hà Tĩnh',
    'Hải Dương',
    'Hải Phòng',
    'Hậu Giang',
    'Hòa Bình',
    'Hưng Yên',
    'Khánh Hòa',
    'Kiên Giang',
    'Kon Tum',
    'Lai Châu',
    'Lâm Đồng',
    'Lạng Sơn',
    'Lào Cai',
    'Long An',
    'Nam Định',
    'Nghệ An',
    'Ninh Bình',
    'Ninh Thuận',
    'Phú Thọ',
    'Phú Yên',
    'Quảng Bình',
    'Quảng Nam',
    'Quảng Ngãi',
    'Quảng Ninh',
    'Quảng Trị',
    'Sóc Trăng',
    'Sơn La',
    'Tây Ninh',
    'Thái Bình',
    'Thái Nguyên',
    'Thanh Hóa',
    'Thừa Thiên Huế',
    'Tiền Giang',
    'TP. Hồ Chí Minh',
    'Trà Vinh',
    'Tuyên Quang',
    'Vĩnh Long',
    'Vĩnh Phúc',
    'Yên Bái',
  ];

  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  final _fullName = TextEditingController();
  final _birthDateText = TextEditingController();
  final _phoneNumber = TextEditingController();
  final _dateFormat = DateFormat('dd/MM/yyyy');

  bool _register = false;
  bool _loading = false;
  String? _error;
  DateTime? _birthDate;
  String? _province;

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      if (_register) {
        await widget.repository.register(
          email: _email.text,
          password: _password.text,
          profile: RegistrationProfile(
            fullName: _fullName.text,
            birthDate: _birthDate!,
            phoneNumber: _phoneNumber.text,
            province: _province!,
          ),
        );
      } else {
        await widget.repository.signIn(_email.text, _password.text);
      }
    } catch (e) {
      setState(() => _error = ErrorMapper.friendly(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: DateTime(now.year, now.month, now.day),
      helpText: 'Chọn ngày sinh',
      cancelText: 'Hủy',
      confirmText: 'Chọn',
    );
    if (picked == null) return;
    setState(() {
      _birthDate = picked;
      _birthDateText.text = _dateFormat.format(picked);
    });
  }

  void _toggleMode() {
    setState(() {
      _register = !_register;
      _error = null;
    });
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    _fullName.dispose();
    _birthDateText.dispose();
    _phoneNumber.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF7F1E7), Color(0xFFFDFDFB)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.forest,
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: .12),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: const Icon(
                              Icons.spa_rounded,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            'Plant AI',
                            style: textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Quét và chẩn đoán bệnh cho cây trồng của bạn bằng công nghệ AI',
                            style: textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withValues(alpha: .88),
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      margin: EdgeInsets.zero,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                _register ? 'Đăng ký tài khoản' : 'Đăng nhập',
                                style: textTheme.titleLarge
                                    ?.copyWith(fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _register
                                    ? 'Tao tài khoản mới để bắt đầu hành trình chăm sóc cây trồng thông minh.'
                                    : 'Đăng nhập để quản lý cây trồng và nhận chẩn đoán bệnh nhanh chóng.',
                                style: textTheme.bodyMedium?.copyWith(
                                  color: AppTheme.ink.withValues(alpha: .66),
                                ),
                              ),
                              const SizedBox(height: 18),
                              if (_register) ...[
                                TextFormField(
                                  controller: _fullName,
                                  textInputAction: TextInputAction.next,
                                  decoration: const InputDecoration(
                                    labelText: 'Họ và tên',
                                    prefixIcon: Icon(Icons.badge_outlined),
                                  ),
                                  validator: (value) {
                                    if (!_register) return null;
                                    if ((value ?? '').trim().length < 2) {
                                      return 'Vui lòng nhập họ và tên.';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: _birthDateText,
                                  readOnly: true,
                                  onTap: _pickBirthDate,
                                  decoration: const InputDecoration(
                                    labelText: 'Ngày sinh',
                                    prefixIcon: Icon(
                                      Icons.calendar_today_outlined,
                                    ),
                                  ),
                                  validator: (_) {
                                    if (!_register) return null;
                                    if (_birthDate == null) {
                                      return 'Vui lòng chọn ngày sinh.';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: _phoneNumber,
                                  keyboardType: TextInputType.phone,
                                  textInputAction: TextInputAction.next,
                                  decoration: const InputDecoration(
                                    labelText: 'Số điện thoại',
                                    prefixIcon: Icon(Icons.phone_outlined),
                                  ),
                                  validator: (value) {
                                    if (!_register) return null;
                                    final normalized = (value ?? '')
                                        .replaceAll(RegExp(r'[\s.-]'), '');
                                    final valid = RegExp(
                                      r'^(0|\+84)[0-9]{9,10}$',
                                    ).hasMatch(normalized);
                                    if (!valid) {
                                      return 'Vui lòng nhập số điện thoại hợp lệ.';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 12),
                                DropdownButtonFormField<String>(
                                  initialValue: _province,
                                  isExpanded: true,
                                  decoration: const InputDecoration(
                                    labelText: 'Tỉnh/Thành phố',
                                    prefixIcon:
                                        Icon(Icons.location_on_outlined),
                                  ),
                                  items: _vietnamProvinces
                                      .map(
                                        (province) => DropdownMenuItem<String>(
                                          value: province,
                                          child: Text(province),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: _loading
                                      ? null
                                      : (value) =>
                                          setState(() => _province = value),
                                  validator: (value) {
                                    if (!_register) return null;
                                    if (value == null || value.isEmpty) {
                                      return 'Vui lòng chọn tỉnh/thành phố.';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 12),
                              ],
                              TextFormField(
                                controller: _email,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                decoration: const InputDecoration(
                                  labelText: 'Email',
                                  prefixIcon: Icon(Icons.mail_outline_rounded),
                                ),
                                validator: (value) {
                                  final email = (value ?? '').trim();
                                  if (email.isEmpty) {
                                    return 'Vui lòng nhập email.';
                                  }
                                  if (!email.contains('@')) {
                                    return 'Email chưa đúng định dạng.';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _password,
                                obscureText: true,
                                textInputAction: _register
                                    ? TextInputAction.next
                                    : TextInputAction.done,
                                onFieldSubmitted: (_) {
                                  if (!_register) _submit();
                                },
                                decoration: const InputDecoration(
                                  labelText: 'Mật khẩu',
                                  prefixIcon: Icon(Icons.lock_outline_rounded),
                                ),
                                validator: (value) {
                                  final password = value ?? '';
                                  if (password.isEmpty) {
                                    return 'Vui lòng nhập mật khẩu.';
                                  }
                                  if (_register && password.length < 6) {
                                    return 'Mật khẩu cần ít nhất 6 ký tự.';
                                  }
                                  return null;
                                },
                              ),
                              if (_register) ...[
                                const SizedBox(height: 12),
                                TextFormField(
                                  controller: _confirmPassword,
                                  obscureText: true,
                                  textInputAction: TextInputAction.done,
                                  onFieldSubmitted: (_) => _submit(),
                                  decoration: const InputDecoration(
                                    labelText: 'Xác nhận mật khẩu',
                                    prefixIcon: Icon(Icons.lock_reset_rounded),
                                  ),
                                  validator: (value) {
                                    if (!_register) return null;
                                    if ((value ?? '').isEmpty) {
                                      return 'Vui lòng xác nhận mật khẩu.';
                                    }
                                    if (value != _password.text) {
                                      return 'Mật khẩu xác nhận không khớp.';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                              if (_error != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 12),
                                  child: Text(
                                    _error!,
                                    style: TextStyle(
                                      color:
                                          Theme.of(context).colorScheme.error,
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 16),
                              FilledButton(
                                onPressed: _loading ? null : _submit,
                                child: _loading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(
                                        _register ? 'Đăng ký' : 'Đăng nhập',
                                      ),
                              ),
                              TextButton(
                                onPressed: _loading ? null : _toggleMode,
                                child: Text(
                                  _register
                                      ? 'Đã có tài khoản? Đăng nhập'
                                      : 'Chưa có tài khoản? Đăng ký',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
