import 'package:cloud_firestore/cloud_firestore.dart';
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
  final List<String> _categories = ['All', 'drinks', 'food'];
  String _selectedCategory = 'All';
  String _searchQuery = '';
  List<Coffee> _displayedCoffees = [];
  final List<Coffee> _internalFavorites = [];

  @override
  void initState() {
    super.initState();
    _runFilter();
  }

  void _runFilter() {
    List<Coffee> results = coffeeList.where((coffee) => _searchQuery.isEmpty || coffee.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    if (_selectedCategory != 'All') results = results.where((coffee) => coffee.category == _selectedCategory).toList();
    setState(() => _displayedCoffees = results);
  }

  void _localToggleFavorite(Coffee coffee) {
    setState(() {
      if (_internalFavorites.contains(coffee)) {
        _internalFavorites.remove(coffee);
      } else {
        _internalFavorites.add(coffee);
      }
    });
    widget.onToggleFavorite(coffee);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 20),
          children: [
            _buildHeader(context),
            const SizedBox(height: 25),
            _buildSearchBar(context),
            const SizedBox(height: 25),
            _buildPromoBanner(context),
            const SizedBox(height: 25),
            _buildCategoryTabs(context),
            const SizedBox(height: 20),
            _buildCoffeeGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildCoffeeGrid() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: _displayedCoffees.isEmpty
          ? EmptyStateWidget(key: UniqueKey())
          : GridView.builder(
              key: ValueKey(_selectedCategory),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75, // Adjusted for new card layout
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _displayedCoffees.length,
              itemBuilder: (context, index) {
                final coffee = _displayedCoffees[index];
                return CoffeeCard(
                  coffee: coffee,
                  isFavorite: _internalFavorites.contains(coffee),
                  onToggleFavorite: () => _localToggleFavorite(coffee),
                  onAddToCart: widget.onAddToCart,
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => ProductDetailScreen(
                        coffee: coffee,
                        onAddToCart: widget.onAddToCart,
                        isFavorite: _internalFavorites.contains(coffee),
                        onToggleFavorite: () => _localToggleFavorite(coffee),
                      ),
                    ));
                  },
                );
              },
            ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
            _runFilter();
          });
        },
        decoration: InputDecoration(
          hintText: 'Find your coffee...',
          hintStyle: TextStyle(fontFamily: 'Poppins', color: isDarkMode ? Colors.white54 : Colors.grey[600]),
          prefixIcon: Icon(Icons.search_rounded, color: isDarkMode ? Colors.white70 : Colors.grey[700], size: 28),
          filled: true,
          fillColor: isDarkMode ? Colors.grey[850] : Colors.grey[200],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildCategoryTabs(BuildContext context) {
    return SizedBox(
      height: 45,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        padding: const EdgeInsets.only(left: 20),
        itemBuilder: (context, index) {
          final category = _categories[index];
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: CategoryTabWidget(
              category: category,
              isSelected: _selectedCategory == category,
              onTap: () {
                setState(() => _selectedCategory = category);
                _runFilter();
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Text("Hello, Guest"),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: FutureBuilder<DocumentSnapshot>(
        future: user.isAnonymous ? null : FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
        builder: (context, snapshot) {
          String displayName = 'Guest';
          String? photoUrl = 'https://i.imgur.com/Z3N57Dk.png';

          if (user.displayName != null && user.displayName!.isNotEmpty) {
            displayName = user.displayName!.split(' ').first;
            photoUrl = user.photoURL ?? photoUrl;
          } else if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
            Map<String, dynamic>? data = snapshot.data!.data() as Map<String, dynamic>?;
            String fullName = data?['fullName'] ?? 'User';
            displayName = fullName.split(' ').first;
          }

          return _buildHeaderUI(theme, displayName, photoUrl);
        },
      ),
    );
  }

  Widget _buildHeaderUI(ThemeData theme, String name, String? photoUrl) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Good morning,', style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey, fontFamily: 'Poppins')),
            const SizedBox(height: 4),
            Text(name, style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, fontFamily: 'Urbanist')),
          ],
        ),
        CircleAvatar(
          radius: 28,
          backgroundImage: NetworkImage(photoUrl!),
        ),
      ],
    );
  }

  Widget _buildPromoBanner(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark ? const Color(0xFF1F1F1F) : const Color(0xFF313131),
        borderRadius: BorderRadius.circular(25),
        image: const DecorationImage(
          image: AssetImage('assets/images/promo_banner.png'), // Pastikan gambar ini ada
          fit: BoxFit.cover,
          opacity: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Promo Today',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w300, fontFamily: 'Poppins'),
          ),
          const SizedBox(height: 8),
          const Text(
            'Get 20% off for your first order!',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Urbanist'),
          ),
          const SizedBox(height: 15),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
            ),
            child: const Text('Claim Now', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
          )
        ],
      ),
    );
  }
}
