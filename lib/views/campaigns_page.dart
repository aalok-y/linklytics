import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/campaign_controller.dart';

class CampaignsPage extends StatelessWidget {
  CampaignsPage({super.key});

  final campaignController = Get.find<CampaignController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Campaigns'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => Get.toNamed('/create-campaign'),
          ),
        ],
      ),
      body: Obx(
        () => campaignController.isLoading.value
            ? Center(child: CircularProgressIndicator())
            : campaignController.campaigns.isEmpty
                ? Center(
                    child: Text(
                      'No campaigns yet. Create one!',
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    itemCount: campaignController.campaigns.length,
                    itemBuilder: (context, index) {
                      final campaign = campaignController.campaigns[index];
                      return Card(
                        margin: EdgeInsets.all(8),
                        child: ExpansionTile(
                          title: Text(
                            campaign.campaignName,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          children: [
                            if (campaign.links.isNotEmpty)
                              Padding(
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Links',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    ...campaign.links.map((link) => Padding(
                                          padding: EdgeInsets.only(bottom: 8),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Original URL: ${link.originalUrl}',
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                'Short URL: ${link.shortUrl}',
                                                style: TextStyle(
                                                  color: Theme.of(context).primaryColor,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed('/create-campaign'),
        child: Icon(Icons.add),
        tooltip: 'Create Campaign',
      ),
    );
  }
}
