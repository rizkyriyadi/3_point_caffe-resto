import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart'; // Import package baru
import '../../data/models/coffee.dart';
import '../../utils/app_theme.dart';

class CoffeeCard extends StatelessWidget {
  final Coffee coffee;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;
  final Function(Coffee, String) onAddToCart;
  final VoidCallback onTap;

  const CoffeeCard({
    super.key,
    required this.coffee,
    required this.isFavorite,
    required this.onToggleFavorite,
    required this.onAddToCart,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          // ... (dekorasi container Anda sudah bagus, tidak perlu diubah)
          gradient: isDarkMode
              ? const LinearGradient(
            colors: [Color(0xFF2E2E2E), Color(0xFF1A1A1A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
              : LinearGradient(
            colors: [Colors.white, Colors.grey[50]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDarkMode ? 0.5 : 0.08),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImage(context, theme), // Kirim context untuk akses theme di placeholder
            _buildInfo(context, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext context, ThemeData theme) {
    return Expanded(
      flex: 5,
      child: Stack(
        children: [
          Hero(
            tag: coffee.image + coffee.name,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
              // PERBAIKAN UTAMA: Gunakan CachedNetworkImage
              child: CachedNetworkImage(
                imageUrl: coffee.image,
                placeholder: (context, url) => Center(child: CircularProgressIndicator(color: theme.primaryColor)),
                errorWidget: (context, url, error) => const Icon(Icons.broken_image, color: Colors.grey, size: 40),
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  const Icon(Icons.star_rounded, color: Color(0xFFFFD700), size: 16),
                  const SizedBox(width: 5),
                  Text(
                    coffee.rating.toString(),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfo(BuildContext context, ThemeData theme) {
    return Expanded(
      flex: 4,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(15, 12, 15, 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              coffee.name,
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontFamily: 'Urbanist'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              'with ${coffee.subtitle}',
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  // PENYEMPURNAAN: Lebih aman dari error jika harga 'M' tidak ada
                  AppTheme.formatRupiah(coffee.prices['M'] ?? 0.0),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                    fontFamily: 'Urbanist',
                  ),
                ),
                _buildAddToCartButton(context, theme),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddToCartButton(BuildContext context, ThemeData theme) {
    return GestureDetector(
      onTap: () => onAddToCart(coffee, 'M'),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: theme.colorScheme.primary,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: const Icon(Icons.add_shopping_cart_rounded, color: Colors.white, size: 22),
      ),
    );
  }
}