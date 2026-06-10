import 'package:flutter/material.dart';

class RiskBadge extends StatelessWidget {
  final String label;
  const RiskBadge({super.key, required this.label});

  Color _bg() {
    if (label.contains('High')) return const Color(0xFFff4f6d).withOpacity(0.2);
    if (label.contains('Moderate')) return const Color(0xFFffb340).withOpacity(0.2);
    return const Color(0xFF0ee7b0).withOpacity(0.2);
  }

  Color _fg() {
    if (label.contains('High')) return const Color(0xFFff4f6d);
    if (label.contains('Moderate')) return const Color(0xFFffb340);
    return const Color(0xFF0ee7b0);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: _bg(), borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(color: _fg(), fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}

class ResultBadge extends StatelessWidget {
  final String label;
  const ResultBadge({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    final positive = label.contains('Positive');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: (positive ? const Color(0xFFff4f6d) : const Color(0xFF0ee7b0)).withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: positive ? const Color(0xFFff4f6d) : const Color(0xFF0ee7b0),
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
