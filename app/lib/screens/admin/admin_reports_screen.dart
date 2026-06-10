import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/risk_badge.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});
  @override
  State<AdminReportsScreen> createState() => _State();
}

class _State extends State<AdminReportsScreen> {
  List<dynamic> _reports = [];
  bool _loading = true;
  String _search = '';

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final res = await ApiService().dio.get('/admin/reports');
    setState(() { _reports = res.data; _loading = false; });
  }

  Future<void> _delete(int id) async {
    await ApiService().dio.delete('/admin/reports/$id');
    setState(() => _reports.removeWhere((r) => r['id'] == id));
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _reports.where((r) {
      final q = _search.toLowerCase();
      return q.isEmpty || (r['patient_name'] as String?)?.toLowerCase().contains(q) == true || (r['username'] as String?)?.toLowerCase().contains(q) == true;
    }).toList();

    return AppScaffold(
      title: 'Reports',
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
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final r = filtered[i];
                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(color: const Color(0xFF0d1a2e), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF1e3a5f))),
                        child: Row(
                          children: [
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(r['patient_name'] ?? '—', style: const TextStyle(color: Color(0xFFb0c4de), fontWeight: FontWeight.w600)),
                              const SizedBox(height: 4),
                              Text('@${r['username']}', style: const TextStyle(color: Color(0xFF3d7fff), fontSize: 12)),
                              const SizedBox(height: 6),
                              Row(children: [ResultBadge(label: r['result'] ?? '—'), const SizedBox(width: 8), RiskBadge(label: r['risk'] ?? '—')]),
                            ])),
                            IconButton(icon: const Icon(Icons.delete_outline, color: Color(0xFFff4f6d)), onPressed: () => _delete(r['id'])),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
