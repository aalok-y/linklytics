// import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_service.dart';
import '../controllers/campaign_controller.dart';
import '../controllers/portfolio_controller.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'dart:math';

class AuthController extends GetxController {
  final _logger = Logger('AuthController');
  var isLoading = false.obs;
  var token = ''.obs;
  var userId = 0.obs;
  var generatedOtp = ''.obs;
  var userEmail = ''.obs;
  var userName = ''.obs;
  var otpAttempts = 0.obs;
  var isSignup = false.obs;
  static const maxOtpAttempts = 5;

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
    
    if (response != null) {
      isSignup.value = true;
      userEmail.value = email;
      await sendOtp(email);
      Get.toNamed('/otp-verification', arguments: {'email': email, 'isSignup': true});
    } else {
      Get.snackbar(
        "Error",
        "Sign-up failed. Try again.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
        duration: Duration(seconds: 3),
        margin: EdgeInsets.all(10),
        borderRadius: 8,
        isDismissible: true,
        overlayBlur: 0,
        overlayColor: Colors.transparent,
      );
    }
    isLoading(false);
  }

  void signIn(String email, String password) async {
    try {
      isLoading(true);
      _logger.info('Attempting sign in for email: $email');
      
      if (email.isEmpty || password.isEmpty) {
        Get.snackbar(
          "Error",
          "Email and password cannot be empty",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red,
          duration: Duration(seconds: 3),
          margin: EdgeInsets.all(10),
          borderRadius: 8,
          isDismissible: true,
          overlayBlur: 0,
          overlayColor: Colors.transparent,
        );
        return;
      }
      
      final response = await ApiService.signIn(email, password);
      _logger.info('Sign in response received');
      
      if (response != null && response['token'] != null) {
        userEmail.value = email;
        userName.value = response['user'] ?? email.split('@')[0]; // Get name from response
        String tempToken = response['token'];
        
        // Now initiate OTP verification
        await sendOtp(email);
        Get.toNamed('/otp-verification', arguments: {
          'email': email,
          'token': tempToken,
          'name': userName.value
        });
      } else {
        Get.snackbar(
          "Error",
          "Invalid credentials or User does not exist",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red,
          duration: Duration(seconds: 3),
          margin: EdgeInsets.all(10),
          borderRadius: 8,
          isDismissible: true,
          overlayBlur: 0,
          overlayColor: Colors.transparent,
        );
      }
    } catch (e) {
      _logger.severe('Sign in error: $e');
      Get.snackbar(
        "Error",
        "Login failed: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
        duration: Duration(seconds: 3),
        margin: EdgeInsets.all(10),
        borderRadius: 8,
        isDismissible: true,
        overlayBlur: 0,
        overlayColor: Colors.transparent,
      );
    } finally {
      isLoading(false);
    }
  }

  String generateOtp() {
    Random random = Random();
    String otp = '';
    for (int i = 0; i < 6; i++) {
      otp += random.nextInt(10).toString();
    }
    return otp;
  }

  Future<void> sendOtp(String email) async {
    try {
      String otp = generateOtp();
      generatedOtp.value = otp;
      
      final response = await ApiService.get('/sendotp/$email/$otp');
      if (response == null) {
        throw Exception('Failed to send OTP');
      }
      
      Get.snackbar(
        "Success",
        "OTP sent to your email",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green,
        duration: Duration(seconds: 3),
        margin: EdgeInsets.all(10),
        borderRadius: 8,
        isDismissible: true,
        overlayBlur: 0,
        overlayColor: Colors.transparent,
      );
    } catch (e) {
      _logger.severe('Send OTP error: $e');
      Get.snackbar(
        "Error",
        "Failed to send OTP: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
        duration: Duration(seconds: 3),
        margin: EdgeInsets.all(10),
        borderRadius: 8,
        isDismissible: true,
        overlayBlur: 0,
        overlayColor: Colors.transparent,
      );
    }
  }

  void verifyOtp(String enteredOtp) async {
    try {
      isLoading(true);
      final arguments = Get.arguments;
      final isSignupFlow = arguments['isSignup'] ?? false;

      if (enteredOtp == generatedOtp.value) {
        if (isSignupFlow) {
          // Verify OTP with server for signup
          final verifyResponse = await ApiService.verifyOtp(
            userEmail.value,
            generatedOtp.value,
            enteredOtp
          );

          if (verifyResponse != null) {
            if (verifyResponse['success']) {
              Get.snackbar(
                "Success",
                "Account verified successfully. Please log in.",
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green.withOpacity(0.1),
                colorText: Colors.green,
                duration: Duration(seconds: 3),
                margin: EdgeInsets.all(10),
                borderRadius: 8,
                isDismissible: true,
                overlayBlur: 0,
                overlayColor: Colors.transparent,
              );
              Get.offAllNamed('/login');
            } else {
              handleOtpError(verifyResponse['message'] ?? "Verification failed");
            }
          } else {
            handleOtpError("Network error during verification");
          }
        } else {
          // Login flow OTP verification
          final token = arguments['token'];
          final name = arguments['name'];
          if (token != null) {
            // Ensure user name is set
            userName.value = name ?? userEmail.value.split('@')[0];
            await saveUserSession(token);
            _initializeControllers();
            Get.offAllNamed('/home');
          }
        }
      } else {
        otpAttempts.value++;
        if (otpAttempts.value >= maxOtpAttempts) {
          Get.snackbar(
            "Error",
            "Maximum OTP attempts reached. Please try again.",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.withOpacity(0.1),
            colorText: Colors.red,
            duration: Duration(seconds: 3),
            margin: EdgeInsets.all(10),
            borderRadius: 8,
            isDismissible: true,
            overlayBlur: 0,
            overlayColor: Colors.transparent,
          );
          otpAttempts.value = 0;
          Get.offAllNamed(isSignupFlow ? '/signup' : '/login');
        } else {
          Get.snackbar(
            "Error",
            "Invalid OTP. ${maxOtpAttempts - otpAttempts.value} attempts remaining",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.withOpacity(0.1),
            colorText: Colors.red,
            duration: Duration(seconds: 3),
            margin: EdgeInsets.all(10),
            borderRadius: 8,
            isDismissible: true,
            overlayBlur: 0,
            overlayColor: Colors.transparent,
          );
        }
      }
    } catch (e) {
      _logger.severe('OTP verification error: $e');
      handleOtpError(e.toString());
    } finally {
      isLoading(false);
    }
  }

  void handleOtpError(String message) {
    Get.snackbar(
      "Error",
      "Verification failed: $message",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.withOpacity(0.1),
      colorText: Colors.red,
      duration: Duration(seconds: 3),
      margin: EdgeInsets.all(10),
      borderRadius: 8,
      isDismissible: true,
      overlayBlur: 0,
      overlayColor: Colors.transparent,
    );
  }

  void resendOtp() async {
    if (userEmail.value.isNotEmpty) {
      otpAttempts.value = 0;
      await sendOtp(userEmail.value);
    }
  }

  Future<void> saveUserSession(String authToken) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', authToken);
      await prefs.setString('email', userEmail.value);
      await prefs.setString('name', userName.value);
      token.value = authToken;
    } catch (e) {
      print('Error saving session: $e');
      throw Exception('Failed to save session');
    }
  }

  void loadUserSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedToken = prefs.getString('token');
      final savedEmail = prefs.getString('email');
      final savedName = prefs.getString('name');
      
      if (savedToken != null && savedToken.isNotEmpty) {
        token.value = savedToken;
        userEmail.value = savedEmail ?? '';
        userName.value = savedName ?? '';
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
    await prefs.remove('email');
    await prefs.remove('name');
    token.value = '';
    userEmail.value = '';
    userName.value = '';
    if (Get.isRegistered<CampaignController>()) {
      Get.delete<CampaignController>();
    }
    if (Get.isRegistered<PortfolioController>()) {
      Get.delete<PortfolioController>();
    }
    Get.offAllNamed('/login');
  }
}
