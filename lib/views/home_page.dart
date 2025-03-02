import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/campaign_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'analytics_page.dart';
import 'create_portfolio_page.dart';
import 'create_campaign_page.dart';
import 'my_links_page.dart';

class HomePage extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();
  final CampaignController campaignController = Get.find<CampaignController>();
  final homeController = Get.put(HomeController());
  DateTime? lastBackPressTime;

  HomePage({super.key});

  void navigateToCreatePortfolio() {
    Get.to(() => CreatePortfolioPage());
  }

  void navigateToCreateCampaign() {
    Get.to(() => CreateCampaignPage());
  }

  String _getPageTitle() {
    switch (homeController.currentIndex.value) {
      case 0:
        return 'Create Link';
      case 1:
        return 'My Links';
      case 2:
        return 'Analytics';
      default:
        return 'Linklytics';
    }
  }

  Widget _buildDrawerItem(IconData icon, String title, int index) {
    return Obx(() => ListTile(
      leading: Icon(
        icon,
        color: homeController.currentIndex.value == index ? Theme.of(Get.context!).primaryColor : Colors.grey,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: homeController.currentIndex.value == index ? Theme.of(Get.context!).primaryColor : Colors.black87,
          fontWeight: homeController.currentIndex.value == index ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: homeController.currentIndex.value == index,
      selectedTileColor: Theme.of(Get.context!).primaryColor.withOpacity(0.1),
      onTap: () {
        homeController.setIndex(index);
        // Close the drawer if we're on a small screen
        if (Navigator.canPop(Get.context!)) {
          Navigator.pop(Get.context!);
        }
      },
    ));
  }

  Widget _buildNavigationDrawer() {
    return Drawer(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(Get.context!).primaryColor,
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Linklytics',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Link Management Made Easy',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 24),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 20,
                          child: Obx(() => Text(
                            authController.userName.value.isNotEmpty 
                              ? authController.userName.value[0].toUpperCase()
                              : '?',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(Get.context!).primaryColor,
                            ),
                          )),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Obx(() => Text(
                                authController.userName.value,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              )),
                              SizedBox(height: 2),
                              Obx(() => Text(
                                authController.userEmail.value,
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              )),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(Icons.add_link, 'Create Link', 0),
                _buildDrawerItem(Icons.link, 'My Links', 1),
                _buildDrawerItem(Icons.analytics, 'Analytics', 2),
                Divider(),
                ListTile(
                  leading: Icon(Icons.logout, color: Colors.red),
                  title: Text('Logout', style: TextStyle(color: Colors.red)),
                  onTap: () async {
                    if (Navigator.canPop(Get.context!)) {
                      Navigator.pop(Get.context!);
                    }
                    authController.logout();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> onWillPop() async {
    final now = DateTime.now();
    if (lastBackPressTime == null || 
        now.difference(lastBackPressTime!) > const Duration(seconds: 2)) {
      lastBackPressTime = now;
      Get.snackbar(
        "Exit",
        "Press back again to exit",
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final bool isSmallScreen = MediaQuery.of(context).size.width < 600;

    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Obx(() => Text(_getPageTitle())),
        ),
        drawer: isSmallScreen ? _buildNavigationDrawer() : null,
        body: Row(
          children: [
            if (!isSmallScreen) 
              SizedBox(
                width: 250,
                child: _buildNavigationDrawer(),
              ),
            Expanded(
              child: Obx(() {
                switch (homeController.currentIndex.value) {
                  case 0:
                    return SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Wrap(
                                  spacing: 16.0,
                                  runSpacing: 16.0,
                                  alignment: WrapAlignment.center,
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: navigateToCreateCampaign,
                                      icon: Icon(Icons.campaign),
                                      label: Text('Create Campaign'),
                                      style: ElevatedButton.styleFrom(
                                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                      ),
                                    ),
                                    ElevatedButton.icon(
                                      onPressed: navigateToCreatePortfolio,
                                      icon: Icon(Icons.work),
                                      label: Text('Create Portfolio'),
                                      style: ElevatedButton.styleFrom(
                                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  case 1:
                    return MyLinksPage();
                  case 2:
                    return AnalyticsPage();
                  default:
                    return Center(child: Text('Page not found'));
                }
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeController extends GetxController {
  final currentIndex = 0.obs;

  void setIndex(int index) {
    currentIndex.value = index;
    update(); // Add this to ensure UI updates
  }
}
