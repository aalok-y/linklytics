import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/campaign_controller.dart';

class CampaignsPage extends StatelessWidget {
  final campaignController = Get.find<CampaignController>();

  CampaignsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Campaigns'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (campaignController.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        if (campaignController.campaigns.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.campaign_outlined,
                  size: 64,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'No campaigns yet',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () => Get.toNamed('/create-campaign'),
                  icon: Icon(Icons.add),
                  label: Text('Create Campaign'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: campaignController.campaigns.length,
          itemBuilder: (context, index) {
            final campaign = campaignController.campaigns[index];
            return Card(
              margin: EdgeInsets.only(bottom: 16),
              child: ListTile(
                contentPadding: EdgeInsets.all(16),
                title: Text(
                  campaign.name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 8),
                    Text(
                      'Original URL: ${campaign.originalUrl}',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Short URL: ${campaign.shortUrl}',
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                  ],
                ),
                trailing: IconButton(
                  icon: Icon(Icons.analytics),
                  onPressed: () {
                    // Navigate to campaign analytics
                    Get.toNamed('/analytics', arguments: campaign);
                  },
                ),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed('/create-campaign'),
        child: Icon(Icons.add),
        tooltip: 'Create Campaign',
      ),
    );
  }
}
