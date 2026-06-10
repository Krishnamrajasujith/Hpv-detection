import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'router.dart';

void main() {
  runApp(const ProviderScope(child: HPVDetectApp()));
}

class HPVDetectApp extends ConsumerWidget {
  const HPVDetectApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'HPV DetectAI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF070d1a),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3d7fff),
          brightness: Brightness.dark,
          background: const Color(0xFF070d1a),
          surface: const Color(0xFF0d1a2e),
          primary: const Color(0xFF3d7fff),
          secondary: const Color(0xFF00c6ff),
          error: const Color(0xFFff4f6d),
        ),
        textTheme: GoogleFonts.dmSansTextTheme(
          ThemeData.dark().textTheme,
        ).apply(bodyColor: const Color(0xFFb0c4de), displayColor: const Color(0xFFb0c4de)),
        cardTheme: CardTheme(
          color: const Color(0xFF0d1a2e),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFF1e3a5f)),
          ),
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF070d1a),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF1e3a5f)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF1e3a5f)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF3d7fff)),
          ),
          labelStyle: const TextStyle(color: Color(0xFF5a7a9a)),
          hintStyle: const TextStyle(color: Color(0xFF5a7a9a)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3d7fff),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(vertical: 14),
            textStyle: GoogleFonts.dmSans(fontWeight: FontWeight.w600, fontSize: 15),
          ),
        ),
      ),
      routerConfig: router,
    );
  }
}
