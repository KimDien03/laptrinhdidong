import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app_state.dart';
import '../explore/explore_shell.dart';

enum _AuthMode { login, register }

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  static const String routeName = '/auth';

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  _AuthMode _mode = _AuthMode.login;
  bool _isSubmitting = false;
  bool _registerAsAdmin = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String get _headerTitle =>
      _mode == _AuthMode.login ? 'WELCOME TO FOOD TRAVEL' : 'ĐĂNG KÝ TÀI KHOẢN';

  String get _primaryButtonLabel =>
      _mode == _AuthMode.login ? 'Đăng nhập' : 'Đăng ký';

  String get _secondaryButtonLabel =>
      _mode == _AuthMode.login ? 'Đăng ký' : 'Đăng nhập';

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final appState = context.read<AppState>();
    String? errorMessage;

    if (_mode == _AuthMode.login) {
      errorMessage = await appState.signInWithPhone(
        phoneNumber: _phoneController.text,
        password: _passwordController.text,
      );
    } else {
      errorMessage = await appState.registerAccount(
        phoneNumber: _phoneController.text,
        displayName: _nameController.text,
        password: _passwordController.text,
        isAdmin: _registerAsAdmin,
      );
    }

    if (!mounted) return;

    setState(() => _isSubmitting = false);

    if (errorMessage != null) {
      _showSnackBar(errorMessage, isError: true);
      return;
    }

    _showSnackBar(
      _mode == _AuthMode.login
          ? 'Đăng nhập thành công!'
          : 'Tạo tài khoản thành công!',
    );

    Navigator.of(context).pushNamedAndRemoveUntil(
      ExploreShell.routeName,
      (route) => false,
    );
  }

  void _toggleMode() {
    setState(() {
      _mode =
          _mode == _AuthMode.login ? _AuthMode.register : _AuthMode.login;
      _isSubmitting = false;
      _registerAsAdmin = false;
      _confirmPasswordController.clear();
    });
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.green.shade600,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final cardWidth = size.width > 460 ? 420.0 : size.width * 0.9;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              'https://images.pexels.com/photos/1558732/pexels-photo-1558732.jpeg',
              fit: BoxFit.cover,
              alignment: Alignment.center,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.green.shade800,
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xAA1B5E20),
                    Color(0xAA388E3C),
                    Color(0xAA66BB6A),
                  ],
                ),
              ),
            ),
          ),
          Column(
            children: [
              _TopBar(
                title: 'FOOD TRAVEL',
                onBack: () => Navigator.of(context).maybePop(),
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 350),
                      switchInCurve: Curves.easeOutBack,
                      switchOutCurve: Curves.easeInBack,
                      child: Container(
                        key: ValueKey(_mode),
                        width: cardWidth,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(26),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2E7D32)
                                  .withValues(alpha: 0.18),
                              blurRadius: 24,
                              offset: const Offset(0, 16),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 32,
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _LogoHeader(mode: _mode),
                                const SizedBox(height: 12),
                                Text(
                                  _headerTitle,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        color: const Color(0xFF2E7D32),
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.4,
                                      ),
                                ),
                                const SizedBox(height: 24),
                                _buildPhoneField(),
                                const SizedBox(height: 16),
                                if (_mode == _AuthMode.register) ...[
                                  _buildNameField(),
                                  const SizedBox(height: 16),
                                ],
                                _buildPasswordField(),
                                if (_mode == _AuthMode.register) ...[
                                  const SizedBox(height: 16),
                                  _buildConfirmPasswordField(),
                                  const SizedBox(height: 12),
                                  _AdminRegisterToggle(
                                    value: _registerAsAdmin,
                                    onChanged: (value) => setState(
                                      () => _registerAsAdmin = value,
                                    ),
                                  ),
                                ] else ...[
                                  const SizedBox(height: 12),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      'Quên mật khẩu?',
                                      style: TextStyle(
                                        color: Colors.grey.shade700,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 28),
                                _ActionButtons(
                                  isSubmitting: _isSubmitting,
                                  primaryLabel: _primaryButtonLabel,
                                  secondaryLabel: _secondaryButtonLabel,
                                  onPrimaryPressed: _handleSubmit,
                                  onSecondaryPressed: _toggleMode,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneField() {
    return _AuthTextField(
      controller: _phoneController,
      label: 'Số điện thoại',
      hintText: 'Nhập số điện thoại',
      icon: Icons.phone_iphone_rounded,
      keyboardType: TextInputType.phone,
      validator: (value) {
        final text = value?.trim() ?? '';
        if (text.isEmpty) {
          return 'Vui lòng nhập số điện thoại';
        }
        if (text.length < 8) {
          return 'Số điện thoại không hợp lệ';
        }
        return null;
      },
    );
  }

  Widget _buildNameField() {
    return _AuthTextField(
      controller: _nameController,
      label: 'Tên tài khoản',
      hintText: 'Nhập tên hiển thị',
      icon: Icons.person_outline_rounded,
      validator: (value) {
        final text = value?.trim() ?? '';
        if (text.isEmpty) {
          return 'Vui lòng nhập tên tài khoản';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return _AuthTextField(
      controller: _passwordController,
      label: 'Mật khẩu',
      hintText: 'Nhập mật khẩu',
      icon: Icons.lock_outline_rounded,
      obscureText: true,
      validator: (value) {
        final text = value ?? '';
        if (text.length < 6) {
          return 'Mật khẩu tối thiểu 6 ký tự';
        }
        return null;
      },
    );
  }

  Widget _buildConfirmPasswordField() {
    return _AuthTextField(
      controller: _confirmPasswordController,
      label: 'Xác nhận mật khẩu',
      hintText: 'Nhập lại mật khẩu',
      icon: Icons.lock_reset_rounded,
      obscureText: true,
      validator: (value) {
        if (value != _passwordController.text) {
          return 'Mật khẩu không khớp';
        }
        return null;
      },
    );
  }
}

class _AuthTextField extends StatelessWidget {
  const _AuthTextField({
    required this.controller,
    required this.label,
    required this.hintText,
    required this.icon,
    this.obscureText = false,
    this.validator,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String label;
  final String hintText;
  final IconData icon;
  final bool obscureText;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        labelText: label,
        hintText: hintText,
        prefixIcon: Icon(icon, color: const Color(0xFF2E7D32)),
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFF81C784)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFF2E7D32), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({
    required this.isSubmitting,
    required this.primaryLabel,
    required this.secondaryLabel,
    required this.onPrimaryPressed,
    required this.onSecondaryPressed,
  });

  final bool isSubmitting;
  final String primaryLabel;
  final String secondaryLabel;
  final VoidCallback onPrimaryPressed;
  final VoidCallback onSecondaryPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: isSubmitting ? null : onPrimaryPressed,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(primaryLabel),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: OutlinedButton(
            onPressed: isSubmitting ? null : onSecondaryPressed,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              foregroundColor: const Color(0xFF2E7D32),
              side: const BorderSide(color: Color(0xFF2E7D32)),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(secondaryLabel),
          ),
        ),
      ],
    );
  }
}

class _LogoHeader extends StatelessWidget {
  const _LogoHeader({required this.mode});

  final _AuthMode mode;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 70,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              colors: [
                Color(0xFF1B5E20),
                Color(0xFF43A047),
              ],
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(
                Icons.park_rounded,
                size: 36,
                color: Colors.white,
              ),
              SizedBox(width: 10),
              Text(
                'FOOD TRAVEL',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Text(
          mode == _AuthMode.login
              ? 'Sử dụng số điện thoại để tiếp tục'
              : 'Vui lòng điền thông tin để đăng ký',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.title,
    required this.onBack,
  });

  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF1B5E20),
            Color(0xFF388E3C),
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 72,
          child: Row(
            children: [
              IconButton(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              const CircleAvatar(
                radius: 26,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.travel_explore,
                  color: Color(0xFF2E7D32),
                  size: 30,
                ),
              ),
              const SizedBox(width: 14),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminRegisterToggle extends StatelessWidget {
  const _AdminRegisterToggle({
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          children: [
            Checkbox(
              value: value,
              activeColor: const Color(0xFF2E7D32),
              onChanged: (checked) => onChanged(checked ?? false),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                'Đăng ký tài khoản quản trị',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
