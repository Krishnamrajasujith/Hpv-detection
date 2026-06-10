import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/api_service.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/risk_badge.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  @override
  State<HistoryScreen> createState() => _State();
}

class _State extends State<HistoryScreen> {
  List<dynamic> _items = [];
  bool _loading = true;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await ApiService().dio.get('/predictions/history');
      setState(() { _items = res.data; _loading = false; });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _delete(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0d1a2e),
        title: const Text('Delete Report?', style: TextStyle(color: Color(0xFFb0c4de))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Color(0xFFff4f6d)))),
        ],
      ),
    );
    if (confirmed == true) {
      await ApiService().dio.delete('/predictions/history/$id');
      setState(() => _items.removeWhere((i) => i['id'] == id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _items.where((i) {
      final q = _search.toLowerCase();
      return q.isEmpty || (i['patient_name'] as String?)?.toLowerCase().contains(q) == true;
    }).toList();

    return AppScaffold(
      title: 'History',
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: const InputDecoration(labelText: 'Search patient…', prefixIcon: Icon(Icons.search, color: Color(0xFF5a7a9a))),
              onChanged: (v) => setState(() => _search = v),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : filtered.isEmpty
                    ? const Center(child: Text('No predictions yet.', style: TextStyle(color: Color(0xFF5a7a9a))))
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (_, i) {
                          final item = filtered[i];
                          return Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0d1a2e),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFF1e3a5f)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(item['patient_name'] ?? '—', style: const TextStyle(color: Color(0xFFb0c4de), fontWeight: FontWeight.w600)),
                                    ResultBadge(label: item['result'] ?? '—'),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(children: [
                                  RiskBadge(label: item['risk'] ?? '—'),
                                  const SizedBox(width: 8),
                                  Text('${(item['confidence'] as num?)?.toStringAsFixed(1) ?? '—'}%', style: const TextStyle(color: Color(0xFF3d7fff), fontWeight: FontWeight.bold)),
                                ]),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton(
                                      onPressed: () => launchUrl(Uri.parse('${const String.fromEnvironment('API_URL', defaultValue: 'http://10.0.2.2:8000/api')}/predictions/download/${item['id']}')),
                                      child: const Text('PDF', style: TextStyle(color: Color(0xFF3d7fff), fontSize: 12)),
                                    ),
                                    TextButton(
                                      onPressed: () => _delete(item['id']),
                                      child: const Text('Delete', style: TextStyle(color: Color(0xFFff4f6d), fontSize: 12)),
                                    ),
                                  ],
                                ),
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
