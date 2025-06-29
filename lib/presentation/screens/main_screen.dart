import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/providers/theme_provider.dart';
import '../../data/models/cart_item.dart';
import '../../data/models/coffee.dart';
import '../../data/models/order.dart';

import 'home/home_screen.dart';
import 'favorites/favorites_screen.dart';
import 'cart/cart_screen.dart';
import 'orders/my_orders_screen.dart';
import 'profile/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // State utama aplikasi
  final List<Coffee> _favoriteCoffees = [];
  final List<CartItem> _cartItems = [];
  final List<Order> _allOrders = [];

  // --- Fungsi untuk memodifikasi state ---

  void _toggleFavorite(Coffee coffee) {
    setState(() {
      // Pengecekan yang lebih aman untuk menghindari duplikat objek
      final isFavorited = _favoriteCoffees.any((item) => item.name == coffee.name);
      if (isFavorited) {
        _favoriteCoffees.removeWhere((item) => item.name == coffee.name);
      } else {
        _favoriteCoffees.add(coffee);
      }
    });
  }

  void _placeOrder(List<CartItem> items, String method, double total) {
    setState(() {
      final newOrder = Order(
        id: 'ID-${DateTime.now().millisecondsSinceEpoch}',
        items: List<CartItem>.from(items),
        orderMethod: method,
        totalAmount: total,
        orderDate: DateTime.now(),
        status: OrderStatus.ongoing,
      );
      _allOrders.insert(0, newOrder);
      _cartItems.clear();
    });
    // Navigasi ke halaman pesanan setelah berhasil membuat pesanan
    _onItemTapped(3);
  }

  void _addToCart(Coffee coffee, String size) {
    setState(() {
      final newItem = CartItem(coffee: coffee, size: size);
      // Pengecekan yang lebih aman
      final itemIndex = _cartItems.indexWhere((item) => item.coffee.name == coffee.name && item.size == size);

      if (itemIndex != -1) {
        _cartItems[itemIndex].quantity++;
      } else {
        _cartItems.add(newItem);
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${coffee.name} ($size) added to cart!'),
        duration: const Duration(seconds: 2),
        backgroundColor: Theme.of(context).primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        margin: const EdgeInsets.all(15),
      ),
    );
  }

  void _incrementCartItem(CartItem item) => setState(() => item.quantity++);
  void _decrementCartItem(CartItem item) {
    setState(() {
      if (item.quantity > 1) {
        item.quantity--;
      } else {
        _cartItems.remove(item);
      }
    });
  }

  void _onItemTapped(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    // --- PERBAIKAN UTAMA ADA DI SINI ---
    final List<Widget> pages = [
      HomePageContent(
        favoriteCoffees: _favoriteCoffees, // <-- Tambahkan parameter yang hilang ini
        onToggleFavorite: _toggleFavorite,
        onAddToCart: _addToCart,
      ),
      FavoritesScreen(
        favoriteCoffees: _favoriteCoffees,
        onToggleFavorite: _toggleFavorite,
      ),
      CartScreen(
        cartItems: _cartItems,
        onIncrement: _incrementCartItem,
        onDecrement: _decrementCartItem,
        onPlaceOrder: _placeOrder,
      ),
      MyOrdersScreen(allOrders: _allOrders),
      const ProfileScreen(), // Meneruskan daftar pesanan ke Profile
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: _buildBottomNavBar(isDarkMode),
    );
  }


  Widget _buildBottomNavBar(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -10),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavBarItem(0, Icons.home_rounded, 'Home', isDarkMode),
          _buildNavBarItem(1, Icons.favorite_rounded, 'Favorites', isDarkMode),
          _buildNavBarItem(2, Icons.shopping_cart_rounded, 'Cart', isDarkMode),
          _buildNavBarItem(3, Icons.receipt_rounded, 'Orders', isDarkMode),
          _buildNavBarItem(4, Icons.person_rounded, 'Profile', isDarkMode),
        ],
      ),
    );
  }

  Widget _buildNavBarItem(int index, IconData icon, String label, bool isDarkMode) {
    final isSelected = _selectedIndex == index;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(horizontal: isSelected ? 18 : 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.primaryColor.withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? theme.primaryColor : (isDarkMode ? Colors.white70 : Colors.grey[600]),
              size: isSelected ? 28 : 26,
            ),
            if (isSelected)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  label,
                  style: TextStyle(
                    color: theme.primaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
