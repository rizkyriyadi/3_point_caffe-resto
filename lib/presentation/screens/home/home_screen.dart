// MENGGUNAKAN PAGEVIEW MANUAL, TIDAK ADA DEPENDENSI CAROUSEL EKSTERNAL

import 'dart:async'; // Import untuk Timer
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

// Helper class (Tidak ada perubahan di sini)
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });
  final double minHeight;
  final double maxHeight;
  final Widget child;
  @override
  double get minExtent => minHeight;
  @override
  double get maxExtent => maxHeight;
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }
  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}

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
  // Controller untuk PageView Kategori
  late final PageController _pageController;
  final List<String> _categories = ['All', 'drinks', 'food'];
  int _selectedCategoryIndex = 0;
  String _searchQuery = '';
  final List<Coffee> _internalFavorites = [];

  // State untuk Carousel Manual
  int _carouselCurrentIndex = 0;
  final PageController _carouselPageController = PageController(viewportFraction: 0.9);
  Timer? _carouselTimer;

  final List<String> _promoImageUrls = [
    'https://images.unsplash.com/photo-1559925393-8be0ec4767c8?q=80&w=2070&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1511920183353-3c9c93dae237?q=80&w=1887&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1542312621-9e9da15339a7?q=80&w=2070&auto=format&fit=crop',
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    // Timer untuk autoplay carousel manual
    _startCarouselTimer();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _carouselPageController.dispose();
    _carouselTimer?.cancel(); // Hentikan timer saat widget dihancurkan
    super.dispose();
  }

  void _startCarouselTimer() {
    _carouselTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!mounted) return; // Pastikan widget masih ada di tree
      int nextPage = _carouselCurrentIndex + 1;
      if (nextPage >= _promoImageUrls.length) {
        nextPage = 0;
      }
      _carouselPageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOut,
      );
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              child: _buildHeader(context),
            ),
            Expanded(
              child: NestedScrollView(
                headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                  return <Widget>[
                    SliverToBoxAdapter(child: _buildSearchBar(context)),
                    SliverToBoxAdapter(child: const SizedBox(height: 25)),
                    SliverToBoxAdapter(child: _buildCarouselPromo()),
                    SliverToBoxAdapter(child: const SizedBox(height: 15)),
                    SliverPersistentHeader(
                      delegate: _SliverAppBarDelegate(
                        minHeight: 75.0,
                        maxHeight: 75.0,
                        child: Container(
                          padding: const EdgeInsets.only(top: 10, bottom: 10),
                          decoration: BoxDecoration(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            boxShadow: innerBoxIsScrolled ? [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10.0,
                                offset: const Offset(0, 5),
                              ),
                            ] : null,
                          ),
                          child: _buildCategoryTabs(context),
                        ),
                      ),
                      pinned: true,
                    ),
                  ];
                },
                body: _buildCategoryPages(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCarouselPromo() {
    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: _carouselPageController,
            itemCount: _promoImageUrls.length,
            onPageChanged: (index) {
              setState(() {
                _carouselCurrentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              // Efek scaling untuk slide yang di tengah
              return AnimatedBuilder(
                animation: _carouselPageController,
                builder: (context, child) {
                  double value = 1.0;
                  if (_carouselPageController.position.haveDimensions) {
                    value = _carouselPageController.page! - index;
                    value = (1 - (value.abs() * 0.15)).clamp(0.85, 1.0);
                  }
                  return Center(
                    child: SizedBox(
                      height: Curves.easeOut.transform(value) * 180,
                      width: Curves.easeOut.transform(value) * double.infinity,
                      child: child,
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(25.0),
                    child: Image.network(_promoImageUrls[index], fit: BoxFit.cover),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        // Indikator dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _promoImageUrls.asMap().entries.map((entry) {
            return GestureDetector(
              onTap: () => _carouselPageController.animateToPage(entry.key, duration: const Duration(milliseconds: 300), curve: Curves.ease),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: _carouselCurrentIndex == entry.key ? 24.0 : 8.0,
                height: 8.0,
                margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: (Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.brown)
                      .withOpacity(_carouselCurrentIndex == entry.key ? 0.9 : 0.4),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCategoryPages(){
    return PageView.builder(
      controller: _pageController,
      itemCount: _categories.length,
      onPageChanged: (index) {
        setState(() {
          _selectedCategoryIndex = index;
        });
      },
      itemBuilder: (context, index) {
        final category = _categories[index];
        List<Coffee> displayedCoffees = coffeeList
            .where((coffee) =>
        _searchQuery.isEmpty ||
            coffee.name.toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList();
        if (category != 'All') {
          displayedCoffees = displayedCoffees
              .where((coffee) => coffee.category == category)
              .toList();
        }
        if (displayedCoffees.isEmpty) {
          return EmptyStateWidget(key: UniqueKey());
        }
        return GridView.builder(
          key: ValueKey(category),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.68,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
          ),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          itemCount: displayedCoffees.length,
          itemBuilder: (context, gridIndex) {
            final coffee = displayedCoffees[gridIndex];
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
        );
      },
    );
  }

  Widget _buildCategoryTabs(BuildContext context) {
    return Center(
      child: SizedBox(
        height: 45,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: _categories.length,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemBuilder: (context, index) {
            final category = _categories[index];
            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: CategoryTabWidget(
                category: category,
                isSelected: _selectedCategoryIndex == index,
                onTap: () {
                  _pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Mau coba apa hari ini?...',
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

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Text("Hello, Guest");
    }

    return FutureBuilder<DocumentSnapshot>(
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
    );
  }

  Widget _buildHeaderUI(ThemeData theme, String name, String? photoUrl) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Selamat datang kembali,', style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey, fontFamily: 'Poppins')),
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
}