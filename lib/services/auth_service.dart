import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Utilisateur actuel
  User? get currentUser => _auth.currentUser;

  // Stream pour écouter l'état de connexion
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Inscription
  Future<UserCredential?> register({
    required String email,
    required String password,
    required String nom,
    required String role, // 'chercheur' ou 'proprietaire'
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Sauvegarde dans Firestore
      await _firestore.collection('users').doc(result.user!.uid).set({
        'uid': result.user!.uid,
        'nom': nom,
        'email': email,
        'role': role,
        'createdAt': DateTime.now(),
      });

      return result;
    } catch (e) {
      rethrow;
    }
  }

  // Connexion
  Future<UserCredential?> login({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Déconnexion
  Future<void> logout() async {
    await _auth.signOut();
  }
}