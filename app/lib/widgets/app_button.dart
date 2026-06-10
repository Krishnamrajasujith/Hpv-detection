import 'package:flutter/material.dart';

enum AppButtonVariant { primary, teal, danger, ghost }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final AppButtonVariant variant;
  final bool fullWidth;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.loading = false,
    this.variant = AppButtonVariant.primary,
    this.fullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = {
      AppButtonVariant.primary: const Color(0xFF3d7fff),
      AppButtonVariant.teal: const Color(0xFF0ee7b0),
      AppButtonVariant.danger: const Color(0xFFff4f6d),
      AppButtonVariant.ghost: Colors.transparent,
    };

    final bg = colors[variant]!;
    final fg = variant == AppButtonVariant.teal ? const Color(0xFF070d1a) : Colors.white;

    final child = loading
        ? SizedBox(
            height: 18,
            width: 18,
            child: CircularProgressIndicator(strokeWidth: 2, color: fg),
          )
        : Text(label);

    final button = variant == AppButtonVariant.ghost
        ? OutlinedButton(
            onPressed: loading ? null : onPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFb0c4de),
              side: const BorderSide(color: Color(0xFF1e3a5f)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: child,
          )
        : ElevatedButton(
            onPressed: loading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: bg,
              foregroundColor: fg,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: child,
          );

    return fullWidth ? SizedBox(width: double.infinity, child: button) : button;
  }
}
