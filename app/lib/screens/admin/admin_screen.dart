import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/api_service.dart';
import '../../widgets/app_scaffold.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});
  @override
  State<AdminScreen> createState() => _State();
}

class _State extends State<AdminScreen> {
  Map<String, dynamic>? _stats;

  @override
  void initState() {
    super.initState();
    ApiService().dio.get('/admin/stats').then((r) => setState(() => _stats = r.data));
  }

  @override
  Widget build(BuildContext context) {
    final cards = _stats == null ? <Map<String, dynamic>>[] : [
      {'label': 'Users', 'value': _stats!['total_users'], 'color': const Color(0xFF3d7fff)},
      {'label': 'Reports', 'value': _stats!['total_reports'], 'color': const Color(0xFF00c6ff)},
      {'label': 'Positive', 'value': _stats!['positive'], 'color': const Color(0xFFff4f6d)},
      {'label': 'Negative', 'value': _stats!['negative'], 'color': const Color(0xFF0ee7b0)},
    ];

    return AppScaffold(
      title: 'Admin',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.6,
              children: cards.map((c) => Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: const Color(0xFF0d1a2e), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF1e3a5f))),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text('${c['value']}', style: TextStyle(color: c['color'] as Color, fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(c['label'] as String, style: const TextStyle(color: Color(0xFF5a7a9a), fontSize: 13)),
                ]),
              )).toList(),
            ),
            const SizedBox(height: 20),
            ...[
              {'path': '/admin/users', 'label': 'Manage Users', 'icon': Icons.people_outline},
              {'path': '/admin/reports', 'label': 'Manage Reports', 'icon': Icons.description_outlined},
              {'path': '/admin/audit', 'label': 'Audit Log', 'icon': Icons.history_rounded},
            ].map((item) => ListTile(
              tileColor: const Color(0xFF0d1a2e),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: const BorderSide(color: Color(0xFF1e3a5f))),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              leading: Icon(item['icon'] as IconData, color: const Color(0xFF3d7fff)),
              title: Text(item['label'] as String, style: const TextStyle(color: Color(0xFFb0c4de))),
              trailing: const Icon(Icons.chevron_right, color: Color(0xFF5a7a9a)),
              onTap: () => context.go(item['path'] as String),
            )).expand((w) => [w, const SizedBox(height: 8)]),
          ],
        ),
      ),
    );
  }
}
