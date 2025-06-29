// lib/data/models/coffee.dart

class Coffee {
  final String name;
  final String? subtitle;
  final String image;
  final Map<String, double> prices;
  final double rating;
  final bool isBestSeller;
  final String description;
  final String category;

  Coffee({
    required this.name,
    this.subtitle,
    required this.image,
    required this.prices,
    required this.rating,
    this.isBestSeller = false,
    required this.description,
    required this.category,
  });

  // --- PERBAIKAN UTAMA ADA DI SINI ---
  factory Coffee.fromFirestore(Map<String, dynamic> data) {
    // Ambil map 'prices' dari Firestore
    final rawPrices = data['prices'] as Map<String, dynamic>? ?? {};

    // Konversi setiap nilai di dalam map menjadi double, apapun tipe angka aslinya
    final Map<String, double> convertedPrices = rawPrices.map(
          (key, value) => MapEntry(key, (value as num).toDouble()),
    );

    return Coffee(
      name: data['name'] ?? 'No Name',
      subtitle: data['subtitle'],
      image: data['image'] ?? '',
      description: data['description'] ?? '',
      isBestSeller: data['isBestSeller'] ?? false,
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      prices: convertedPrices, // Gunakan map yang sudah dikonversi
      category: data['category'] ?? 'uncategorized',
    );
  }
  // --- AKHIR DARI PERBAIKAN ---

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Coffee && runtimeType == other.runtimeType && name == other.name;

  @override
  int get hashCode => name.hashCode;
}