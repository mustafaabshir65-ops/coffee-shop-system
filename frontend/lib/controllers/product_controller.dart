import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../models/models.dart';

class ProductController extends GetxController {
  var isLoading = true.obs;
  var productList = <Product>[].obs;

  @override
  void onInit() {
    fetchProducts();
    super.onInit();
  }

  Future<void> fetchProducts() async {
    try {
      isLoading(true);
      final response = await http.get(
        Uri.parse('${Constants.baseUrl}/products'),
      );
      if (response.statusCode == 200) {
        var productsJson = jsonDecode(response.body) as List;
        productList.value = productsJson
            .map((p) => Product.fromJson(p))
            .toList();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch products: $e');
    } finally {
      isLoading(false);
    }
  }

  // Admin: Add Product
  Future<void> addProduct(
    String name,
    double price,
    int stock,
    String description,
    String imageUrl,
  ) async {
    try {
      isLoading(true);
      final response = await http.post(
        Uri.parse('${Constants.baseUrl}/products'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'price': price,
          'stock': stock,
          'description': description,
          'imageUrl': imageUrl,
        }),
      );
      if (response.statusCode == 201) {
        fetchProducts(); // Refresh list
        Get.back(); // Go back
        Get.snackbar('Success', 'Product added successfully');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to add product: $e');
    } finally {
      isLoading(false);
    }
  }

  // Admin: Update Product
  Future<void> updateProduct(
    int id,
    String name,
    double price,
    int stock,
    String description,
    String imageUrl,
  ) async {
    try {
      isLoading(true);
      final response = await http.put(
        Uri.parse('${Constants.baseUrl}/products/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'price': price,
          'stock': stock,
          'description': description,
          'imageUrl': imageUrl,
        }),
      );
      if (response.statusCode == 200) {
        fetchProducts(); // Refresh list
        Get.back(); // Close dialog
        Get.snackbar('Success', 'Product updated successfully');
      } else {
        Get.snackbar('Error', 'Failed to update: ${response.body}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update product: $e');
    } finally {
      isLoading(false);
    }
  }

  // Admin: Delete Product
  Future<void> deleteProduct(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('${Constants.baseUrl}/products/$id'),
      );
      if (response.statusCode == 200) {
        productList.removeWhere((p) => p.id == id);
        Get.snackbar('Success', 'Product deleted');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete product');
    }
  }
}
