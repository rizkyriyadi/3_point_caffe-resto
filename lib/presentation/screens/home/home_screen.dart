import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/providers/theme_provider.dart';
import '../../../data/dummy_data.dart';
import '../../../data/models/coffee.dart';
import '../../widgets/category_tab_widget.dart';
import '../../widgets/coffee_card.dart';
import '../../widgets/empty_state_widget.dart';
import '../detail/product_detail_screen.dart';

class HomePageContent extends StatefulWidget {
  final Function(Coffee, String) onAddToCart;
  final Function(Coffee) onToggleFavorite;

  const HomePageContent({
    super.key,
    required this.onAddToCart,
    required this.onToggleFavorite,
  });

  @override
  State<HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  final List<String> _categories = [
    'All',
    'Cappuccino',
    'Macchiato',
    'Latte',
    'Americano',
  ];
  String _selectedCategory = 'All';
  String _searchQuery = '';
  List<Coffee> _displayedCoffees = [];

  // Dummy favorite list for demonstration inside this widget
  // In a real app, this would come from a state management solution
  final List<Coffee> _internalFavorites = [];

  @override
  void initState() {
    super.initState();
    _runFilter();
  }

  void _runFilter() {
    List<Coffee> results = coffeeList
        .where(
          (coffee) =>
              _searchQuery.isEmpty ||
              coffee.name.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();

    if (_selectedCategory != 'All') {
      results = results
          .where((coffee) => coffee.name == _selectedCategory)
          .toList();
    }
    setState(() => _displayedCoffees = results);
  }

  // Local toggle favorite to update UI instantly
  void _localToggleFavorite(Coffee coffee) {
    setState(() {
      if (_internalFavorites.contains(coffee)) {
        _internalFavorites.remove(coffee);
      } else {
        _internalFavorites.add(coffee);
      }
    });
    // Call the main toggle function passed from MainScreen
    widget.onToggleFavorite(coffee);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
        children: [
          _buildHeader(context),
          const SizedBox(height: 30),
          _buildSearchBar(),
          const SizedBox(height: 30),
          _buildCategoryTabs(context),
          const SizedBox(height: 20),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: _displayedCoffees.isEmpty
                ? EmptyStateWidget(key: UniqueKey())
                : GridView.builder(
                    key: ValueKey(_selectedCategory),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.72,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20,
                        ),
                    itemCount: _displayedCoffees.length,
                    itemBuilder: (context, index) {
                      final coffee = _displayedCoffees[index];
                      return CoffeeCard(
                        coffee: coffee,
                        isFavorite: _internalFavorites.contains(coffee),
                        onToggleFavorite: () => _localToggleFavorite(coffee),
                        onAddToCart: (c, s) => widget.onAddToCart(coffee, 'M'),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ProductDetailScreen(
                                coffee: coffee,
                                onAddToCart: widget.onAddToCart,
                                isFavorite: _internalFavorites.contains(coffee),
                                onToggleFavorite: () =>
                                    _localToggleFavorite(coffee),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    final isDarkMode =
        Provider.of<ThemeProvider>(context).themeMode == ThemeMode.dark;
    return TextField(
      onChanged: (value) {
        setState(() {
          _searchQuery = value;
          _runFilter();
        });
      },
      decoration: InputDecoration(
        hintText: 'Search coffee',
        hintStyle: TextStyle(color: isDarkMode ? Colors.white54 : Colors.grey),
        prefixIcon: Icon(
          Icons.search,
          color: isDarkMode ? Colors.white54 : Colors.grey,
        ),
        filled: true,
        fillColor: isDarkMode ? Colors.grey[850] : Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildCategoryTabs(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          return CategoryTabWidget(
            category: category,
            isSelected: _selectedCategory == category,
            onTap: () {
              setState(() => _selectedCategory = category);
              _runFilter();
            },
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final user = FirebaseAuth.instance.currentUser;
    String greetingName = user?.displayName?.split(' ').first ?? 'Guest';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, $greetingName',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Mau ngopi apa hari ini?',
              style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey),
            ),
          ],
        ),
        CircleAvatar(
          radius: 25,
          backgroundImage: NetworkImage(
            user?.photoURL ?? 'https://i.imgur.com/Z3N57Dk.png',
          ),
        ),
      ],
    );
  }
}
