import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';
import '../../widgets/app_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _user = TextEditingController();
  final _pass = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _login() async {
    setState(() { _loading = true; _error = null; });
    try {
      await ref.read(authStateProvider.notifier).login(_user.text.trim(), _pass.text);
      if (mounted) context.go('/dashboard');
    } catch (e) {
      setState(() => _error = 'Invalid username or password');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('HPV DetectAI', style: TextStyle(color: Color(0xFF3d7fff), fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text('Genomic Diagnostics Platform', style: TextStyle(color: Color(0xFF5a7a9a), fontSize: 13)),
                const SizedBox(height: 40),

                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0d1a2e),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF1e3a5f)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Sign In', style: TextStyle(color: Color(0xFFb0c4de), fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),
                      TextField(controller: _user, decoration: const InputDecoration(labelText: 'Username')),
                      const SizedBox(height: 12),
                      TextField(controller: _pass, obscureText: true, decoration: const InputDecoration(labelText: 'Password')),
                      if (_error != null) ...[
                        const SizedBox(height: 10),
                        Text(_error!, style: const TextStyle(color: Color(0xFFff4f6d), fontSize: 13)),
                      ],
                      const SizedBox(height: 20),
                      AppButton(label: 'Sign In', onPressed: _login, loading: _loading),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(onPressed: () => context.go('/forgot-password'), child: const Text('Forgot password?', style: TextStyle(color: Color(0xFF3d7fff), fontSize: 13))),
                          TextButton(onPressed: () => context.go('/register'), child: const Text('Register', style: TextStyle(color: Color(0xFF3d7fff), fontSize: 13))),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
