import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/treasure_hunt.dart';

class HuntProgress {
  const HuntProgress({
    required this.currentIndex,
    required this.completedObjectives,
    required this.objectiveScores,
    required this.isCompleted,
    required this.finalScore,
  });

  final int currentIndex;
  final int completedObjectives;
  final Map<int, int> objectiveScores;
  final bool isCompleted;
  final int finalScore;
}

class HuntProgressStats {
  const HuntProgressStats({
    required this.completedHunts,
    required this.earnedMedals,
  });

  final int completedHunts;
  final int earnedMedals;
}

class EarnedMedal {
  const EarnedMedal({
    required this.huntId,
    required this.cityId,
    required this.cityName,
    required this.huntTitle,
    required this.finalScore,
  });

  final String huntId;
  final String cityId;
  final String cityName;
  final String huntTitle;
  final int finalScore;
}

class HuntProgressService {
  HuntProgressService({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  static const int minimumMedalScore = 90;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>>? _progressReference(String huntId) {
    final user = _auth.currentUser;

    if (user == null) return null;

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('hunt_progress')
        .doc(huntId);
  }

  CollectionReference<Map<String, dynamic>>? _progressCollection() {
    final user = _auth.currentUser;

    if (user == null) return null;

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('hunt_progress');
  }

  Future<HuntProgress?> getProgress(String huntId) async {
    final reference = _progressReference(huntId);

    if (reference == null) return null;

    final snapshot = await reference.get();

    if (!snapshot.exists) return null;

    return _progressFromData(snapshot.data() ?? const {});
  }

  Future<void> startHunt(TreasureHunt hunt) async {
    final reference = _progressReference(hunt.id);

    if (reference == null) return;

    await reference.set({
      'huntId': hunt.id,
      'cityId': hunt.cityId,
      'cityName': hunt.cityName,
      'huntTitle': hunt.title,
      'currentIndex': 0,
      'completedObjectives': 0,
      'totalObjectives': hunt.objectives.length,
      'objectiveScores': <String, int>{},
      'status': 'in_progress',
      'finalScore': 0,
      'medalEarned': false,
      'startedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> restartHunt(TreasureHunt hunt) async {
    await startHunt(hunt);
  }

  Future<void> saveObjectiveScore({
    required TreasureHunt hunt,
    required int objectiveIndex,
    required int score,
  }) async {
    final reference = _progressReference(hunt.id);

    if (reference == null) return;

    final snapshot = await reference.get();
    final data = snapshot.data() ?? const {};
    final scores = Map<String, dynamic>.from(
      data['objectiveScores'] as Map? ?? const {},
    );

    scores['$objectiveIndex'] = score;

    final completedObjectives = scores.length;
    final isCompleted = completedObjectives >= hunt.objectives.length;
    final finalScore = isCompleted ? _averageScore(scores) : 0;

    await reference.set({
      'huntId': hunt.id,
      'cityId': hunt.cityId,
      'cityName': hunt.cityName,
      'huntTitle': hunt.title,
      'currentIndex': isCompleted ? hunt.objectives.length : objectiveIndex + 1,
      'completedObjectives': completedObjectives,
      'totalObjectives': hunt.objectives.length,
      'objectiveScores': scores,
      'status': isCompleted ? 'completed' : 'in_progress',
      'finalScore': finalScore,
      'medalEarned': isCompleted && finalScore >= minimumMedalScore,
      'completedAt': isCompleted ? FieldValue.serverTimestamp() : null,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Stream<HuntProgressStats> watchStats() {
    final collection = _progressCollection();

    if (collection == null) {
      return Stream.value(
        const HuntProgressStats(completedHunts: 0, earnedMedals: 0),
      );
    }

    return collection.snapshots().map((snapshot) {
      var completedHunts = 0;
      var earnedMedals = 0;

      for (final document in snapshot.docs) {
        final data = document.data();

        if (data['status'] == 'completed') {
          completedHunts++;
        }

        if (data['medalEarned'] == true) {
          earnedMedals++;
        }
      }

      return HuntProgressStats(
        completedHunts: completedHunts,
        earnedMedals: earnedMedals,
      );
    });
  }

  Stream<List<EarnedMedal>> watchEarnedMedals() {
    final collection = _progressCollection();

    if (collection == null) {
      return Stream.value(const []);
    }

    return collection.snapshots().map((snapshot) {
      final medals = snapshot.docs
          .where((document) => document.data()['medalEarned'] == true)
          .map((document) {
            final data = document.data();

            return EarnedMedal(
              huntId: data['huntId'] as String? ?? document.id,
              cityId: data['cityId'] as String? ?? '',
              cityName: data['cityName'] as String? ?? 'Oras',
              huntTitle: data['huntTitle'] as String? ?? 'Treasure hunt',
              finalScore: data['finalScore'] as int? ?? 0,
            );
          })
          .toList();

      medals.sort((a, b) => a.cityName.compareTo(b.cityName));

      return medals;
    });
  }

  HuntProgress _progressFromData(Map<String, dynamic> data) {
    final rawScores = Map<String, dynamic>.from(
      data['objectiveScores'] as Map? ?? const {},
    );
    final scores = rawScores.map((key, value) {
      return MapEntry(int.tryParse(key) ?? 0, value as int? ?? 0);
    });

    return HuntProgress(
      currentIndex: data['currentIndex'] as int? ?? 0,
      completedObjectives: data['completedObjectives'] as int? ?? 0,
      objectiveScores: scores,
      isCompleted: data['status'] == 'completed',
      finalScore: data['finalScore'] as int? ?? 0,
    );
  }

  int _averageScore(Map<String, dynamic> scores) {
    if (scores.isEmpty) return 0;

    final values = scores.values.map((value) => value as int? ?? 0);
    final total = values.fold<int>(0, (currentTotal, value) {
      return currentTotal + value;
    });

    return (total / scores.length).round();
  }
}
