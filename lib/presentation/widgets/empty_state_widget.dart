import 'package:flutter/material.dart';

class EmptyStateWidget extends StatelessWidget {
  // PENAMBAHAN: Tambahkan parameter message
  final String message;

  const EmptyStateWidget({
    super.key,
    this.message = "Sepertinya belum ada apa-apa di sini.", // Beri nilai default
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.network('https://i.imgur.com/sBMS2h6.png', height: 150),
            const SizedBox(height: 20),
            const Text(
              'Tidak Ada Data',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // Gunakan message yang diterima dari parameter
            Text(
              message,
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}