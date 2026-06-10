import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../widgets/app_scaffold.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});
  @override
  State<AdminUsersScreen> createState() => _State();
}

class _State extends State<AdminUsersScreen> {
  List<dynamic> _users = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final res = await ApiService().dio.get('/admin/users');
    setState(() { _users = res.data; _loading = false; });
  }

  Future<void> _upgrade(int id, String name) async {
    await ApiService().dio.post('/admin/users/$id/upgrade');
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$name is now admin')));
    _load();
  }

  Future<void> _delete(int id, String name) async {
    final ok = await showDialog<bool>(context: context, builder: (_) => AlertDialog(
      backgroundColor: const Color(0xFF0d1a2e),
      title: Text('Delete $name?', style: const TextStyle(color: Color(0xFFb0c4de))),
      content: const Text('This will delete the user and all their reports.', style: TextStyle(color: Color(0xFF5a7a9a))),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
        TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Color(0xFFff4f6d)))),
      ],
    ));
    if (ok == true) {
      await ApiService().dio.delete('/admin/users/$id');
      setState(() => _users.removeWhere((u) => u['id'] == id));
    }
  }

  @override
  Widget build(BuildContext context) => AppScaffold(
    title: 'Manage Users',
    body: _loading
        ? const Center(child: CircularProgressIndicator())
        : ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: _users.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final u = _users[i];
              return ListTile(
                tileColor: const Color(0xFF0d1a2e),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: const BorderSide(color: Color(0xFF1e3a5f))),
                leading: CircleAvatar(backgroundColor: const Color(0xFF3d7fff).withOpacity(0.2), child: Text((u['username'] as String)[0].toUpperCase(), style: const TextStyle(color: Color(0xFF3d7fff)))),
                title: Text(u['username'], style: const TextStyle(color: Color(0xFFb0c4de))),
                subtitle: Text(u['email'] ?? '—', style: const TextStyle(color: Color(0xFF5a7a9a), fontSize: 12)),
                trailing: PopupMenuButton(
                  color: const Color(0xFF0d1a2e),
                  itemBuilder: (_) => [
                    if (u['role'] != 'admin') PopupMenuItem(onTap: () => _upgrade(u['id'], u['username']), child: const Text('Upgrade to admin', style: TextStyle(color: Color(0xFFffb340)))),
                    PopupMenuItem(onTap: () => _delete(u['id'], u['username']), child: const Text('Delete', style: TextStyle(color: Color(0xFFff4f6d)))),
                  ],
                ),
              );
            },
          ),
  );
}
