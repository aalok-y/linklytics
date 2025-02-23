import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:linklytics/api/api_service.dart';
import 'package:linklytics/views/campaigns_page.dart';
import 'package:linklytics/views/portfolios_page.dart';

class MyLinksPage extends StatelessWidget {
  const MyLinksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.05),
              Colors.white,
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 40),
                Text(
                  'My Links',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                SizedBox(height: 40),
                LayoutBuilder(
                  builder: (context, constraints) {
                    double cardWidth = constraints.maxWidth < 600 
                        ? constraints.maxWidth 
                        : (constraints.maxWidth / 2) - 30;
                    return Container(
                      width: constraints.maxWidth,
                      child: constraints.maxWidth < 600
                          ? Column(
                              children: [
                                _buildOptionCard(
                                  context,
                                  'View Campaigns',
                                  Icons.campaign,
                                  'Manage and track your campaign links',
                                  () => Get.to(() => CampaignsPage()),
                                  cardWidth,
                                ),
                                SizedBox(height: 20),
                                _buildOptionCard(
                                  context,
                                  'View Portfolios',
                                  Icons.work,
                                  'Organize and monitor your portfolio links',
                                  () => Get.to(() => PortfoliosPage()),
                                  cardWidth,
                                ),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildOptionCard(
                                  context,
                                  'View Campaigns',
                                  Icons.campaign,
                                  'Manage and track your campaign links',
                                  () => Get.to(() => CampaignsPage()),
                                  cardWidth,
                                ),
                                SizedBox(width: 20),
                                _buildOptionCard(
                                  context,
                                  'View Portfolios',
                                  Icons.work,
                                  'Organize and monitor your portfolio links',
                                  () => Get.to(() => PortfoliosPage()),
                                  cardWidth,
                                ),
                              ],
                            ),
                    );
                  },
                ),
                SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard(BuildContext context, String title, IconData icon,
      String description, VoidCallback onTap, double width) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: width,
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              SizedBox(height: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
