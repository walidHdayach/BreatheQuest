/// App-wide constants for BreatheQuest.
class AppConstants {
  AppConstants._();

  static const String appName = 'BreatheQuest';
  static const String tagline = 'Respire. Joue. Récupère.';

  /// Session modes with breath patterns (inhale seconds, exhale seconds) and duration.
  static const Map<String, SessionConfig> sessionConfigs = {
    'calm': SessionConfig(
      id: 'calm',
      name: 'Calm',
      description: '1 min • Équilibre',
      inhaleSec: 4,
      exhaleSec: 4,
      totalDurationSec: 60,
    ),
    'focus': SessionConfig(
      id: 'focus',
      name: 'Focus',
      description: '2 min • Concentration',
      inhaleSec: 4,
      exhaleSec: 6,
      totalDurationSec: 120,
    ),
    'sleep': SessionConfig(
      id: 'sleep',
      name: 'Sleep',
      description: '3 min • Détente',
      inhaleSec: 4,
      exhaleSec: 8,
      totalDurationSec: 180,
    ),
  };

  static const List<String> badgeIds = ['FIRST_SESSION', 'STREAK_3', 'FOCUS_5'];
}

class SessionConfig {
  final String id;
  final String name;
  final String description;
  final int inhaleSec;
  final int exhaleSec;
  final int totalDurationSec;

  const SessionConfig({
    required this.id,
    required this.name,
    required this.description,
    required this.inhaleSec,
    required this.exhaleSec,
    required this.totalDurationSec,
  });

  String get breathPattern => '$inhaleSec-$exhaleSec';
}
