import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class AuthUser {
  final String username;
  final String role;
  final String token;
  const AuthUser({required this.username, required this.role, required this.token});

  Map<String, dynamic> toJson() => {'username': username, 'role': role, 'token': token};
  factory AuthUser.fromJson(Map<String, dynamic> j) =>
      AuthUser(username: j['username'], role: j['role'], token: j['token']);
}

class AuthNotifier extends StateNotifier<AuthUser?> {
  AuthNotifier() : super(null) {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('auth_user');
    if (raw != null) {
      final user = AuthUser.fromJson(jsonDecode(raw));
      await ApiService().saveToken(user.token);
      state = user;
    }
  }

  Future<void> login(String username, String password) async {
    final res = await ApiService().dio.post('/auth/login', data: {
      'username': username,
      'password': password,
    });
    final user = AuthUser(
      username: res.data['username'],
      role: res.data['role'],
      token: res.data['access_token'],
    );
    await ApiService().saveToken(user.token);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_user', jsonEncode(user.toJson()));
    state = user;
  }

  Future<void> logout() async {
    await ApiService().clearToken();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_user');
    state = null;
  }
}

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthUser?>((ref) => AuthNotifier());
