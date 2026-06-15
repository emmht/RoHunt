import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EmailNotVerifiedException implements Exception {}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Future<void> _sendVerificationEmail(User user) async {
    try {
      await user.sendEmailVerification();
    } on FirebaseAuthException {
      return;
    }
  }

  Future<void> resendVerificationEmail() async {
    final user = _auth.currentUser;

    if (user != null && !user.emailVerified) {
      await _sendVerificationEmail(user);
    }
  }

  Future<bool> isCurrentUserEmailVerified() async {
    final user = _auth.currentUser;

    if (user == null) return false;

    await user.reload();
    return _auth.currentUser?.emailVerified ?? false;
  }

  // REGISTER
  Future<User?> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credential.user;

    if (user != null) {
      await user.updateDisplayName(name);
      await _sendVerificationEmail(user);

      try {
        await _firestore.collection('users').doc(user.uid).set({
          'name': name,
          'email': email,
          'emailVerified': user.emailVerified,
          'createdAt': Timestamp.now(),
        });
      } on FirebaseException {
        return user;
      }
    }

    return user;
  }

  // LOGIN
  Future<User?> login({required String email, required String password}) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credential.user;

    if (user != null && !user.emailVerified) {
      throw EmailNotVerifiedException();
    }

    if (user != null) {
      try {
        await _firestore.collection('users').doc(user.uid).set({
          'email': user.email,
          'emailVerified': true,
          'lastLoginAt': Timestamp.now(),
        }, SetOptions(merge: true));
      } on FirebaseException {
        return user;
      }
    }

    return user;
  }

  // LOGOUT
  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<void> sendPasswordResetEmail({required String email}) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> updateName(String name) async {
    final user = _auth.currentUser;

    if (user == null) return;

    await user.updateDisplayName(name);
    await user.reload();

    try {
      await _firestore.collection('users').doc(user.uid).set({
        'name': name,
        'updatedAt': Timestamp.now(),
      }, SetOptions(merge: true));
    } on FirebaseException {
      return;
    }
  }

  Future<void> deleteAccount() async {
    final user = _auth.currentUser;

    if (user == null) return;

    try {
      await _firestore.collection('users').doc(user.uid).delete();
    } on FirebaseException {
      // Contul din Firebase Auth rămâne prioritar pentru ștergere.
    }

    await user.delete();
  }
}
