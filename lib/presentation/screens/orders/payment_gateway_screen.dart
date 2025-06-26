import 'package:flutter/material.dart';

class PaymentGatewayScreen extends StatefulWidget {
  final double totalAmount;
  final VoidCallback onPaymentSuccess;

  const PaymentGatewayScreen({
    super.key,
    required this.totalAmount,
    required this.onPaymentSuccess,
  });

  @override
  State<PaymentGatewayScreen> createState() => _PaymentGatewayScreenState();
}

class _PaymentGatewayScreenState extends State<PaymentGatewayScreen> {
  bool _isLoading = false;

  void _simulatePayment(BuildContext context) {
    setState(() => _isLoading = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pop(context); // Tutup halaman payment gateway ini
        widget.onPaymentSuccess(); // Panggil callback sukses
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Secure Payment'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40.0),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              'Total: \$${widget.totalAmount.toStringAsFixed(2)}',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSectionHeader('E-Wallet'),
              _buildPaymentTile('GoPay', 'https://i.imgur.com/t4jB3sY.png'),
              _buildPaymentTile('OVO', 'https://i.imgur.com/r3x1g2A.png'),
              const Divider(height: 32),
              _buildSectionHeader('Bank Transfer / Virtual Account'),
              _buildPaymentTile(
                'BCA Virtual Account',
                'https://i.imgur.com/v8MV30d.png',
              ),
              _buildPaymentTile(
                'Mandiri Virtual Account',
                'https://i.imgur.com/5b8g2wv.png',
              ),
              const Divider(height: 32),
              _buildSectionHeader('Credit / Debit Card'),
              _buildPaymentTile(
                'Visa / Mastercard',
                'https://i.imgur.com/CsS4yWc.png',
              ),
            ],
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: Colors.grey,
      ),
    ),
  );

  Widget _buildPaymentTile(String title, String logoUrl) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Image.network(
          logoUrl,
          height: 24,
          width: 40,
          fit: BoxFit.contain,
        ),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => _simulatePayment(context),
      ),
    );
  }
}
