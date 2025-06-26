import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'core/providers/theme_provider.dart';
import 'presentation/screens/auth/auth_wrapper.dart';
import 'utils/app_theme.dart';
import 'core/utils/firebase_options.dart';

void main() async {
  // Memastikan semua widget binding sudah siap sebelum menjalankan kode async.
  WidgetsFlutterBinding.ensureInitialized();

  // Menginisialisasi Firebase sebelum aplikasi berjalan.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    // Mendaftarkan ThemeProvider di level tertinggi agar bisa diakses di seluruh aplikasi.
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const CoffeeApp(),
    ),
  );
}

class CoffeeApp extends StatelessWidget {
  const CoffeeApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: '3Point Caffe & Resto',
      debugShowCheckedModeBanner: false,

      // Menggunakan definisi tema dari file terpisah.
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,

      // Mengatur mode tema (light/dark) berdasarkan state di ThemeProvider.
      themeMode: themeProvider.themeMode,

      // Titik masuk UI aplikasi sekarang adalah AuthWrapper,
      // yang akan menentukan apakah user harus ke halaman Login atau Home.
      home: const AuthWrapper(),
    );
  }
}