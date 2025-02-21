
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/campaign_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'analytics_page.dart';
import 'create_portfolio_page.dart';
import 'create_campaign_page.dart';

class HomePage extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();
  final CampaignController campaignController = Get.put(CampaignController());
  final RxInt currentIndex = 0.obs;

  void navigateToCreatePortfolio() {
    Get.to(() => CreatePortfolioPage());
  }

  void navigateToCreateCampaign() {
    Get.to(() => CreateCampaignPage());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(currentIndex.value == 0 ? 'Create Short Link' : 'Analytics')),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: authController.logout,
          ),
        ],
      ),
      body: Obx(() => IndexedStack(
        index: currentIndex.value,
        children: [
          // Create Link Options Page
          Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Create New',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: navigateToCreateCampaign,
                      icon: Icon(Icons.add_link),
                      label: Text('Create Campaign', style: TextStyle(fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: navigateToCreatePortfolio,
                      icon: Icon(Icons.add_box_outlined),
                      label: Text('Create Portfolio', style: TextStyle(fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Analytics Page
          AnalyticsPage(),
        ],
      )),
      bottomNavigationBar: Obx(() => BottomNavigationBar(
        currentIndex: currentIndex.value,
        onTap: (index) => currentIndex.value = index,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.link),
            label: 'Create Link',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Analytics',
          ),
        ],
      )),
    );
  }
}
