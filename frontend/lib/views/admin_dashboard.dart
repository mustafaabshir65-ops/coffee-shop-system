import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/product_controller.dart';
import '../controllers/order_controller.dart';
import '../controllers/admin_dashboard_controller.dart';
import 'login_screen.dart';
import 'profile_drawer.dart';

class AdminDashboard extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();
  final ProductController productController = Get.put(ProductController());
  final OrderController orderController = Get.put(OrderController());
  final AdminDashboardController adminController = Get.put(
    AdminDashboardController(),
  );

  // Controllers for adding/editing product
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController stockController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  final TextEditingController imageController = TextEditingController();

  AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    // Fetch data
    orderController.fetchAllOrders();
    authController.fetchUsers();

    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
        bottom: TabBar(
          controller: adminController.tabController,
          tabs: [
            Tab(icon: Icon(Icons.coffee), text: 'Products'),
            Tab(icon: Icon(Icons.receipt), text: 'Orders'),
            Tab(icon: Icon(Icons.people), text: 'Users'),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              authController.logout();
              Get.offAll(() => LoginScreen());
            },
          ),
        ],
      ),
      drawer: ProfileDrawer(),
      body: TabBarView(
        controller: adminController.tabController,
        children: [
          // Products Tab
          Obx(() {
            if (productController.isLoading.value) {
              return Center(child: CircularProgressIndicator());
            }
            return Scaffold(
              floatingActionButton: FloatingActionButton(
                child: Icon(Icons.add),
                onPressed: () => _showProductDialog(context, null),
              ),
              body: ListView.builder(
                itemCount: productController.productList.length,
                itemBuilder: (ctx, i) {
                  final product = productController.productList[i];
                  return Card(
                    margin: EdgeInsets.all(8),
                    child: ListTile(
                      leading: Image.network(
                        product.imageUrl,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Icon(Icons.coffee),
                      ),
                      title: Text(product.name),
                      subtitle: Text(
                        product.stock < 0
                            ? 'Prepare for ${product.stock.abs()} orders'
                            : '\$${product.price} - Stock: ${product.stock}',
                        style: TextStyle(
                          color: product.stock < 0
                              ? Colors.orange
                              : Colors.grey,
                          fontWeight: product.stock < 0
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            onPressed: () =>
                                _showProductDialog(context, product),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () =>
                                productController.deleteProduct(product.id),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }),

          // Orders Tab
          Obx(() {
            if (orderController.isLoading.value) {
              return Center(child: CircularProgressIndicator());
            }
            orderController.fetchRevenueStats();
            return Column(
              children: [
                // Revenue Summary
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Card(
                          color: Colors.green[50],
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              children: [
                                Text(
                                  'Total Revenue',
                                  style: TextStyle(color: Colors.green),
                                ),
                                Text(
                                  '\$${orderController.totalRevenue.value.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Card(
                          color: Colors.orange[50],
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              children: [
                                Text(
                                  'Potential Revenue',
                                  style: TextStyle(color: Colors.orange),
                                ),
                                Text(
                                  '\$${orderController.potentialRevenue.value.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: orderController.allOrders.length,
                    itemBuilder: (ctx, i) {
                      final order = orderController.allOrders[i];
                      return Card(
                        margin: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListTile(
                                title: Text(
                                  'Order #${order['id']} - ${order['customer_name']}',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Date: ${order['order_date'].toString().substring(0, 10)}',
                                    ),
                                    if (order['location'] != null)
                                      Text('Location: ${order['location']}'),
                                    if (order['contact'] != null)
                                      Text('Contact: ${order['contact']}'),
                                    if (order['note'] != null &&
                                        order['note'].toString().isNotEmpty)
                                      Text(
                                        'Note: ${order['note']}',
                                        style: TextStyle(
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    if (order['cancel_reason'] != null)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: 4.0,
                                        ),
                                        child: Text(
                                          'Canceled by: ${order['canceled_by']} - ${order['cancel_reason']}',
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                trailing: Text(
                                  '\$${order['total_amount']}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              Divider(),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          'Status:',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        DropdownButton<String>(
                                          value:
                                              [
                                                'Pending',
                                                'Preparing',
                                                'Delivered',
                                                'Completed',
                                                'Canceled',
                                              ].contains(order['status'])
                                              ? order['status']
                                              : 'Pending',
                                          items:
                                              [
                                                'Pending',
                                                'Preparing',
                                                'Delivered',
                                                'Completed',
                                                'Canceled',
                                              ].map((String value) {
                                                return DropdownMenuItem<String>(
                                                  value: value,
                                                  child: Text(value),
                                                );
                                              }).toList(),
                                          onChanged:
                                              (order['status'] == 'Canceled' &&
                                                  order['canceled_by'] ==
                                                      'customer')
                                              ? null // Disabled if user canceled
                                              : (newStatus) {
                                                  if (newStatus == 'Canceled') {
                                                    _showAdminCancelDialog(
                                                      order['id'],
                                                    );
                                                  } else if (newStatus !=
                                                      null) {
                                                    orderController
                                                        .updateOrderStatus(
                                                          order['id'],
                                                          newStatus,
                                                        );
                                                  }
                                                },
                                        ),
                                      ],
                                    ),
                                    if (order['status'] != 'Canceled' &&
                                        order['status'] != 'Completed')
                                      TextButton.icon(
                                        onPressed: () =>
                                            _showAdminCancelDialog(order['id']),
                                        icon: Icon(
                                          Icons.cancel,
                                          color: Colors.red,
                                        ),
                                        label: Text(
                                          'Cancel',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }),

          // Users Tab
          Obx(() {
            if (authController.isLoading.value) {
              return Center(child: CircularProgressIndicator());
            }
            return ListView.builder(
              itemCount: authController.allUsers.length,
              itemBuilder: (ctx, i) {
                final user = authController.allUsers[i];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(user.name[0].toUpperCase()),
                    ),
                    title: Text(user.name),
                    subtitle: Text(user.email),
                    trailing: Text(
                      user.role.toUpperCase(),
                      style: TextStyle(
                        color: user.role == 'admin' ? Colors.red : Colors.green,
                      ),
                    ),
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }

  void _showAdminCancelDialog(int orderId) {
    final TextEditingController reasonController = TextEditingController();
    Get.defaultDialog(
      title: 'Admin Cancel Order',
      content: TextField(
        controller: reasonController,
        decoration: InputDecoration(labelText: 'Reason (e.g. Danger/Far)'),
        maxLines: 2,
      ),
      textConfirm: 'Confirm Cancel',
      textCancel: 'Exit',
      confirmTextColor: Colors.white,
      onConfirm: () {
        if (reasonController.text.isEmpty) {
          Get.snackbar('Error', 'Please provide a reason');
          return;
        }
        orderController.cancelOrder(orderId, reasonController.text, 'admin');
        Get.back();
      },
    );
  }

  void _showProductDialog(BuildContext context, dynamic product) {
    // Pre-fill if editing
    nameController.text = product?.name ?? '';
    priceController.text = product?.price.toString() ?? '';
    stockController.text = product?.stock.toString() ?? '';
    descController.text = product?.description ?? '';
    imageController.text = product?.imageUrl ?? '';

    Get.defaultDialog(
      title: product == null ? 'Add Product' : 'Edit Product',
      content: Column(
        children: [
          TextField(
            controller: nameController,
            decoration: InputDecoration(labelText: 'Name'),
          ),
          TextField(
            controller: priceController,
            decoration: InputDecoration(labelText: 'Price'),
            keyboardType: TextInputType.number,
          ),
          TextField(
            controller: stockController,
            decoration: InputDecoration(labelText: 'Stock'),
            keyboardType: TextInputType.number,
          ),
          TextField(
            controller: descController,
            decoration: InputDecoration(labelText: 'Description'),
          ),
          TextField(
            controller: imageController,
            decoration: InputDecoration(labelText: 'Image URL'),
          ),
        ],
      ),
      textConfirm: product == null ? 'Add' : 'Update',
      textCancel: 'Cancel',
      onConfirm: () {
        if (product == null) {
          productController.addProduct(
            nameController.text,
            double.tryParse(priceController.text) ?? 0.0,
            int.tryParse(stockController.text) ?? 0,
            descController.text,
            imageController.text,
          );
        } else {
          productController.updateProduct(
            product.id,
            nameController.text,
            double.tryParse(priceController.text) ?? 0.0,
            int.tryParse(stockController.text) ?? 0,
            descController.text,
            imageController.text,
          );
        }
      },
    );
  }
}
