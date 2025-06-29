import 'package:flutter/material.dart';
import 'package:coffe_shop_gpt/presentation/screens/auth/auth_wrapper.dart';
import 'package:slide_to_act/slide_to_act.dart'; // Import package slider

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1), // Mulai dari atas
      end: Offset.zero, // Selesai di posisi normal
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SlideTransition(
        position: _slideAnimation,
        child: Stack(
          children: [
            // Background Image
            Positioned.fill(
              child: Image.asset(
                'assets/images/drink_coffe_3point_coffee.jpg',
                fit: BoxFit.cover,
              ),
            ),
            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.8),
                  ],
                  stops: const [0.4, 1.0],
                ),
              ),
            ),
            // Konten Utama
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Latar belakang semi-transparan untuk logo dan teks
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5), // Background polos dengan opacity
                      borderRadius: BorderRadius.circular(20), // Membuat sudut lebih halus
                    ),
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/images/3pointcafe_logo.png',
                          height: 80, // Ukuran disesuaikan
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Ngopi asik, Makan Enak, Satu-satunya Cafe-Resto dengan Fasilitas terlengkap di JakSel',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            shadows: [Shadow(blurRadius: 10.0, color: Colors.black)],
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Your daily dose of happiness, delivered.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Widget Slide to Continue
                  SlideAction(
                    onSubmit: () {
                      // Fungsi ini akan dipanggil setelah animasi slider selesai
                      // Kita tambahkan sedikit delay agar transisi terasa mulus
                      Future.delayed(const Duration(milliseconds: 500), () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => const AuthWrapper()),
                        );
                      });
                    },
                    text: 'Geser untuk Mulai',
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    outerColor: Colors.brown.shade700,
                    innerColor: Colors.white,
                    sliderButtonIcon: const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.brown,
                      size: 20,
                    ),
                    animationDuration: const Duration(milliseconds: 300),
                    borderRadius: 12,
                    elevation: 4,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}