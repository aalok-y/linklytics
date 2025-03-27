import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatelessWidget {
  final AuthController authController = Get.put(AuthController());
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final RxInt _tapCount = 0.obs;
  static const String _otpBypassKey = 'otp_bypass_enabled';

  Future<void> _showSecretPage(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final isOtpBypassEnabled = prefs.getBool(_otpBypassKey) ?? false;
    final RxBool otpBypassEnabled = isOtpBypassEnabled.obs;

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Secret Settings'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Bypass OTP Validation'),
                  Obx(() => Switch(
                    value: otpBypassEnabled.value,
                    onChanged: (bool value) async {
                      otpBypassEnabled.value = value;
                      await prefs.setBool(_otpBypassKey, value);
                    },
                  )),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleTap(BuildContext context) async {
    _tapCount.value++;
    if (_tapCount.value == 3) {
      _tapCount.value = 0;
      await _showSecretPage(context);
    }
  }

  Future<void> _showForgotPasswordDialog(BuildContext context) async {
    final TextEditingController resetEmailController = TextEditingController();
    final RxBool isLoading = false.obs;

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Reset Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Enter your email to receive a password reset link'),
              SizedBox(height: 10),
              TextField(
                controller: resetEmailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            Obx(() => isLoading.value
                ? CircularProgressIndicator()
                : TextButton(
                    onPressed: () async {
                      if (resetEmailController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Please enter your email')),
                        );
                        return;
                      }

                      isLoading.value = true;
                      try {
                        final response = await http.get(
                          Uri.parse('https://linklytics-backend.onrender.com/api/v1/auth/send-reset-password-link/${resetEmailController.text.trim()}'),
                        );

                        if (response.statusCode == 200) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Password reset link sent successfully')),
                          );
                        } else {
                          final error = json.decode(response.body);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(error['message'] ?? 'Failed to send reset link')),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('An error occurred')),
                        );
                      } finally {
                        isLoading.value = false;
                      }
                    },
                    child: Text('Send Reset Link'),
                  ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login"),
        actions: [
          SizedBox(
            width: 60,
            height: 60,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _handleTap(context),
                child: Container(),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            SizedBox(height: 20),
            Obx(() => authController.isLoading.value
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      final isOtpBypassEnabled = prefs.getBool(_otpBypassKey) ?? false;
                      authController.signIn(
                        emailController.text,
                        passwordController.text,
                        bypassOtp: isOtpBypassEnabled,
                      );
                    },
                    child: Text("Login"),
                  )),
            SizedBox(height: 10),
            TextButton(
              onPressed: () => Get.toNamed('/signup'),
              child: Text("Don't have an account? Sign Up"),
            ),
            TextButton(
              onPressed: () => _showForgotPasswordDialog(context),
              child: Text("Forgot Password?"),
            ),
          ],
        ),
      ),
    );
  }
}
