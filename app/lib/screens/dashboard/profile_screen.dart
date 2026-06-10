import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/app_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _State();
}

class _State extends State<ProfileScreen> {
  Map<String, dynamic>? _profile;
  bool _editing = false;
  bool _saving = false;
  final _email = TextEditingController();
  final _mobile = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final res = await ApiService().dio.get('/users/me');
    setState(() {
      _profile = res.data;
      _email.text = res.data['email'] ?? '';
      _mobile.text = res.data['mobile'] ?? '';
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final res = await ApiService().dio.patch('/users/me', data: {'email': _email.text, 'mobile': _mobile.text});
      setState(() { _profile = res.data; _editing = false; });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated')));
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Update failed')));
    } finally {
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_profile == null) return const AppScaffold(title: 'Profile', body: Center(child: CircularProgressIndicator()));

    return AppScaffold(
      title: 'Profile',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: const Color(0xFF0d1a2e), borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFF1e3a5f))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: const Color(0xFF3d7fff).withOpacity(0.2),
                  child: Text((_profile!['username'] as String)[0].toUpperCase(), style: const TextStyle(color: Color(0xFF3d7fff), fontSize: 22, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 14),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(_profile!['username'], style: const TextStyle(color: Color(0xFFb0c4de), fontWeight: FontWeight.w600, fontSize: 18)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: (_profile!['role'] == 'admin' ? const Color(0xFFffb340) : const Color(0xFF3d7fff)).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(_profile!['role'], style: TextStyle(color: _profile!['role'] == 'admin' ? const Color(0xFFffb340) : const Color(0xFF3d7fff), fontSize: 11, fontWeight: FontWeight.w600)),
                  ),
                ]),
              ]),
              const SizedBox(height: 20),
              if (_editing) ...[
                TextField(controller: _email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email')),
                const SizedBox(height: 12),
                TextField(controller: _mobile, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Mobile')),
                const SizedBox(height: 16),
                AppButton(label: 'Save Changes', onPressed: _save, loading: _saving),
                const SizedBox(height: 8),
                AppButton(label: 'Cancel', onPressed: () => setState(() => _editing = false), variant: AppButtonVariant.ghost),
              ] else ...[
                ...[['Email', _profile!['email']], ['Mobile', _profile!['mobile']]].map((row) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text(row[0] ?? '', style: const TextStyle(color: Color(0xFF5a7a9a), fontSize: 14)),
                    Text(row[1]?.isNotEmpty == true ? row[1]! : '—', style: const TextStyle(color: Color(0xFFb0c4de), fontSize: 14)),
                  ]),
                )),
                const SizedBox(height: 16),
                AppButton(label: 'Edit Profile', onPressed: () => setState(() => _editing = true), variant: AppButtonVariant.ghost),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
