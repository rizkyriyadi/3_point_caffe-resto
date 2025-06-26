// lib/data/models/cart_item.dart

import 'coffee.dart';

class CartItem {
  final Coffee coffee;
  final String size;
  int quantity;

  CartItem({required this.coffee, required this.size, this.quantity = 1});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartItem &&
          runtimeType == other.runtimeType &&
          coffee == other.coffee &&
          size == other.size;

  @override
  int get hashCode => coffee.hashCode ^ size.hashCode;
}
