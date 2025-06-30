import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dio/dio.dart';
import 'payment_webview_screen.dart';
import '../../../data/models/cart_item.dart';
import '../main_screen.dart';
import 'package:coffe_shop_gpt/utils/app_theme.dart';

class OrderSummaryScreen extends StatefulWidget {
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
  State<OrderSummaryScreen> createState() => _OrderSummaryScreenState();
}

class _OrderSummaryScreenState extends State<OrderSummaryScreen> {
  bool _isProcessingPayment = false;

  // --- Kalkulasi Harga ---
  double get _subtotal => widget.cartItems.isNotEmpty ? widget.cartItems.map((item) => item.coffee.prices[item.size]! * item.quantity).reduce((a, b) => a + b) : 0.0;
  double get _deliveryFee => widget.orderMethod == 'Delivery' ? 2.00 : 0.00;
  double get _serviceFee => 0.50;
  double get _total => _subtotal + _deliveryFee + _serviceFee;

  // --- Alur Pembayaran dengan Xendit ---
  Future<void> _processPayment() async {
    if (_isProcessingPayment) return;
    setState(() { _isProcessingPayment = true; });

    final user = FirebaseAuth.instance.currentUser;

    try {
      final dio = Dio();
      final response = await dio.post(
        "https://bd08-103-136-57-231.ngrok-free.app/create-xendit-invoice", // GANTI DENGAN URL BACKEND ANDA
        data: {
          "order_id": 'KOPIKAP-${DateTime.now().millisecondsSinceEpoch}',
          "total": _total,
          "user_name": user?.displayName ?? "Guest",
          "user_email": user?.email ?? "guest@email.com",
        },
      );

      final String? invoiceUrl = response.data['invoice_url'];
      if (invoiceUrl == null) throw Exception("Gagal mendapatkan URL invoice.");

      // Buat pesanan di app dengan status "ongoing" SEBELUM ke halaman pembayaran
      widget.onPlaceOrder(widget.cartItems, widget.orderMethod, _total);

      // Luncurkan WebView dan tunggu hasilnya
      final paymentResult = await Navigator.of(context).push<bool>(
        MaterialPageRoute(builder: (_) => PaymentWebViewScreen(url: invoiceUrl)),
      );

      if (paymentResult == true && mounted) {
        _showDialogMessage(context, 'Menunggu Konfirmasi', 'Terima kasih! Kami akan segera mengupdate status pesanan Anda setelah pembayaran dikonfirmasi oleh Xendit.');
      } else if (paymentResult == false && mounted) {
        _showDialogMessage(context, 'Pembayaran Dibatalkan', 'Pembayaran dibatalkan atau tidak berhasil. Silakan coba lagi.', isSuccess: false);
      }

    } catch (e) {
      if (mounted) {
        _showDialogMessage(context, 'Error', "Tidak dapat membuat sesi pembayaran. Silakan coba lagi.", isSuccess: false);
      }
    } finally {
      if (mounted) setState(() { _isProcessingPayment = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Rincian Pesanan')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildOrderMethodCard(theme),
          const SizedBox(height: 24),
          Text('Ringkasan Item', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...widget.cartItems.map((item) => _buildCartItemTile(item)),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          Text('Rincian Biaya', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildCostRow('Subtotal', _subtotal),
          _buildCostRow('Biaya Layanan & Pajak', _serviceFee),
          if(_deliveryFee > 0) _buildCostRow('Biaya Pengiriman', _deliveryFee),
          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Pembayaran', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              Text(AppTheme.formatRupiah(_total), style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
            ],
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
          onPressed: _isProcessingPayment ? null : _processPayment,
          child: _isProcessingPayment
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text('Konfirmasi & Bayar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  // --- Helper Widgets & Functions ---

  Widget _buildOrderMethodCard(ThemeData theme) {
    final isDarkMode = theme.brightness == Brightness.dark;
    IconData icon;
    switch(widget.orderMethod) {
      case 'Delivery': icon = Icons.delivery_dining; break;
      case 'Take Away': icon = Icons.shopping_bag; break;
      default: icon = Icons.restaurant;
    }
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isDarkMode ? Colors.grey[850] : Colors.white,
      elevation: isDarkMode ? 1 : 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, color: theme.colorScheme.primary, size: 30),
            const SizedBox(width: 16),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Metode', style: TextStyle(color: Colors.grey)), Text(widget.orderMethod, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold))])
          ],
        ),
      ),
    );
  }

  Widget _buildCartItemTile(CartItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            // Ganti Image.asset menjadi CachedNetworkImage
            child: CachedNetworkImage(
              imageUrl: item.coffee.image,
              placeholder: (context, url) => const SizedBox(
                  width: 50,
                  height: 50,
                  child: Center(child: CircularProgressIndicator())),
              errorWidget: (context, url, error) => const Icon(Icons.error),
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
                Text(item.coffee.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('Size: ${item.size} • Qty: ${item.quantity}', style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          Text(AppTheme.formatRupiah((item.coffee.prices[item.size]! * item.quantity))),
        ],
      ),
    );
  }


  Widget _buildCostRow(String title, double amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(title, style: const TextStyle(color: Colors.grey)), Text(AppTheme.formatRupiah(amount))]),
    );
  }

  void _showDialogMessage(BuildContext context, String title, String message, {bool isSuccess = true}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(title, textAlign: TextAlign.center),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(isSuccess ? Icons.check_circle : Icons.error, color: isSuccess ? Colors.green : Colors.red, size: 60),
              const SizedBox(height: 16),
              Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                if (isSuccess) {
                  // Kembali ke halaman utama, menghapus semua halaman sebelumnya
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const MainScreen()),
                          (Route<dynamic> route) => false);
                }
              },
            ),
          ],
        );
      },
    );
  }
}