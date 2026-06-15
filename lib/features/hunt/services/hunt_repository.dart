import 'package:cloud_firestore/cloud_firestore.dart';

import '../data/iasi_hunt.dart';
import '../models/treasure_hunt.dart';

class HuntRepository {
  HuntRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<TreasureHunt?> getActiveHuntForCity(String cityId) async {
    final huntSnapshot = await _firestore
        .collection('hunts')
        .where('cityId', isEqualTo: cityId)
        .where('isActive', isEqualTo: true)
        .limit(1)
        .get();

    if (huntSnapshot.docs.isEmpty) return null;

    final huntDocument = huntSnapshot.docs.first;
    final huntData = huntDocument.data();

    final objectivesSnapshot = await _firestore
        .collection('hunt_objectives')
        .where('huntId', isEqualTo: huntDocument.id)
        .get();

    final sortedObjectiveDocs = [...objectivesSnapshot.docs]
      ..sort((a, b) {
        final aOrder = a.data()['order'] as int? ?? 0;
        final bOrder = b.data()['order'] as int? ?? 0;

        return aOrder.compareTo(bOrder);
      });

    final objectives = sortedObjectiveDocs.map((document) {
      final data = document.data();
      final order = data['order'] as int? ?? 0;

      return HuntObjective(
        name: data['name'] as String? ?? '',
        story: data['story'] as String? ?? '',
        hints: List<String>.from(data['hints'] as List? ?? const []),
        reward: data['reward'] as String? ?? '',
        photoInstruction: _photoInstructionFor(
          huntDocument.id,
          order,
          data['photoInstruction'] as String?,
        ),
        latitude: (data['latitude'] as num?)?.toDouble(),
        longitude: (data['longitude'] as num?)?.toDouble(),
        officialImageUrl: data['officialImageUrl'] as String?,
        officialImageAsset: _localOfficialImageAsset(huntDocument.id, order),
      );
    }).toList();

    return TreasureHunt(
      id: huntDocument.id,
      cityId: huntData['cityId'] as String? ?? cityId,
      cityName: _cityNameFromId(huntData['cityId'] as String? ?? cityId),
      title: huntData['title'] as String? ?? '',
      story: huntData['story'] as String? ?? '',
      startPoint: huntData['startPoint'] as String? ?? '',
      estimatedTime: huntData['estimatedTime'] as String? ?? '',
      rewardName: huntData['rewardName'] as String? ?? '',
      objectives: objectives,
    );
  }

  Future<TreasureHunt> getHuntWithFallback(String cityId) async {
    final fallbackHunt = _fallbackHuntForCity(cityId);

    try {
      final firestoreHunt = await getActiveHuntForCity(cityId);

      if (firestoreHunt != null && firestoreHunt.objectives.isNotEmpty) {
        return firestoreHunt;
      }
    } catch (_) {
      return fallbackHunt;
    }

    return fallbackHunt;
  }

  String _cityNameFromId(String cityId) {
    return switch (cityId) {
      'iasi' => 'Iași',
      _ => cityId,
    };
  }

  TreasureHunt _fallbackHuntForCity(String cityId) {
    return switch (cityId) {
      'iasi' => iasiTreasureHunt,
      _ => iasiTreasureHunt,
    };
  }

  String? _localOfficialImageAsset(String huntId, int order) {
    return switch ((huntId, order)) {
      ('iasi_tainele_vechi', 1) => 'assets/official_images/iasi/Parcul_copou/',
      ('iasi_tainele_vechi', 2) => 'assets/official_images/iasi/Piata_unirii/',
      ('iasi_tainele_vechi', 3) =>
        'assets/official_images/iasi/Teatrul_national/',
      ('iasi_tainele_vechi', 4) =>
        'assets/official_images/iasi/Catedrala_mitropolitana/',
      ('iasi_tainele_vechi', 5) =>
        'assets/official_images/iasi/Palatul_culturii/',
      _ => null,
    };
  }

  String _localPhotoInstruction(String huntId, int order) {
    if (huntId != 'iasi_tainele_vechi') {
      return 'Fă poza din fața locației, cu reperul principal cât mai clar în cadru.';
    }

    return switch (order) {
      1 =>
        'Fă poza din fața zonei indicate, cu reperul principal în centru și fără zoom exagerat.',
      2 =>
        'Fă poza din fața locației, cu reperul principal în mijloc și cât mai puține obstacole în cadru.',
      3 =>
        'Fă poza din fața locației, de la distanță medie, astfel încât intrarea și partea superioară să încapă în cadru.',
      4 =>
        'Fă poza din fața locației, cu telefonul drept și partea superioară vizibilă în cadru.',
      5 =>
        'Fă poza din fața locației, de la distanță, astfel încât reperul principal să fie vizibil cât mai complet.',
      _ =>
        'Fă poza din fața locației, cu reperul principal cât mai clar în cadru.',
    };
  }

  String _photoInstructionFor(
    String huntId,
    int order,
    String? firestoreInstruction,
  ) {
    if (huntId == 'iasi_tainele_vechi') {
      return _localPhotoInstruction(huntId, order);
    }

    return firestoreInstruction ??
        'Fă poza din fața locației, cu reperul principal cât mai clar în cadru.';
  }
}
