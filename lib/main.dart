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

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: initialRoute,
      getPages: [
        GetPage(name: '/login', page: () => LoginPage()),
        GetPage(name: '/home', page: () => HomePage()),
        GetPage(name: '/create-campaign', page: () => CreateCampaignPage()),
        GetPage(name: '/create-portfolio', page: () => CreatePortfolioPage()),
        GetPage(name: '/campaigns', page: () => CampaignsPage()),
        GetPage(name: '/portfolios', page: () => PortfoliosPage()),
        GetPage(name: '/analytics', page: () => AnalyticsPage()),
      ],
    );
  }
}