import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileImage {
  const ProfileImage({required this.type, required this.path});

  final String type;
  final String path;

  bool get isAsset => type == 'asset';
  bool get isNetwork => type == 'custom' && path.startsWith('http');
  bool get isLocalFile => type == 'custom' && !path.startsWith('http');
}

class AvatarService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get _currentUser => _auth.currentUser;

  Stream<ProfileImage?> watchProfileImage() {
    final user = _currentUser;

    if (user == null) return Stream.value(null);

    return _firestore.collection('users').doc(user.uid).snapshots().map((
      snapshot,
    ) {
      final data = snapshot.data();

      if (data == null) return null;

      final type = data['profileImageType'] as String?;
      final path = data['profileImagePath'] as String?;

      if (type == null || path == null || path.isEmpty) return null;

      return ProfileImage(type: type, path: path);
    });
  }

  Future<void> savePresetAvatar(String assetPath) async {
    final user = _currentUser;

    if (user == null) return;

    await _firestore.collection('users').doc(user.uid).set({
      'profileImageType': 'asset',
      'profileImagePath': assetPath,
      'avatarUpdatedAt': Timestamp.now(),
    }, SetOptions(merge: true));
  }

  Future<void> saveCustomProfileImage(File imageFile) async {
    final user = _currentUser;

    if (user == null) return;

    await _firestore.collection('users').doc(user.uid).set({
      'profileImageType': 'custom',
      'profileImagePath': imageFile.path,
      'avatarUpdatedAt': Timestamp.now(),
    }, SetOptions(merge: true));
  }
}
