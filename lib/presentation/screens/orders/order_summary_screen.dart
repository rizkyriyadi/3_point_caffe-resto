import 'package:flutter/material.dart';
import '../../../data/models/cart_item.dart';
import '../../screens/orders/payment_gateway_screen.dart';
import '../main_screen.dart'; // Untuk navigasi kembali ke home

class OrderSummaryScreen extends StatelessWidget {
  final List<CartItem> cartItems;
  final String orderMethod;
  final Function(List<CartItem>, String, double) onPlaceOrder;

  const OrderSummaryScreen({
    super.key,
    required this.cartItems,
    required this.orderMethod,
    required this.onPlaceOrder,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    // --- Kalkulasi Harga ---
    final double subtotal = cartItems
        .map((item) => item.coffee.prices[item.size]! * item.quantity)
        .reduce((a, b) => a + b);
    final double deliveryFee = orderMethod == 'Delivery' ? 2.00 : 0.00;
    final double serviceFee = 0.50;
    final double total = subtotal + deliveryFee + serviceFee;

    void _navigateToPaymentGateway(BuildContext context) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PaymentGatewayScreen(
            totalAmount: total,
            onPaymentSuccess: () {
              // Panggil fungsi utama untuk membuat pesanan & membersihkan keranjang
              onPlaceOrder(cartItems, orderMethod, total);
              // Tampilkan dialog sukses
              _showThankYouDialog(context);
            },
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Rincian Pesanan')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Bagian Metode Pemesanan
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            color: isDarkMode ? Colors.grey[850] : Colors.white,
            elevation: isDarkMode ? 1 : 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(
                    orderMethod == 'Delivery'
                        ? Icons.delivery_dining
                        : (orderMethod == 'Take Away'
                              ? Icons.shopping_bag
                              : Icons.restaurant),
                    color: theme.colorScheme.primary,
                    size: 30,
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Metode',
                        style: TextStyle(color: Colors.grey),
                      ),
                      Text(
                        orderMethod,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Bagian Daftar Item
          Text(
            'Ringkasan Item',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ...cartItems
              .map(
                (item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          item.coffee.image,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.coffee.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Size: ${item.size} • Qty: ${item.quantity}',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '\$${(item.coffee.prices[item.size]! * item.quantity).toStringAsFixed(2)}',
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),

          // Bagian Rincian Biaya
          Text(
            'Rincian Biaya',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildCostRow('Subtotal', subtotal),
          _buildCostRow('Biaya Layanan & Pajak', serviceFee),
          if (deliveryFee > 0) _buildCostRow('Biaya Pengiriman', deliveryFee),
          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Pembayaran',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '\$${total.toStringAsFixed(2)}',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          onPressed: () => _navigateToPaymentGateway(context),
          child: const Text(
            'Konfirmasi & Bayar',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  void _showThankYouDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Pembayaran Berhasil!',
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 60),
              const SizedBox(height: 16),
              const Text(
                'Terima kasih! Pesanan Anda sedang diproses.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const MainScreen()),
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildCostRow(String title, double amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.grey)),
          Text('\$${amount.toStringAsFixed(2)}'),
        ],
      ),
    );
  }
}
