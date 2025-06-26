import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore

import '../../../core/providers/theme_provider.dart';
import '../../../core/services/auth_service.dart';
import '../../../data/models/order.dart';
import '../orders/my_orders_screen.dart';

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
      appBar: AppBar(title: const Text('Profile'), automaticallyImplyLeading: false),
      body: _isLoggingOut
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          if (currentUser != null)
          // --- PERBAIKAN UNTUK BUG NAMA "GUEST" ---
            FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                  Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
                  String fullName = data['fullName'] ?? currentUser.displayName ?? 'Guest User';
                  return _buildUserInfoTile(currentUser, fullName);
                }
                // Tampilkan info dasar selama loading
                return _buildUserInfoTile(currentUser, "Loading...");
              },
            ),

          const Divider(height: 30),
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
              setState(() => _isLoggingOut = true);
              await authService.signOut();
              // AuthWrapper akan menangani navigasi
            },
          ),
        ],
      ),
    );
  }

  // Widget helper untuk menampilkan info user
  Widget _buildUserInfoTile(User user, String displayName) {
    return ListTile(
      leading: CircleAvatar(
        radius: 30,
        backgroundImage: NetworkImage(user.photoURL ?? 'https://i.imgur.com/Z3N57Dk.png'),
      ),
      title: Text(displayName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      subtitle: Text(user.email ?? ''),
    );
  }
}