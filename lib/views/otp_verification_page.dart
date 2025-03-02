import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class OtpVerificationPage extends StatelessWidget {
  final String email;
  final AuthController authController = Get.find<AuthController>();
  final TextEditingController otpController = TextEditingController();

  OtpVerificationPage({required this.email});

  @override
  Widget build(BuildContext context) {
    final isSignup = Get.arguments['isSignup'] ?? false;
    
    return Scaffold(
      appBar: AppBar(title: Text('OTP Verification')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isSignup 
                ? 'Verify your email address'
                : 'Enter the OTP sent to your email',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              email,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            SizedBox(height: 8),
            Obx(() => Text(
              'Remaining attempts: ${AuthController.maxOtpAttempts - authController.otpAttempts.value}',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            )),
            SizedBox(height: 20),
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: InputDecoration(
                labelText: 'Enter OTP',
                border: OutlineInputBorder(),
                counterText: '',
                helperText: isSignup 
                  ? 'Enter the OTP to verify your account'
                  : 'Enter the OTP to complete login',
              ),
              onChanged: (value) {
                if (value.length == 6) {
                  authController.verifyOtp(value);
                }
              },
            ),
            SizedBox(height: 20),
            Obx(() => authController.isLoading.value
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () {
                      if (otpController.text.length == 6) {
                        authController.verifyOtp(otpController.text);
                      } else {
                        Get.snackbar(
                          "Error",
                          "Please enter a 6-digit OTP",
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.red.withOpacity(0.1),
                          colorText: Colors.red,
                        );
                      }
                    },
                    child: Text('Verify OTP'),
                  )),
            SizedBox(height: 20),
            TextButton(
              onPressed: () => authController.resendOtp(),
              child: Text('Resend OTP'),
            ),
          ],
        ),
      ),
    );
  }
}
