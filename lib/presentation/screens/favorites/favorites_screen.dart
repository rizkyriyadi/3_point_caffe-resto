import 'package:flutter/material.dart';
import '../../../data/models/coffee.dart';
import '../../widgets/empty_state_widget.dart';

class FavoritesScreen extends StatelessWidget {
  final List<Coffee> favoriteCoffees;
  final Function(Coffee) onToggleFavorite;
  const FavoritesScreen({
    super.key,
    required this.favoriteCoffees,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: favoriteCoffees.isEmpty
          ? const EmptyStateWidget()
          : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: favoriteCoffees.length,
              itemBuilder: (context, index) {
                final coffee = favoriteCoffees[index];
                return Card(
                  color: isDarkMode ? Colors.grey[850] : Colors.white,
                  elevation: isDarkMode ? 1 : 2,
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(coffee.image),
                    ),
                    title: Text(coffee.name),
                    subtitle: Text('\$${coffee.prices['M']}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.favorite, color: Colors.redAccent),
                      onPressed: () => onToggleFavorite(coffee),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
