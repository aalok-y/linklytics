import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginPage extends StatelessWidget {
  final AuthController authController = Get.put(AuthController());
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

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
      appBar: AppBar(title: Text("Login")),
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
                    onPressed: () => authController.signIn(
                      emailController.text,
                      passwordController.text,
                    ),
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
