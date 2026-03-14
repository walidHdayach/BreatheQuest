import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String? displayName;
  final String? email;
  final DateTime? createdAt;
  final int streak;
  final DateTime? lastSessionAt;
  final int totalMinutes;
  final List<String> badges;
  final int focusSessionsCount;

  const UserProfile({
    required this.uid,
    this.displayName,
    this.email,
    this.createdAt,
    this.streak = 0,
    this.lastSessionAt,
    this.totalMinutes = 0,
    this.badges = const [],
    this.focusSessionsCount = 0,
  });

  factory UserProfile.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return UserProfile(
      uid: doc.id,
      displayName: d['displayName'] as String?,
      email: d['email'] as String?,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
      streak: d['streak'] as int? ?? 0,
      lastSessionAt: (d['lastSessionAt'] as Timestamp?)?.toDate(),
      totalMinutes: d['totalMinutes'] as int? ?? 0,
      badges: List<String>.from(d['badges'] as List? ?? []),
      focusSessionsCount: d['focusSessionsCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (displayName != null) 'displayName': displayName,
      if (email != null) 'email': email,
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
      'streak': streak,
      if (lastSessionAt != null) 'lastSessionAt': Timestamp.fromDate(lastSessionAt!),
      'totalMinutes': totalMinutes,
      'badges': badges,
      'focusSessionsCount': focusSessionsCount,
    };
  }

  UserProfile copyWith({
    String? displayName,
    String? email,
    DateTime? createdAt,
    int? streak,
    DateTime? lastSessionAt,
    int? totalMinutes,
    List<String>? badges,
    int? focusSessionsCount,
  }) {
    return UserProfile(
      uid: uid,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      streak: streak ?? this.streak,
      lastSessionAt: lastSessionAt ?? this.lastSessionAt,
      totalMinutes: totalMinutes ?? this.totalMinutes,
      badges: badges ?? this.badges,
      focusSessionsCount: focusSessionsCount ?? this.focusSessionsCount,
    );
  }
}
