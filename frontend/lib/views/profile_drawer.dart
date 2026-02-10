import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/admin_dashboard_controller.dart';
import 'login_screen.dart';
import 'order_history_screen.dart';

class ProfileDrawer extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();

  ProfileDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(authController.user.value?.name ?? 'User'),
            accountEmail: Text(
              authController.user.value?.email ?? 'email@example.com',
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                (authController.user.value?.name ?? 'U')[0].toUpperCase(),
                style: TextStyle(fontSize: 40.0),
              ),
            ),
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Home'),
            onTap: () {
              Get.back(); // Close drawer
            },
          ),
          if (authController.user.value?.role != 'admin')
            ListTile(
              leading: Icon(Icons.history),
              title: Text('Order History'),
              onTap: () {
                Get.back(); // Close drawer
                Get.to(() => OrderHistoryScreen());
              },
            ),
          if (authController.user.value?.role == 'admin') ...[
            ListTile(
              leading: Icon(Icons.coffee),
              title: Text('Products'),
              onTap: () {
                Get.back();
                Get.find<AdminDashboardController>().changeTab(0);
              },
            ),
            ListTile(
              leading: Icon(Icons.receipt),
              title: Text('Orders'),
              onTap: () {
                Get.back();
                Get.find<AdminDashboardController>().changeTab(1);
              },
            ),
            ListTile(
              leading: Icon(Icons.people),
              title: Text('Users'),
              onTap: () {
                Get.back();
                Get.find<AdminDashboardController>().changeTab(2);
              },
            ),
          ],
          Divider(),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Logout'),
            onTap: () {
              authController.logout();
              Get.offAll(() => LoginScreen());
            },
          ),
        ],
      ),
    );
  }
}
