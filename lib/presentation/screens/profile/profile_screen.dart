// lib/presentation/screens/profile/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/services/auth_service.dart';

// PERUBAHAN: Menjadi StatefulWidget untuk mengelola state loading saat logout
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService authService = AuthService();
  bool _isLoggingOut = false;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile'), automaticallyImplyLeading: false,),
      body: _isLoggingOut
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          if (currentUser != null)
            ListTile(
              leading: CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(currentUser.photoURL ?? 'https://i.imgur.com/Z3N57Dk.png'),
              ),
              title: Text(currentUser.displayName ?? 'Guest User', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              subtitle: Text(currentUser.email ?? ''),
            ),
          const Divider(height: 30),

          // PERUBAHAN: ListTile "Pesanan Saya" telah dihapus dari sini.

          SwitchListTile(
            title: const Text('Dark Mode'),
            value: isDarkMode,
            onChanged: (value) => themeProvider.toggleTheme(value),
            secondary: Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () async {
              setState(() {
                _isLoggingOut = true;
              });
              await authService.signOut();
              // AuthWrapper akan menangani navigasi secara otomatis
              // Tidak perlu setState lagi karena widget akan di-unmount
            },
          ),
        ],
      ),
    );
  }
}