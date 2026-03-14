import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Rule-based coach tips. No external AI. Optional: read from content/tips.
final coachTipsServiceProvider = Provider<CoachTipsService>((ref) => CoachTipsService());

class CoachTipsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// [userConcern] optional: 'stress' | 'energy' | 'sleep'
  Future<String> getTip({required String mode, String? userConcern}) async {
    final fromFirestore = await _getTipFromFirestore(mode, userConcern);
    if (fromFirestore != null && fromFirestore.isNotEmpty) return fromFirestore;
    return _ruleBasedTip(mode: mode, userConcern: userConcern);
  }

  Future<String?> _getTipFromFirestore(String mode, String? concern) async {
    try {
      QuerySnapshot<Map<String, dynamic>> snap;
      if (concern != null && concern.isNotEmpty) {
        snap = await _firestore
            .collection('content')
            .doc('tips')
            .collection('items')
            .where('mode', isEqualTo: mode)
            .where('concern', isEqualTo: concern)
            .limit(1)
            .get();
      } else {
        snap = await _firestore
            .collection('content')
            .doc('tips')
            .collection('items')
            .where('mode', isEqualTo: mode)
            .limit(1)
            .get();
      }
      if (snap.docs.isNotEmpty) {
        return snap.docs.first.data()['text'] as String?;
      }
    } catch (_) {}
    return null;
  }

  String _ruleBasedTip({required String mode, String? userConcern}) {
    final c = userConcern?.toLowerCase() ?? '';
    switch (mode) {
      case 'calm':
        if (c == 'stress') return 'Pratiquez la cohérence cardiaque : 4s inspire, 4s expire. Idéal pour calmer le stress rapidement.';
        if (c == 'energy') return 'Une courte session Calm peut recentrer votre attention et augmenter la clarté.';
        if (c == 'sleep') return 'Le rythme 4-4 prépare le corps à des exercices plus lents pour le sommeil.';
        return 'Respiration égale : gardez le même temps à l\'inspiration et à l\'expiration pour un effet apaisant.';
      case 'focus':
        if (c == 'stress') return 'Allonger l\'expiration (4-6) active le système parasympathique et réduit la tension.';
        if (c == 'energy') return 'Le pattern 4-6 améliore l\'oxygénation et la concentration. Idéal avant une tâche importante.';
        if (c == 'sleep') return 'Pour le sommeil, privilégiez la session Sleep avec expiration plus longue.';
        return 'Expiration plus longue que l\'inspiration favorise la concentration et la récupération.';
      case 'sleep':
        if (c == 'stress') return 'L\'expiration longue (4-8) est très efficace pour diminuer le stress et la rumination.';
        if (c == 'energy') return 'En fin de journée, la session Sleep aide à la transition vers le repos.';
        if (c == 'sleep') return 'Pratiquez 10–15 min avant le coucher dans une pièce calme et sombre.';
        return 'Le ratio 4-8 (inspire/expire) favorise l\'endormissement et la récupération.';
      default:
        return 'Respirez lentement et régulièrement. Chaque cycle compte.';
    }
  }
}
