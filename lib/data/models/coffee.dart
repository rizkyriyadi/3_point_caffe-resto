// lib/data/models/coffee.dart

class Coffee {
  final String name;
  final String image;
  final Map<String, double> prices;
  final double rating;
  final bool isBestSeller;
  final String description;

  Coffee({
    required this.name,
    required this.image,
    required this.prices,
    required this.rating,
    this.isBestSeller = false,
    required this.description,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Coffee && runtimeType == other.runtimeType && name == other.name;

  @override
  int get hashCode => name.hashCode;
}
