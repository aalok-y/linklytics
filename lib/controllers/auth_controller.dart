import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_service.dart';
import '../views/home_page.dart';

class AuthController extends GetxController {
  var isLoading = false.obs;
  var token = ''.obs;
  var userId = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserSession();
  }

  void signUp(String name, String email, String password) async {
    isLoading(true);
    final response = await ApiService.signUp(name, email, password);
    isLoading(false);

    if (response != null) {
      Get.snackbar("Success", "Account created. Please log in.");
      Get.offAllNamed('/login');
    } else {
      Get.snackbar("Error", "Sign-up failed. Try again.");
    }
  }

  void signIn(String email, String password) async {
    try {
      isLoading(true);
      final response = await ApiService.signIn(email, password);
      
      if (response != null) {
        token.value = response;
        await saveUserSession(response);
        Get.offAllNamed('/home');
      } else {
        Get.snackbar("Error", "Invalid credentials.");
      }
    } catch (e) {
      Get.snackbar("Error", "Login failed: ${e.toString()}");
    } finally {
      isLoading(false);
    }
  }

  Future<void> saveUserSession(String authToken) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', authToken);
      token.value = authToken; // Ensure token is set in memory
    } catch (e) {
      print('Error saving session: $e');
      throw Exception('Failed to save session');
    }
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final savedToken = prefs.getString('token');
    return savedToken != null && savedToken.isNotEmpty;
  }

  void loadUserSession() async {
    if (Get.currentRoute == '/login') return; // Don't redirect if already on login
    
    final prefs = await SharedPreferences.getInstance();
    final savedToken = prefs.getString('token');
    if (savedToken != null && savedToken.isNotEmpty) {
      token.value = savedToken;
      if (Get.currentRoute != '/home') {
        Get.offAllNamed('/home');
      }
    } else if (Get.currentRoute != '/login') {
      Get.offAllNamed('/login');
    }
  }

  void logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    token.value = '';
    Get.offAllNamed('/login');
  }
}
