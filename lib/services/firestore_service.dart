import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_profile.dart';
import '../models/session_record.dart';
import '../core/constants.dart';

final firestoreServiceProvider = Provider<FirestoreService>((ref) => FirestoreService());

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;
  CollectionReference<Map<String, dynamic>> get _users => _firestore.collection('users');

  Future<UserProfile?> getUserProfile() async {
    final uid = _uid;
    if (uid == null) return null;
    final doc = await _users.doc(uid).get();
    if (doc.exists) return UserProfile.fromFirestore(doc);
    return null;
  }

  Stream<UserProfile?> watchUserProfile() {
    final uid = _uid;
    if (uid == null) return Stream.value(null);
    return _users.doc(uid).snapshots().map((doc) {
      if (doc.exists) return UserProfile.fromFirestore(doc);
      return null;
    });
  }

  Future<void> createOrUpdateUserProfile({
    required String displayName,
    required String email,
  }) async {
    final uid = _uid;
    if (uid == null) return;
    final ref = _users.doc(uid);
    final existing = await ref.get();
    if (existing.exists) {
      await ref.update({'displayName': displayName, 'email': email});
    } else {
      await ref.set({
        'displayName': displayName,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'streak': 0,
        'totalMinutes': 0,
        'badges': <String>[],
        'focusSessionsCount': 0,
      });
    }
  }

  Future<void> saveSession({
    required String mode,
    required int durationSec,
    required String breathPattern,
    required int score,
    required int cycles,
  }) async {
    final uid = _uid;
    if (uid == null) return;
    final sessionsRef = _users.doc(uid).collection('sessions');
    await sessionsRef.add({
      'mode': mode,
      'durationSec': durationSec,
      'breathPattern': breathPattern,
      'score': score,
      'cycles': cycles,
      'createdAt': FieldValue.serverTimestamp(),
    });

    final profile = await getUserProfile();
    final now = DateTime.now();
    final lastAt = profile?.lastSessionAt;
    int newStreak = 1;
    if (lastAt != null) {
      final diffDays = now.difference(lastAt).inDays;
      if (diffDays == 0) {
        newStreak = profile!.streak;
      } else if (diffDays == 1) {
        newStreak = profile!.streak + 1;
      }
    }

    final newTotalMinutes = (profile?.totalMinutes ?? 0) + (durationSec ~/ 60);
    final newFocusCount = profile?.focusSessionsCount ?? 0;
    final focusIncrement = mode == 'focus' ? 1 : 0;
    final badges = List<String>.from(profile?.badges ?? []);
    if (!badges.contains('FIRST_SESSION')) badges.add('FIRST_SESSION');
    if (newStreak >= 3 && !badges.contains('STREAK_3')) badges.add('STREAK_3');
    final focusTotal = newFocusCount + focusIncrement;
    if (focusTotal >= 5 && !badges.contains('FOCUS_5')) badges.add('FOCUS_5');

    await _users.doc(uid).update({
      'lastSessionAt': FieldValue.serverTimestamp(),
      'streak': newStreak,
      'totalMinutes': newTotalMinutes,
      'focusSessionsCount': focusTotal,
      'badges': badges,
    });
  }

  Future<List<SessionRecord>> getSessionHistory({int limit = 20}) async {
    final uid = _uid;
    if (uid == null) return [];
    final snap = await _users
        .doc(uid)
        .collection('sessions')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();
    return snap.docs.map((d) => SessionRecord.fromFirestore(d)).toList();
  }

  Stream<List<SessionRecord>> watchSessionHistory({int limit = 20}) {
    final uid = _uid;
    if (uid == null) return Stream.value([]);
    return _users
        .doc(uid)
        .collection('sessions')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) => snap.docs.map((d) => SessionRecord.fromFirestore(d)).toList());
  }
}
