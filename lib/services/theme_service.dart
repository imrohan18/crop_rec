import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  static final ThemeService _instance = ThemeService._internal();
  factory ThemeService() => _instance;
  ThemeService._internal();

  final ValueNotifier<ThemeMode> themeMode = ValueNotifier(ThemeMode.system);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getString('themeMode');
    if (v == 'light') {
      themeMode.value = ThemeMode.light;
    } else if (v == 'dark') {
      themeMode.value = ThemeMode.dark;
    } else {
      themeMode.value = ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    themeMode.value = mode;
    final prefs = await SharedPreferences.getInstance();
    String v = 'system';
    if (mode == ThemeMode.light) v = 'light';
    if (mode == ThemeMode.dark) v = 'dark';
    await prefs.setString('themeMode', v);
  }
}
