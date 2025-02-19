import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class HomePage extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Home")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("User Token:", style: TextStyle(fontSize: 16)),
            Text(authController.token.value, style: TextStyle(fontSize: 14, color: Colors.blue)),
            SizedBox(height: 20),
            ElevatedButton(onPressed: authController.logout, child: Text("Logout"))
          ],
        ),
      ),
    );
  }
}
