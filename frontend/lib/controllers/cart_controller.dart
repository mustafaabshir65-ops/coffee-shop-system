import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../models/models.dart';
import 'auth_controller.dart';

class CartController extends GetxController {
  var cartItems = <CartItem>[].obs;
  var isLoading = false.obs;

  double get totalAmount => cartItems.fold(0, (sum, item) => sum + item.total);

  void addToCart(Product product) {
    var existingItem = cartItems.firstWhereOrNull(
      (item) => item.product.id == product.id,
    );
    if (existingItem != null) {
      existingItem.quantity++;
      cartItems.refresh();
    } else {
      cartItems.add(CartItem(product: product));
    }
    Get.snackbar(
      'Added',
      '${product.name} added to cart',
      duration: Duration(seconds: 1),
    );
  }

  void removeFromCart(CartItem item) {
    if (item.quantity > 1) {
      item.quantity--;
      cartItems.refresh();
    } else {
      cartItems.remove(item);
    }
  }

  void clearCart() {
    cartItems.clear();
  }

  Future<void> placeOrder({
    required String location,
    required String contact,
    required String note,
  }) async {
    final AuthController authController = Get.find<AuthController>();
    if (cartItems.isEmpty) return;

    try {
      isLoading(true);
      final orderData = {
        'userId': authController.user.value!.id,
        'totalAmount': totalAmount,
        'items': cartItems.map((e) => e.toJson()).toList(),
        'location': location,
        'contact': contact,
        'note': note,
      };

      final response = await http.post(
        Uri.parse('${Constants.baseUrl}/orders'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(orderData),
      );

      if (response.statusCode == 201) {
        clearCart();
        Get.defaultDialog(
          title: "Order Success",
          middleText:
              "Thank you for your order! Your coffee is being prepared.",
          textConfirm: "OK",
          confirmTextColor: Colors.white,
          onConfirm: () {
            Get.back(); // Close dialog
            Get.back(); // Go back to Home
          },
        );
      } else {
        Get.snackbar('Error', 'Failed to place order');
      }
    } catch (e) {
      Get.snackbar('Error', 'Something went wrong: $e');
    } finally {
      isLoading(false);
    }
  }
}
