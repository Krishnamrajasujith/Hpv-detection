import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../widgets/app_scaffold.dart';

const _actionColors = {
  'LOGIN': Color(0xFF3d7fff),
  'REGISTER': Color(0xFF0ee7b0),
  'PREDICT': Color(0xFF0ee7b0),
  'TRAIN': Color(0xFFffb340),
  'DELETE_REPORT': Color(0xFFff4f6d),
  'DELETE_USER': Color(0xFFff4f6d),
  'UPGRADE_USER': Color(0xFFffb340),
  'PASSWORD_RESET': Color(0xFFffb340),
  'PROFILE_UPDATE': Color(0xFF3d7fff),
};

class AdminAuditScreen extends StatefulWidget {
  const AdminAuditScreen({super.key});
  @override
  State<AdminAuditScreen> createState() => _State();
}

class _State extends State<AdminAuditScreen> {
  List<dynamic> _logs = [];
  bool _loading = true;
  String _search = '';

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final res = await ApiService().dio.get('/admin/audit');
    setState(() { _logs = res.data; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _logs.where((l) {
      final q = _search.toLowerCase();
      return q.isEmpty || (l['username'] as String?)?.toLowerCase().contains(q) == true || (l['detail'] as String?)?.toLowerCase().contains(q) == true;
    }).toList();

    return AppScaffold(
      title: 'Audit Log',
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(decoration: const InputDecoration(labelText: 'Search…', prefixIcon: Icon(Icons.search, color: Color(0xFF5a7a9a))), onChanged: (v) => setState(() => _search = v)),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 6),
                    itemBuilder: (_, i) {
                      final l = filtered[i];
                      final color = _actionColors[l['action']] ?? const Color(0xFF3d7fff);
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: const Color(0xFF0d1a2e), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFF1e3a5f))),
                        child: Row(children: [
                          Container(width: 3, height: 40, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
                          const SizedBox(width: 10),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Row(children: [
                              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)), child: Text(l['action'], style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700))),
                              const SizedBox(width: 8),
                              Text('@${l['username']}', style: const TextStyle(color: Color(0xFF3d7fff), fontSize: 12)),
                            ]),
                            const SizedBox(height: 4),
                            Text(l['detail'] ?? '', style: const TextStyle(color: Color(0xFF5a7a9a), fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                          ])),
                        ]),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
