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
  final _controller = Get.put(HomeController());

  HomePage({Key? key}) : super(key: key);

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
        title: Obx(() => Text(_getPageTitle())),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              Get.offAllNamed('/login');
            },
          ),
        ],
      ),
      body: Row(
        children: [
          _buildSidebar(context),
          Expanded(
            child: Obx(() {
              switch (_controller.currentIndex.value) {
                case 0:
                  return _buildCreateLinkPage(context);
                case 1:
                  return MyLinksPage();
                case 2:
                  return AnalyticsPage();
                default:
                  return _buildCreateLinkPage(context);
              }
            }),
          ),
        ],
      ),
    );
  }

  String _getPageTitle() {
    switch (_controller.currentIndex.value) {
      case 0:
        return 'Create Short Link';
      case 1:
        return 'My Links';
      case 2:
        return 'Analytics';
      default:
        return 'Create Short Link';
    }
  }

  Widget _buildCreateLinkPage(BuildContext context) {
    return Center(
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
    );
  }

  Widget _buildSidebar(BuildContext context) {
    return Container(
      width: 250,
      color: Theme.of(context).primaryColor,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Linklytics',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          _buildNavItem(
            context,
            'Create Link',
            Icons.add_link,
            0,
          ),
          _buildNavItem(
            context,
            'My Links',
            Icons.link,
            1,
          ),
          _buildNavItem(
            context,
            'Analytics',
            Icons.analytics,
            2,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    String title,
    IconData icon,
    int index,
  ) {
    return Obx(() {
      final isSelected = _controller.currentIndex.value == index;
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => _controller.setIndex(index),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.white.withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: Colors.white,
                  size: 24,
                ),
                SizedBox(width: 16),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class HomeController extends GetxController {
  var currentIndex = 0.obs;

  void setIndex(int index) {
    currentIndex.value = index;
  }
}
