import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _keyDarkMode = 'breathequest_dark_mode';

class ThemeNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyDarkMode) ?? false;
  }

  Future<void> setDark(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDarkMode, value);
    state = AsyncData(value);
  }
}

final themeNotifierProvider = AsyncNotifierProvider<ThemeNotifier, bool>(ThemeNotifier.new);

final themeModeProvider = Provider<ThemeMode>((ref) {
  final dark = ref.watch(themeNotifierProvider);
  return dark.when(
    data: (isDark) => isDark ? ThemeMode.dark : ThemeMode.light,
    loading: () => ThemeMode.light,
    error: (_, __) => ThemeMode.light,
  );
});
