import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../services/api_service.dart';
import '../../widgets/app_button.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});
  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _user = TextEditingController();
  final _email = TextEditingController();
  final _mobile = TextEditingController();
  final _pass = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _register() async {
    setState(() { _loading = true; _error = null; });
    try {
      final res = await ApiService().dio.post('/auth/register', data: {
        'username': _user.text.trim(),
        'email': _email.text.trim(),
        'mobile': _mobile.text.trim(),
        'password': _pass.text,
      });
      final devOtp = res.data['dev_otp'];
      if (mounted) {
        if (devOtp != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Dev OTP: $devOtp'), duration: const Duration(seconds: 15)),
          );
        }
        context.go('/verify-otp', extra: {'email': _email.text.trim(), 'purpose': 'register'});
      }
    } catch (e) {
      setState(() => _error = 'Registration failed. Username or email may already be taken.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF0d1a2e),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF1e3a5f)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Register', style: TextStyle(color: Color(0xFFb0c4de), fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                TextField(controller: _user, decoration: const InputDecoration(labelText: 'Username')),
                const SizedBox(height: 12),
                TextField(controller: _email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email')),
                const SizedBox(height: 12),
                TextField(controller: _mobile, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Mobile (optional)')),
                const SizedBox(height: 12),
                TextField(controller: _pass, obscureText: true, decoration: const InputDecoration(labelText: 'Password (min 6 chars)')),
                if (_error != null) ...[
                  const SizedBox(height: 10),
                  Text(_error!, style: const TextStyle(color: Color(0xFFff4f6d), fontSize: 13)),
                ],
                const SizedBox(height: 20),
                AppButton(label: 'Create Account', onPressed: _register, loading: _loading),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => context.go('/login'),
                  child: const Text('Already have an account? Sign in', style: TextStyle(color: Color(0xFF3d7fff), fontSize: 13)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
