import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/api_service.dart';
import '../../widgets/app_button.dart';

class VerifyOTPScreen extends StatefulWidget {
  final String email;
  final String purpose;
  const VerifyOTPScreen({super.key, required this.email, required this.purpose});
  @override
  State<VerifyOTPScreen> createState() => _State();
}

class _State extends State<VerifyOTPScreen> {
  final _controllers = List.generate(6, (_) => TextEditingController());
  final _focusNodes = List.generate(6, (_) => FocusNode());
  bool _loading = false;
  String? _error;

  Future<void> _verify() async {
    final otp = _controllers.map((c) => c.text).join();
    if (otp.length < 6) { setState(() => _error = 'Enter all 6 digits'); return; }
    setState(() { _loading = true; _error = null; });
    try {
      await ApiService().dio.post('/auth/verify-otp', data: {
        'email': widget.email, 'otp': otp, 'purpose': widget.purpose,
      });
      if (mounted) {
        if (widget.purpose == 'register') context.go('/login');
        else context.go('/reset-password', extra: {'email': widget.email});
      }
    } catch (e) {
      setState(() => _error = 'Invalid or expired OTP');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, title: const Text('Verify OTP')),
    body: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Enter the 6-digit code sent to ${widget.email}', style: const TextStyle(color: Color(0xFF5a7a9a))),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(6, (i) => SizedBox(
              width: 44,
              child: TextField(
                controller: _controllers[i],
                focusNode: _focusNodes[i],
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                maxLength: 1,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFb0c4de)),
                decoration: const InputDecoration(counterText: ''),
                onChanged: (v) {
                  if (v.isNotEmpty && i < 5) _focusNodes[i + 1].requestFocus();
                  if (v.isEmpty && i > 0) _focusNodes[i - 1].requestFocus();
                },
              ),
            )),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: Color(0xFFff4f6d), fontSize: 13)),
          ],
          const SizedBox(height: 24),
          AppButton(label: 'Verify', onPressed: _verify, loading: _loading),
        ],
      ),
    ),
  );
}
