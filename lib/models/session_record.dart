import 'package:cloud_firestore/cloud_firestore.dart';

class SessionRecord {
  final String id;
  final String mode;
  final int durationSec;
  final String breathPattern;
  final int score;
  final int cycles;
  final DateTime createdAt;

  const SessionRecord({
    required this.id,
    required this.mode,
    required this.durationSec,
    required this.breathPattern,
    required this.score,
    required this.cycles,
    required this.createdAt,
  });

  factory SessionRecord.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return SessionRecord(
      id: doc.id,
      mode: d['mode'] as String? ?? 'calm',
      durationSec: d['durationSec'] as int? ?? 0,
      breathPattern: d['breathPattern'] as String? ?? '4-4',
      score: d['score'] as int? ?? 0,
      cycles: d['cycles'] as int? ?? 0,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'mode': mode,
      'durationSec': durationSec,
      'breathPattern': breathPattern,
      'score': score,
      'cycles': cycles,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
