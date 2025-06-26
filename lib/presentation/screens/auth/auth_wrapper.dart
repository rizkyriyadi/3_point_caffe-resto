// lib/presentation/screens/auth/auth_wrapper.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/services/auth_service.dart';
import '../main_screen.dart';
import 'login_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Kita akan membuat AuthService di langkah berikutnya
    final authService = AuthService();

    return StreamBuilder<User?>(
      stream: authService.user,
      builder: (context, snapshot) {
        // Saat Firebase sedang memeriksa status login, tampilkan loading.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Jika data user ada (tidak null), berarti pengguna sudah login.
        if (snapshot.hasData) {
          return const MainScreen(); // Arahkan ke Halaman Utama Aplikasi
        }
        // Jika tidak ada data user, berarti pengguna belum login.
        else {
          return const LoginScreen(); // Arahkan ke Halaman Login
        }
      },
    );
  }
}
