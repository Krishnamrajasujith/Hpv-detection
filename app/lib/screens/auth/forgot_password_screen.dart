import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/api_service.dart';
import '../../widgets/app_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  State<ForgotPasswordScreen> createState() => _State();
}

class _State extends State<ForgotPasswordScreen> {
  final _email = TextEditingController();
  bool _loading = false;

  Future<void> _send() async {
    setState(() => _loading = true);
    try {
      final res = await ApiService().dio.post('/auth/forgot-password', data: {'email': _email.text.trim()});
      final devOtp = res.data['dev_otp'];
      if (mounted) {
        if (devOtp != null) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Dev OTP: $devOtp'), duration: const Duration(seconds: 15)));
        context.go('/verify-otp', extra: {'email': _email.text.trim(), 'purpose': 'reset'});
      }
    } catch (_) {
      if (mounted) context.go('/verify-otp', extra: {'email': _email.text.trim(), 'purpose': 'reset'});
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, title: const Text('Forgot Password')),
    body: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Enter your registered email to receive a reset OTP.', style: TextStyle(color: Color(0xFF5a7a9a))),
          const SizedBox(height: 20),
          TextField(controller: _email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email')),
          const SizedBox(height: 20),
          AppButton(label: 'Send OTP', onPressed: _send, loading: _loading),
        ],
      ),
    ),
  );
}
