import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
import '../../../data/models/order.dart';
import '../../widgets/empty_state_widget.dart';
import '../../widgets/order_card.dart';

class MyOrdersScreen extends StatelessWidget {
  final List<Order> allOrders;
  const MyOrdersScreen({super.key, required this.allOrders});

  @override
  Widget build(BuildContext context) {
    final ongoingOrders = allOrders
        .where((order) => order.status == OrderStatus.ongoing)
        .toList();
    final historyOrders = allOrders
        .where((order) => order.status != OrderStatus.ongoing)
        .toList();
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Pesanan Saya'),
          bottom: TabBar(
            indicatorColor: theme.colorScheme.primary,
            labelColor: theme.colorScheme.primary,
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(text: 'Sedang Berlangsung'),
              Tab(text: 'Riwayat'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ongoingOrders.isEmpty
                ? const EmptyStateWidget()
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: ongoingOrders.length,
                    itemBuilder: (context, index) =>
                        OrderCard(order: ongoingOrders[index]),
                  ),
            historyOrders.isEmpty
                ? const EmptyStateWidget()
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: historyOrders.length,
                    itemBuilder: (context, index) =>
                        OrderCard(order: historyOrders[index]),
                  ),
          ],
        ),
      ),
    );
  }
}
