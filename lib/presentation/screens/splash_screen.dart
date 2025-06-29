import 'package:flutter/material.dart';
import 'package:coffe_shop_gpt/presentation/screens/onboarding/onboarding_screen.dart'; // Import the onboarding screen
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

// Gunakan SingleTickerProviderStateMixin untuk menangani animasi
class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();

    // Inisialisasi AnimationController untuk durasi animasi
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Tentukan animasi slide dari bawah ke atas (Offset(0.0, 1.0) ke Offset.zero)
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    // Mulai animasi
    _controller.forward();

    // Atur timer untuk navigasi ke OnboardingScreen setelah animasi selesai
    Timer(const Duration(seconds: 5), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
      );
    });
  }

  @override
  void dispose() {
    // Hapus controller saat widget tidak lagi digunakan untuk mencegah kebocoran memori
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center, // Pusatkan item secara horizontal
          children: [
            // Bungkus konten dengan SlideTransition untuk animasi
            SlideTransition(
              position: _offsetAnimation,
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/3pointcafe_logo.png',
                    width: 150, // Sesuaikan ukuran sesuai kebutuhan
                    height: 150, // Sesuaikan ukuran sesuai kebutuhan
                  ),
                  const SizedBox(height: 20),
                  // Bungkus Teks dengan Padding untuk memastikan ada ruang di sekelilingnya
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40.0),
                    child: Text(
                      'Ngopi asik, Makan Enak, Satu-satunya Cafe-Resto dengan Fasilitas terlengkap di JakSel',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            const CircularProgressIndicator(), // Indikator loading
          ],
        ),
      ),
    );
  }
}