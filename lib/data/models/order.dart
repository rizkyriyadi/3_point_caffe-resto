// lib/data/models/order.dart

import 'cart_item.dart';

enum OrderStatus { ongoing, completed, cancelled }

class Order {
  final String id;
  final List<CartItem> items;
  final String orderMethod;
  final double totalAmount;
  final DateTime orderDate;
  final OrderStatus status;

  Order({
    required this.id,
    required this.items,
    required this.orderMethod,
    required this.totalAmount,
    required this.orderDate,
    required this.status,
  });
}
