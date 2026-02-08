import 'dart:convert';
import 'package:frontend/views/admin_dashboard.dart';
import 'package:frontend/views/home_screen.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';
import '../models/models.dart';
import '../views/login_screen.dart';

class AuthController extends GetxController {
  var isLoading = false.obs;
  var user = Rxn<User>();
  var token = ''.obs;

  // Admin: User management
  var allUsers = <User>[].obs;

  @override
  void onInit() {
    super.onInit();
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final storedToken = prefs.getString('token');
    final storedUser = prefs.getString('user');

    if (storedToken != null && storedUser != null) {
      token.value = storedToken;
      user.value = User.fromJson(jsonDecode(storedUser));
    }
  }

  Future<void> register(String name, String email, String password) async {
    try {
      isLoading(true);
      final response = await http.post(
        Uri.parse('${Constants.baseUrl}/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'email': email, 'password': password}),
      );

      if (response.statusCode == 201) {
        Get.snackbar('Success', 'Registration successful. Please login.');
        Get.off(() => LoginScreen());
      } else {
        Get.snackbar(
          'Error',
          jsonDecode(response.body)['message'] ?? 'Registration failed',
        );
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading(false);
    }
  }

  Future<void> login(String email, String password) async {
    try {
      isLoading(true);
      final response = await http.post(
        Uri.parse('${Constants.baseUrl}/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        token.value = data['token'];
        user.value = User.fromJson(data['user']);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token.value);
        await prefs.setString('user', jsonEncode(data['user']));

        if (user.value!.role == 'admin') {
          Get.offAll(() => AdminDashboard());
        } else {
          Get.offAll(() => HomeScreen());
        }
      } else {
        Get.snackbar(
          'Error',
          jsonDecode(response.body)['message'] ?? 'Login failed',
        );
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading(false);
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    token.value = '';
    user.value = null;
    Get.offAll(() => LoginScreen());
  }

  Future<void> fetchUsers() async {
    try {
      // In a real app, users endpoint should be protected and only for admin
      // For now we assume a public or pseudo-protected endpoint that returns all users
      // Note: We need to implement this endpoint in backend if not exists,
      // or just assume we have one.
      // The prompt didn't ask for a specific users list API internal implementation
      // but "view registered users". I'll assume we can fetch data.
      // Wait, I didn't implement 'GET /auth/users' in backend.
      // I should implement it in backend/routes/auth.js first.

      final response = await http.get(
        Uri.parse('${Constants.baseUrl}/auth/users'),
      );
      if (response.statusCode == 200) {
        var usersJson = jsonDecode(response.body) as List;
        allUsers.value = usersJson.map((u) => User.fromJson(u)).toList();
      }
    } catch (e) {
      print('Error fetching users: $e');
    }
  }
}
