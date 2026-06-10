import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/api_service.dart';
import '../../widgets/app_button.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  const ResetPasswordScreen({super.key, required this.email});
  @override
  State<ResetPasswordScreen> createState() => _State();
}

class _State extends State<ResetPasswordScreen> {
  final _pass = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _reset() async {
    if (_pass.text.length < 6) { setState(() => _error = 'Minimum 6 characters'); return; }
    setState(() { _loading = true; _error = null; });
    try {
      await ApiService().dio.post('/auth/reset-password', data: {'email': widget.email, 'password': _pass.text});
      if (mounted) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password reset!'))); context.go('/login'); }
    } catch (_) {
      setState(() => _error = 'Reset failed');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, title: const Text('New Password')),
    body: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          TextField(controller: _pass, obscureText: true, decoration: const InputDecoration(labelText: 'New Password (min 6 chars)')),
          if (_error != null) ...[const SizedBox(height: 10), Text(_error!, style: const TextStyle(color: Color(0xFFff4f6d)))],
          const SizedBox(height: 20),
          AppButton(label: 'Reset Password', onPressed: _reset, loading: _loading),
        ],
      ),
    ),
  );
}
