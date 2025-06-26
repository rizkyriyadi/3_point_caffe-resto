// lib/presentation/screens/main_screen.dart

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

  // --- State Management Sederhana ---
  // Data ini akan di-pass ke halaman-halaman yang membutuhkannya.
  // Untuk aplikasi yang lebih besar, ini bisa diganti dengan state management yang lebih canggih (BLoC, Riverpod, dll).
  final List<Coffee> _favoriteCoffees = [];
  final List<CartItem> _cartItems = [];
  final List<Order> _allOrders = [];

  // --- Functions to Modify State ---
  void _toggleFavorite(Coffee coffee) {
    setState(() {
      _favoriteCoffees.contains(coffee)
          ? _favoriteCoffees.remove(coffee)
          : _favoriteCoffees.add(coffee);
    });
  }

  void _placeOrder(List<CartItem> items, String method, double total) {
    setState(() {
      final newOrder = Order(
        id: 'ID-${DateTime.now().millisecondsSinceEpoch}',
        items: List<CartItem>.from(items), // Buat salinan list
        orderMethod: method,
        totalAmount: total,
        orderDate: DateTime.now(),
        status: OrderStatus.ongoing,
      );
      _allOrders.insert(0, newOrder); // Tambah ke awal list
      _cartItems.clear(); // Kosongkan keranjang setelah order
    });
  }

  void _addToCart(Coffee coffee, String size) {
    setState(() {
      final newItem = CartItem(coffee: coffee, size: size);
      final itemIndex = _cartItems.indexOf(newItem);
      if (itemIndex != -1) {
        _cartItems[itemIndex].quantity++;
      } else {
        _cartItems.add(newItem);
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${coffee.name} ($size) added to cart!'),
        duration: const Duration(seconds: 1),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }

  void _incrementCartItem(CartItem item) => setState(() => item.quantity++);
  void _decrementCartItem(CartItem item) => setState(
    () => item.quantity > 1 ? item.quantity-- : _cartItems.remove(item),
  );

  void _onItemTapped(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    // List halaman yang akan ditampilkan berdasarkan tab yang dipilih.
    // Kita passing state dan fungsi yang relevan ke setiap halaman.
    final List<Widget> pages = [
      HomePageContent(
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
      ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Orders',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
        selectedItemColor: isDarkMode
            ? Colors.brown[300]
            : Theme.of(context).primaryColor,
        unselectedItemColor: isDarkMode ? Colors.white54 : Colors.grey,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 10),
      ),
    );
  }
}
