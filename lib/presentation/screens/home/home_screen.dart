import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/services/product_service.dart';
import '../../../data/models/coffee.dart';
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

    // Tambahkan listener untuk memicu filter saat ada perubahan
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
    // Ambil kategori dan query pencarian terbaru
    final selectedCategory = _categories[_tabController.index];
    final searchQuery = _searchController.text.toLowerCase();

    List<Coffee> results = List.from(_allProducts);

    // 1. Filter berdasarkan kategori
    if (selectedCategory != 'All') {
      results.retainWhere((coffee) => coffee.category.toLowerCase() == selectedCategory.toLowerCase());
    }

    // 2. Filter berdasarkan pencarian
    if (searchQuery.isNotEmpty) {
      results.retainWhere((coffee) => coffee.name.toLowerCase().contains(searchQuery));
    }

    // Perbarui UI dengan data yang sudah difilter
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
            return const EmptyStateWidget();
          }

          if (_allProducts.isEmpty) {
            _allProducts = snapshot.data!;
            _displayedCoffees = List.from(_allProducts);
          }

          return Scaffold(
            appBar: _buildAppBar(context),
            body: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverToBoxAdapter(child: _buildHeader(context)),
                  SliverToBoxAdapter(child: _buildSearchBar(context)),
                  SliverToBoxAdapter(child: _buildPromoBanner(context)),
                  SliverPersistentHeader(
                    delegate: _SliverTabBarDelegate(_buildCategoryTabs(context)),
                    pinned: true,
                    floating: true,
                  ),
                ];
              },
              body: _buildCoffeeGrid(),
            ),
          );
        },
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      leading: IconButton(icon: const Icon(Icons.menu_rounded), onPressed: () {}),
      title: const Text('BrewBlend'),
      actions: [
        IconButton(icon: const Icon(Icons.shopping_bag_outlined), onPressed: () {}),
        const SizedBox(width: 10),
      ],
    );
  }

  Widget _buildCoffeeGrid() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _displayedCoffees.isEmpty
          ? EmptyStateWidget(key: UniqueKey())
          : GridView.builder(
        key: ValueKey(_categories[_tabController.index] + _searchController.text),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, childAspectRatio: 0.68, crossAxisSpacing: 15, mainAxisSpacing: 15),
        padding: const EdgeInsets.all(20),
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

  Widget _buildSearchBar(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        controller: _searchController, // Menggunakan controller
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

  TabBar _buildCategoryTabs(BuildContext context) {
    return TabBar(
      controller: _tabController,
      tabs: _categories.map((String category) => Tab(text: category)).toList(),
      isScrollable: true,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      labelStyle: const TextStyle(fontWeight: FontWeight.bold),
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: _buildHeaderUI(theme, 'Guest', null),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
        builder: (context, snapshot) {
          String displayName = 'Guest';
          String? photoUrl = user.photoURL;

          if (user.displayName != null && user.displayName!.isNotEmpty) {
            displayName = user.displayName!.split(' ').first;
          } else if (snapshot.connectionState == ConnectionState.done && snapshot.hasData && snapshot.data!.exists) {
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
          backgroundImage: NetworkImage(photoUrl ?? 'https://i.imgur.com/Z3N57Dk.png'),
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
        color: const Color(0xFF313131),
        borderRadius: BorderRadius.circular(25),
        image: const DecorationImage(
          image: AssetImage('assets/images/promo_banner.png'),
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
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
  _SliverTabBarDelegate(this._tabBar);
  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: Theme.of(context).scaffoldBackgroundColor, child: _tabBar);
  }
  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) => false;
}