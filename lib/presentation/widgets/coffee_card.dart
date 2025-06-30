// lib/presentation/widgets/coffee_card.dart

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
      child: Card( // Menggunakan CardTheme dari AppTheme
        elevation: isDarkMode ? 1 : 3,
        shadowColor: isDarkMode ? Colors.black.withOpacity(0.5) : Colors.grey.withOpacity(0.2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImage(context, theme),
            _buildInfo(context, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext context, ThemeData theme) {
    return Expanded(
      flex: 5,
      child: Hero(
        tag: coffee.image + coffee.name,
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: CachedNetworkImage(
            imageUrl: coffee.image,
            placeholder: (context, url) => Center(child: CircularProgressIndicator(color: theme.primaryColor)),
            errorWidget: (context, url, error) => const Icon(Icons.broken_image, color: Colors.grey, size: 40),
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _buildInfo(BuildContext context, ThemeData theme) {
    return Expanded(
      flex: 4,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  coffee.name,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                // --- PERBAIKAN UTAMA DI SINI ---
                // Hanya tampilkan Text widget ini jika subtitle tidak null & tidak kosong
                if (coffee.subtitle != null && coffee.subtitle!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2.0),
                    child: Text(
                      coffee.subtitle!, // Gunakan ! karena sudah dicek tidak null
                      style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  AppTheme.formatRupiah(coffee.prices['M'] ?? 0.0),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
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
          color: theme.primaryColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: theme.primaryColor.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: const Icon(Icons.add_shopping_cart_rounded, color: Colors.white, size: 22),
      ),
    );
  }
}