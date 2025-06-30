import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/services/product_service.dart';
import '../../../data/models/coffee.dart';
import '../../widgets/category_tab_widget.dart';
import '../../widgets/coffee_card.dart';
import '../../widgets/empty_state_widget.dart';
import '../detail/product_detail_screen.dart';

class HomePageContent extends StatefulWidget {
  final List<Coffee> favoriteCoffees;
  final Function(Coffee) onToggleFavorite;
  final Function(Coffee, String) onAddToCart;

  const HomePageContent({
    super.key,
    required this.favoriteCoffees,
    required this.onToggleFavorite,
    required this.onAddToCart,
  });

  @override
  State<HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> with TickerProviderStateMixin {
  final ProductService _productService = ProductService();
  late Future<List<Coffee>> _productsFuture;
  late TabController _tabController;

  List<Coffee> _allProducts = [];
  List<Coffee> _displayedCoffees = [];

  final List<String> _categories = ['All', 'drinks', 'food'];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _productsFuture = _productService.getProducts();
    _tabController = TabController(length: _categories.length, vsync: this);

    _searchController.addListener(_runFilter);
    _tabController.addListener(_runFilter);
  }

  @override
  void dispose() {
    _searchController.removeListener(_runFilter);
    _tabController.removeListener(_runFilter);
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _runFilter() {
    if (_allProducts.isEmpty) return;

    final selectedCategory = _categories[_tabController.index];
    final searchQuery = _searchController.text.toLowerCase();

    List<Coffee> results = List.from(_allProducts);

    if (selectedCategory != 'All') {
      results.retainWhere((c) => c.category.toLowerCase() == selectedCategory.toLowerCase());
    }

    if (searchQuery.isNotEmpty) {
      results.retainWhere((c) => c.name.toLowerCase().contains(searchQuery));
    }

    if (mounted) {
      setState(() {
        _displayedCoffees = results;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder<List<Coffee>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text("Gagal memuat produk."));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const EmptyStateWidget(message: "Saat ini belum ada produk tersedia.");
          }

          if (_allProducts.isEmpty) {
            _allProducts = snapshot.data!;
            _displayedCoffees = List.from(_allProducts);
          }

          // UI utama menggunakan ListView agar semua komponen bisa di-scroll
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            children: [
              _buildHeader(context),
              const SizedBox(height: 24),
              _buildSearchBar(context),
              const SizedBox(height: 24),
              _buildPromoBanner(context),
              const SizedBox(height: 24),
              _buildCategoryTabs(context),
              const SizedBox(height: 20),
              _buildCoffeeGrid(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final user = FirebaseAuth.instance.currentUser;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // FutureBuilder untuk mengambil nama user dari Firestore
          FutureBuilder<DocumentSnapshot>(
            future: user != null ? FirebaseFirestore.instance.collection('users').doc(user.uid).get() : null,
            builder: (context, snapshot) {
              String displayName = 'Guest';
              if (user?.displayName != null && user!.displayName!.isNotEmpty) {
                displayName = user.displayName!.split(' ').first;
              } else if (snapshot.connectionState == ConnectionState.done && snapshot.hasData && snapshot.data!.exists) {
                Map<String, dynamic>? data = snapshot.data!.data() as Map<String, dynamic>?;
                String fullName = data?['fullName'] ?? 'Guest';
                displayName = fullName.split(' ').first;
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selamat Pagi,',
                    style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey, fontFamily: 'Poppins'),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    displayName,
                    style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, fontFamily: 'Urbanist'),
                  ),
                ],
              );
            },
          ),
          CircleAvatar(
            radius: 28,
            backgroundImage: NetworkImage(user?.photoURL ?? 'https://i.imgur.com/Z3N57Dk.png'),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Cari kopi favoritmu...',
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

  Widget _buildPromoBanner(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF313131),
        borderRadius: BorderRadius.circular(25),
        image: const DecorationImage(
          image: AssetImage('assets/images/promo_banner.png'), // Pastikan gambar ini ada di assets
          fit: BoxFit.cover,
          opacity: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Promo Today', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w300, fontFamily: 'Poppins')),
          const SizedBox(height: 8),
          const Text('Get 20% off for your first order!', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Urbanist')),
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
              isSelected: _tabController.index == index,
              onTap: () {
                _tabController.animateTo(index);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildCoffeeGrid() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _displayedCoffees.isEmpty
          ? EmptyStateWidget(key: UniqueKey(), message: "Tidak ada produk di kategori ini.")
          : GridView.builder(
        key: ValueKey(_categories[_tabController.index] + _searchController.text),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.72,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _displayedCoffees.length,
        itemBuilder: (context, index) {
          final coffee = _displayedCoffees[index];
          final isFavorite = widget.favoriteCoffees.contains(coffee);
          return CoffeeCard(
            coffee: coffee,
            isFavorite: isFavorite,
            onToggleFavorite: () => widget.onToggleFavorite(coffee),
            onAddToCart: widget.onAddToCart,
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => ProductDetailScreen(
                  coffee: coffee,
                  onAddToCart: widget.onAddToCart,
                  isFavorite: isFavorite,
                  onToggleFavorite: () => widget.onToggleFavorite(coffee),
                ),
              ));
            },
          );
        },
      ),
    );
  }
}