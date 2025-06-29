import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/coffee.dart';

class ProductService {
  final CollectionReference _productCollection =
  FirebaseFirestore.instance.collection('products');

  Future<List<Coffee>> getProducts() async {
    try {
      QuerySnapshot snapshot = await _productCollection.get();

      if (snapshot.docs.isEmpty) {
        return [];
      }

      return snapshot.docs.map((doc) {
        return Coffee.fromFirestore(doc.data() as Map<String, dynamic>);
      }).toList();

    } catch (e) {
      print("Error fetching products: $e");
      // Di aplikasi nyata, ini bisa dilaporkan ke layanan logging
      return [];
    }
  }
}