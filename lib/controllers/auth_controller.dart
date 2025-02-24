// import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_service.dart';
import '../controllers/campaign_controller.dart';
import '../controllers/portfolio_controller.dart';
// import '../views/home_page.dart';

class AuthController extends GetxController {
  var isLoading = false.obs;
  var token = ''.obs;
  var userId = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserSession();
  }

  void _initializeControllers() {
  if (!Get.isRegistered<CampaignController>()) {
    Get.put(CampaignController());
  }
  if (!Get.isRegistered<PortfolioController>()) {
    Get.put(PortfolioController());
  }
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
        _initializeControllers();
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
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedToken = prefs.getString('token');
      
      // Update the token value regardless of navigation
      if (savedToken != null && savedToken.isNotEmpty) {
        token.value = savedToken;
        _initializeControllers();
      }
      
      // Only attempt navigation if GetX is initialized
      if (Get.isRegistered<GetMaterialApp>()) {
        if (savedToken == null || savedToken.isEmpty) {
          if (Get.currentRoute != '/login') {
            Get.offAllNamed('/login');
          }
        } else if (Get.currentRoute != '/home') {
          Get.offAllNamed('/home');
        }
      }
    } catch (e) {
      print('Error in loadUserSession: $e');
    }
  }

  void logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    token.value = '';
    if (Get.isRegistered<CampaignController>()) {
  Get.delete<CampaignController>();
}
if (Get.isRegistered<PortfolioController>()) {
  Get.delete<PortfolioController>();
}
    Get.offAllNamed('/login');
  }
}
