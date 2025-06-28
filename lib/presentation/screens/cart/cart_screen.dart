import 'package:coffe_shop_gpt/utils/app_theme.dart';
import 'package:flutter/material.dart';
import '../../../data/models/cart_item.dart';
import '../orders/order_summary_screen.dart';
import '../../widgets/empty_state_widget.dart';

class CartScreen extends StatelessWidget {
  final List<CartItem> cartItems;
  final Function(CartItem) onIncrement;
  final Function(CartItem) onDecrement;
  final Function(List<CartItem>, String, double) onPlaceOrder;

  const CartScreen({
    super.key,
    required this.cartItems,
    required this.onIncrement,
    required this.onDecrement,
    required this.onPlaceOrder,
  });

  double get _totalPrice => cartItems.isEmpty ? 0 : cartItems.map((item) => item.coffee.prices[item.size]! * item.quantity).reduce((a, b) => a + b);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(title: const Text('My Cart')),
      body: cartItems.isEmpty
          ? const EmptyStateWidget()
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final item = cartItems[index];
                final price = item.coffee.prices[item.size]! * item.quantity;
                return Card(
                  color: isDarkMode ? Colors.grey[850] : Colors.white,
                  elevation: isDarkMode ? 1 : 2,
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    leading: CircleAvatar(backgroundImage: AssetImage(item.coffee.image)),
                    title: Text(item.coffee.name),
                    subtitle: Text('Size: ${item.size} | Price: ${AppTheme.formatRupiah(price)}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(icon: const Icon(Icons.remove), onPressed: () => onDecrement(item)),
                        Text('${item.quantity}', style: const TextStyle(fontSize: 16)),
                        IconButton(icon: const Icon(Icons.add), onPressed: () => onIncrement(item)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          _buildCheckoutSection(context),
        ],
      ),
    );
  }

  void _showOrderTypeSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => OrderTypeSelectionSheet(cartItems: cartItems, onPlaceOrder: onPlaceOrder),
    );
  }

  Widget _buildCheckoutSection(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[900] : Colors.grey[100],
        boxShadow: [if (!isDarkMode) BoxShadow(color: Colors.black.withOpacity(0.1), spreadRadius: 0, blurRadius: 10)],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Price', style: TextStyle(fontSize: 20, color: Colors.grey[600])),
              Text(AppTheme.formatRupiah(_totalPrice), style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 60), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
            onPressed: cartItems.isEmpty ? null : () => _showOrderTypeSheet(context),
            child: const Text('Checkout', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class OrderTypeSelectionSheet extends StatelessWidget {
  final List<CartItem> cartItems;
  final Function(List<CartItem>, String, double) onPlaceOrder;
  const OrderTypeSelectionSheet({super.key, required this.cartItems, required this.onPlaceOrder});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    void navigateToSummary(String method) {
      Navigator.pop(context); // Tutup bottom sheet
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => OrderSummaryScreen(
          cartItems: cartItems,
          orderMethod: method,
          onPlaceOrder: onPlaceOrder,
        ),
      ));
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Pilih Metode Pemesanan', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          ListTile(leading: Icon(Icons.delivery_dining, color: theme.colorScheme.primary), title: const Text('Delivery', style: TextStyle(fontWeight: FontWeight.bold)), onTap: () => navigateToSummary('Delivery')),
          ListTile(leading: Icon(Icons.shopping_bag, color: theme.colorScheme.primary), title: const Text('Take Away', style: TextStyle(fontWeight: FontWeight.bold)), onTap: () => navigateToSummary('Take Away')),
          ListTile(leading: Icon(Icons.restaurant, color: theme.colorScheme.primary), title: const Text('Dine In', style: TextStyle(fontWeight: FontWeight.bold)), onTap: () => navigateToSummary('Dine In')),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}