// lib/core/services/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Stream untuk memantau status autentikasi user secara real-time
  Stream<User?> get user => _auth.authStateChanges();

  // Fungsi untuk mendaftar dengan Email & Password
  Future<User?> registerWithEmail(
    String email,
    String password,
    String fullName,
  ) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;
      if (user != null) {
        // Simpan data tambahan (nama lengkap) ke Firestore karena Firebase Auth tidak menyimpannya
        await _db.collection('users').doc(user.uid).set({
          'fullName': fullName,
          'email': email,
        });
        // Update profil Firebase Auth agar displayName juga terisi
        await user.updateDisplayName(fullName);
      }
      return user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // Fungsi untuk login dengan Email & Password
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // Fungsi untuk login dengan Google
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // Proses dibatalkan oleh user

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential result = await _auth.signInWithCredential(credential);
      User? user = result.user;

      // Jika ini adalah user baru, simpan datanya ke Firestore
      if (user != null && result.additionalUserInfo!.isNewUser) {
        await _db.collection('users').doc(user.uid).set({
          'fullName': user.displayName,
          'email': user.email,
          'photoUrl': user.photoURL,
        });
      }
      return user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // Fungsi untuk Logout
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
