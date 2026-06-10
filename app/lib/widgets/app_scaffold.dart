import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';

class AppScaffold extends ConsumerWidget {
  final String title;
  final Widget body;
  final Widget? fab;

  const AppScaffold({super.key, required this.title, required this.body, this.fab});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider);
    final location = GoRouterState.of(context).matchedLocation;

    final navItems = [
      _NavItem('/dashboard', 'Dashboard', Icons.grid_view_rounded),
      _NavItem('/history', 'History', Icons.history_rounded),
      _NavItem('/profile', 'Profile', Icons.person_outline_rounded),
      if (user?.role == 'admin') _NavItem('/admin', 'Admin', Icons.admin_panel_settings_outlined),
    ];

    int selectedIndex = navItems.indexWhere((n) => location.startsWith(n.path));
    if (selectedIndex < 0) selectedIndex = 0;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0d1a2e),
        elevation: 0,
        title: Text(title, style: const TextStyle(color: Color(0xFFb0c4de), fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Color(0xFFff4f6d)),
            onPressed: () async {
              await ref.read(authStateProvider.notifier).logout();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: body,
      floatingActionButton: fab,
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xFF0d1a2e),
        indicatorColor: const Color(0xFF3d7fff).withOpacity(0.2),
        selectedIndex: selectedIndex,
        onDestinationSelected: (i) => context.go(navItems[i].path),
        destinations: navItems
            .map((n) => NavigationDestination(icon: Icon(n.icon), label: n.label))
            .toList(),
      ),
    );
  }
}

class _NavItem {
  final String path;
  final String label;
  final IconData icon;
  const _NavItem(this.path, this.label, this.icon);
}
