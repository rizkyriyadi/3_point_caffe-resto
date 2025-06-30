import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart'; // Jangan lupa import ini
import '../../../data/models/coffee.dart';
import '../../widgets/empty_state_widget.dart';
import '../../../utils/app_theme.dart'; // Import AppTheme untuk format Rupiah

class FavoritesScreen extends StatelessWidget {
  final List<Coffee> favoriteCoffees;
  final Function(Coffee) onToggleFavorite;
  const FavoritesScreen({super.key, required this.favoriteCoffees, required this.onToggleFavorite});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: favoriteCoffees.isEmpty
          ? const EmptyStateWidget()
          : ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: favoriteCoffees.length,
        itemBuilder: (context, index) {
          final coffee = favoriteCoffees[index];
          return Card(
            color: isDarkMode ? const Color(0xFF1F1F1F) : Colors.white,
            elevation: 1,
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              // --- PERBAIKAN UTAMA DI SINI ---
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: coffee.image,
                  placeholder: (context, url) => const CircularProgressIndicator(),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                  fit: BoxFit.cover,
                  width: 56,
                  height: 56,
                ),
              ),
              title: Text(coffee.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(AppTheme.formatRupiah(coffee.prices['M'] ?? 0.0)),
              trailing: IconButton(
                icon: const Icon(Icons.favorite, color: Colors.redAccent, size: 28),
                onPressed: () => onToggleFavorite(coffee),
              ),
            ),
          );
        },
      ),
    );
  }
}