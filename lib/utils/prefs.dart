import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _keyOnboarding = 'breathequest_onboarding_seen';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnsupportedError('Override sharedPreferencesProvider in main');
});

final hasSeenOnboardingProvider = FutureProvider<bool>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(_keyOnboarding) ?? false;
});

Future<void> setOnboardingSeen() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(_keyOnboarding, true);
}
