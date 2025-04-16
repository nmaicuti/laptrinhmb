import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../db/NoteAccountAPIService.dart';
import '../model/NoteAccount.dart';
import 'NoteListScreen.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onThemeChanged;
  final bool isDarkMode;
  final Function(BuildContext) onLogout;

  const LoginScreen({
    super.key,
    required this.onThemeChanged,
    required this.isDarkMode,
    required this.onLogout,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final account = await NoteAccountAPIService.instance.login(
        _usernameController.text.trim(),
        _passwordController.text.trim(),
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (account != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('userId', account.userId);
        await prefs.setInt('accountId', account.id!);
        await prefs.setString('username', account.username);
        await prefs.setBool('isLoggedIn', true);

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => NoteListScreen(
              onThemeChanged: widget.onThemeChanged,
              isDarkMode: widget.isDarkMode,
              onLogout: widget.onLogout,
            ),
          ),
        );
      } else {
        _showErrorDialog(
          'Đăng nhập thất bại',
          'Tên đăng nhập hoặc mật khẩu không đúng, hoặc tài khoản không hoạt động.',
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);

      String errorMessage = 'Đã xảy ra lỗi. Vui lòng thử lại.';
      if (e.toString().contains('network')) {
        errorMessage = 'Lỗi kết nối mạng. Vui lòng kiểm tra và thử lại.';
      } else if (e.toString().contains('timeout')) {
        errorMessage = 'Hết thời gian chờ. Vui lòng thử lại sau.';
      }

      _showErrorDialog('Lỗi đăng nhập', errorMessage);
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.note_alt_outlined,
                      size: 72,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Chào mừng trở lại',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Vui lòng đăng nhập để tiếp tục',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                    _buildTextField(
                      controller: _usernameController,
                      label: 'Tên đăng nhập',
                      icon: Icons.person,
                      validator: (value) =>
                      value == null || value.trim().isEmpty
                          ? 'Vui lòng nhập tên đăng nhập'
                          : null,
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: _passwordController,
                      label: 'Mật khẩu',
                      icon: Icons.lock,
                      obscureText: _obscurePassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () =>
                            setState(() => _obscurePassword = !_obscurePassword),
                      ),
                      validator: (value) =>
                      value == null || value.trim().isEmpty
                          ? 'Vui lòng nhập mật khẩu'
                          : null,
                    ),
                    const SizedBox(height: 24),
                    _buildLoginButton(),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () {
                        _showErrorDialog('Quên mật khẩu', 'Tính năng đang được phát triển.');
                      },
                      child: const Text('Quên mật khẩu?'),
                    ),
                    const SizedBox(height: 8),
                    _buildThemeToggle(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: validator,
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.login),
        label: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _isLoading
              ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          )
              : const Text(
            'Đăng nhập',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        onPressed: _isLoading ? null : _login,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildThemeToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(widget.isDarkMode ? Icons.dark_mode : Icons.light_mode),
        Switch(
          value: widget.isDarkMode,
          onChanged: (_) => widget.onThemeChanged(),
        ),
      ],
    );
  }
}
