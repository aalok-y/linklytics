import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'views/login_page.dart';
import 'views/signup_page.dart';
import 'views/home_page.dart';
import 'views/campaign_page.dart';
import 'views/analytics_page.dart';
import 'views/create_campaign_page.dart';
import 'views/create_portfolio_page.dart';
import 'views/campaigns_page.dart';
import 'views/portfolios_page.dart';
import 'controllers/auth_controller.dart';
import 'controllers/campaign_controller.dart';
import 'controllers/portfolio_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final savedToken = prefs.getString('token');
  runApp(MyApp(initialRoute: savedToken != null && savedToken.isNotEmpty ? '/home' : '/login'));
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  MyApp({required this.initialRoute});
  
  final authController = Get.put(AuthController());
  final campaignController = Get.put(CampaignController());
  final portfolioController = Get.put(PortfolioController());

  Future<bool> _onWillPop() async {
    if (Get.currentRoute == '/home' || Get.currentRoute == '/login') {
      return true; // Allow back button to close app on home or login screen
    } else {
      Get.back(); // Go back to previous screen
      return false; // Don't close the app
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: initialRoute,
        defaultTransition: Transition.fadeIn,
        getPages: [
          GetPage(
            name: '/login', 
            page: () => LoginPage(),
            transition: Transition.fadeIn
          ),
          GetPage(
            name: '/signup', 
            page: () => SignUpPage(),
            transition: Transition.rightToLeft
          ),
          GetPage(
            name: '/home', 
            page: () => HomePage(),
            transition: Transition.fadeIn
          ),
          GetPage(
            name: '/create-campaign', 
            page: () => CreateCampaignPage(),
            transition: Transition.rightToLeft
          ),
          GetPage(
            name: '/create-portfolio', 
            page: () => CreatePortfolioPage(),
            transition: Transition.rightToLeft
          ),
          GetPage(
            name: '/campaigns', 
            page: () => CampaignsPage(),
            transition: Transition.rightToLeft
          ),
          GetPage(
            name: '/portfolios', 
            page: () => PortfoliosPage(),
            transition: Transition.rightToLeft
          ),
          GetPage(
            name: '/analytics', 
            page: () => AnalyticsPage(),
            transition: Transition.rightToLeft
          ),
        ],
      ),
    );
  }
}