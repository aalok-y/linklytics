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
    isLoading(true);
    final response = await ApiService.signIn(email, password);
    isLoading(false);

    if (response != null) {
      token.value = response;
      saveUserSession(response);
      Get.offAllNamed('/home');
    } else {
      Get.snackbar("Error", "Invalid credentials.");
    }
  }

  void saveUserSession(String authToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', authToken);
  }

  void loadUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    final savedToken = prefs.getString('token');
    if (savedToken != null) {
      token.value = savedToken;
      Get.offAllNamed('/home');
    }
  }

  void logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    token.value = '';
    Get.offAllNamed('/login');
  }
}
