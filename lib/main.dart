
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'views/login_page.dart';
import 'views/signup_page.dart';
import 'views/home_page.dart';
import 'views/campaign_page.dart';
import 'controllers/auth_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferences.getInstance();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final authController = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      getPages: [
        GetPage(name: '/login', page: () => LoginPage()),
        GetPage(name: '/signup', page: () => SignUpPage()),
        GetPage(name: '/home', page: () => HomePage()),
        GetPage(name: '/campaign', page: () => CampaignPage()),
      ],
    );
  }
}