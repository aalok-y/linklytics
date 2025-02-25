import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import '../controllers/campaign_controller.dart' as ctrl;
import '../api/api_service.dart';
import '../models/campaign.dart';

extension CampaignConversion on ctrl.Campaign {
  Campaign toModelCampaign() {
    return Campaign(
      id: campaignId.toString(),
      campaignName: campaignName,
      links: links.map((link) => Link(
        id: link.linkId.toString(),
        originalUrl: link.originalUrl,
        shortUrl: link.shortUrl,
        linkName: link.linkName,
        clicks: link.clicks,
        campaignId: campaignId.toString(),
        createdAt: DateTime.parse(link.createdAt),
      )).toList(),
    );
  }
}

class CampaignsPage extends StatelessWidget {
  CampaignsPage({super.key});

  final campaignController = Get.find<ctrl.CampaignController>();

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
            : RefreshIndicator(
                onRefresh: () async {
                  await campaignController.fetchCampaigns();
                },
                child: campaignController.campaigns.isEmpty
                    ? ListView(
                        children: [
                          SizedBox(height: MediaQuery.of(context).size.height / 3),
                          Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.campaign_outlined,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'No campaigns yet. Create one!',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : ListView.builder(
                        physics: AlwaysScrollableScrollPhysics(),
                        itemCount: campaignController.campaigns.length,
                        itemBuilder: (context, index) {
                          final campaign = campaignController.campaigns[index];
                          return Card(
                            margin: EdgeInsets.all(8),
                            elevation: 2,
                            child: ExpansionTile(
                              leading: Icon(Icons.campaign, color: Theme.of(context).primaryColor),
                              title: Text(
                                campaign.campaignName,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                '${campaign.links.length} links',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.analytics, color: Theme.of(context).primaryColor),
                                    onPressed: () {
                                      // Navigate to analytics page
                                      Get.toNamed('/analytics', arguments: campaign.toModelCampaign());
                                    },
                                    tooltip: 'View Analytics',
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: () {
                                      _showLinkManagementDialog(context, campaign.toModelCampaign());
                                    },
                                    tooltip: 'Manage Links',
                                  ),
                                ],
                              ),
                              children: [
                                if (campaign.links.isNotEmpty)
                                  Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Links',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                TextButton.icon(
                                                  onPressed: () {
                                                    _showBatchImportDialog(context, campaign.toModelCampaign());
                                                  },
                                                  icon: Icon(Icons.upload_file),
                                                  label: Text('Batch Import'),
                                                ),
                                                SizedBox(width: 8),
                                                TextButton.icon(
                                                  onPressed: () {
                                                    _showLinkManagementDialog(context, campaign.toModelCampaign());
                                                  },
                                                  icon: Icon(Icons.add_link),
                                                  label: Text('Add Link'),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 8),
                                        ...campaign.links.map((link) => Card(
                                              margin: EdgeInsets.only(bottom: 12),
                                              child: Padding(
                                                padding: EdgeInsets.all(12),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child: Text(
                                                            link.linkName,
                                                            style: TextStyle(
                                                              fontWeight: FontWeight.w500,
                                                              fontSize: 16,
                                                            ),
                                                          ),
                                                        ),
                                                        IconButton(
                                                          icon: Icon(Icons.edit, size: 20),
                                                          onPressed: () {
                                                            _showEditLinkDialog(context, campaign.toModelCampaign(), Link(
                                                              id: link.linkId.toString(),
                                                              originalUrl: link.originalUrl,
                                                              shortUrl: link.shortUrl,
                                                              linkName: link.linkName,
                                                              clicks: link.clicks,
                                                              campaignId: campaign.campaignId.toString(),
                                                              createdAt: DateTime.parse(link.createdAt),
                                                            ));
                                                          },
                                                          tooltip: 'Edit Link',
                                                        ),
                                                        IconButton(
                                                          icon: Icon(Icons.delete, size: 20, color: Colors.red),
                                                          onPressed: () {
                                                            _showDeleteLinkDialog(context, campaign.toModelCampaign(), Link(
                                                              id: link.linkId.toString(),
                                                              originalUrl: link.originalUrl,
                                                              shortUrl: link.shortUrl,
                                                              linkName: link.linkName,
                                                              clicks: link.clicks,
                                                              campaignId: campaign.campaignId.toString(),
                                                              createdAt: DateTime.parse(link.createdAt),
                                                            ));
                                                          },
                                                          tooltip: 'Delete Link',
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(height: 8),
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Text(
                                                                'Original URL:',
                                                                style: TextStyle(
                                                                  color: Colors.grey[600],
                                                                  fontSize: 12,
                                                                ),
                                                              ),
                                                              Text(
                                                                link.originalUrl,
                                                                style: TextStyle(fontSize: 14),
                                                                overflow: TextOverflow.ellipsis,
                                                                maxLines: 1,
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        IconButton(
                                                          icon: Icon(Icons.copy, size: 20),
                                                          onPressed: () {
                                                            Clipboard.setData(ClipboardData(text: link.originalUrl));
                                                            Get.snackbar(
                                                              'Copied',
                                                              'Original URL copied to clipboard',
                                                              snackPosition: SnackPosition.BOTTOM,
                                                            );
                                                          },
                                                          tooltip: 'Copy Original URL',
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(height: 8),
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Text(
                                                                'Short URL:',
                                                                style: TextStyle(
                                                                  color: Colors.grey[600],
                                                                  fontSize: 12,
                                                                ),
                                                              ),
                                                              Text(
                                                                link.shortUrl,
                                                                style: TextStyle(
                                                                  fontSize: 14,
                                                                  color: Theme.of(context).primaryColor,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        IconButton(
                                                          icon: Icon(Icons.copy, size: 20),
                                                          onPressed: () {
                                                            final fullUrl = 'https://linklytics-backend.onrender.com/${link.shortUrl}';
                                                            Clipboard.setData(ClipboardData(text: fullUrl));
                                                            Get.snackbar(
                                                              'Copied',
                                                              'Short URL copied to clipboard',
                                                              snackPosition: SnackPosition.BOTTOM,
                                                            );
                                                          },
                                                          tooltip: 'Copy Short URL',
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(height: 8),
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Icon(Icons.bar_chart, size: 16, color: Colors.grey[600]),
                                                            SizedBox(width: 4),
                                                            Text(
                                                              '${link.clicks} clicks',
                                                              style: TextStyle(
                                                                color: Colors.grey[600],
                                                                fontSize: 14,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        Row(
                                                          children: [
                                                            Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                                                            SizedBox(width: 4),
                                                            Text(
                                                              'Created ${_formatDate(DateTime.parse(link.createdAt))}',
                                                              style: TextStyle(
                                                                color: Colors.grey[600],
                                                                fontSize: 14,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
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
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed('/create-campaign'),
        icon: Icon(Icons.add),
        label: Text('New Campaign'),
        tooltip: 'Create Campaign',
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} minutes ago';
      }
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _showLinkManagementDialog(BuildContext context, Campaign campaign) {
    final newLinkController = TextEditingController();
    final newLinkNameController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 500,
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title section with icon
                Wrap(
                  spacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Icon(Icons.link, color: Theme.of(context).primaryColor),
                    Text(
                      'Add Link to Campaign',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
                SizedBox(height: 16),
                // Form section
                Flexible(
                  child: SingleChildScrollView(
                    child: Form(
                      key: formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            controller: newLinkNameController,
                            decoration: InputDecoration(
                              labelText: 'Link Name',
                              hintText: 'Enter a name for this link',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.title),
                            ),
                          ),
                          SizedBox(height: 16),
                          TextFormField(
                            controller: newLinkController,
                            decoration: InputDecoration(
                              labelText: 'URL',
                              hintText: 'Enter the URL to shorten',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.link),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter a URL';
                              }
                              try {
                                final uri = Uri.parse(value);
                                if (!uri.hasScheme || !uri.hasAuthority) {
                                  return 'Please enter a valid URL with http:// or https://';
                                }
                              } catch (e) {
                                return 'Please enter a valid URL';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'URLs must start with http:// or https://',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                // Actions section
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel'),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () async {
                        if (!formKey.currentState!.validate()) return;
                        
                        final url = newLinkController.text.trim();
                        final name = newLinkNameController.text.trim();
                        
                        try {
                          final response = await ApiService.addLinksToCampaign(
                            campaign.id,
                            [url],
                            name: name,
                          );
                          
                          if (response['message'] == 'Links added to campaign successfully' || response['message'] == 'Links added successfully') {
                            Get.snackbar(
                              'Success',
                              'Link added successfully',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.green[100],
                            );
                            await campaignController.fetchCampaigns();
                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                          }
                        } catch (e) {
                          print('Error adding link: $e');
                          Get.snackbar(
                            'Error',
                            'Failed to add link: ${e.toString()}',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.red[100],
                          );
                        }
                      },
                      icon: Icon(Icons.add),
                      label: Text('Add Link'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showBatchImportDialog(BuildContext context, Campaign campaign) {
    final linksController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.upload_file, color: Theme.of(context).primaryColor),
            SizedBox(width: 8),
            Text('Batch Import Links'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: linksController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    labelText: 'URLs',
                    hintText: 'Enter one URL per line',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.link),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter at least one URL';
                    }
                    final urls = value.split('\n').where((url) => url.trim().isNotEmpty).toList();
                    if (urls.isEmpty) {
                      return 'Please enter at least one URL';
                    }
                    for (final url in urls) {
                      try {
                        final uri = Uri.parse(url.trim());
                        if (!uri.hasScheme || !uri.hasAuthority) {
                          return 'All URLs must start with http:// or https://';
                        }
                      } catch (e) {
                        return 'Please enter valid URLs';
                      }
                    }
                    return null;
                  },
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'URLs must start with http:// or https://\nEach URL will be created with its domain name',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              
              final urls = linksController.text
                  .split('\n')
                  .where((url) => url.trim().isNotEmpty)
                  .map((url) => url.trim())
                  .toList();
              
              try {
                final response = await ApiService.addLinksToCampaign(
                  campaign.id,
                  urls,
                );
                
                if (response['message'] == 'Links added to campaign successfully' || response['message'] == 'Links added successfully') {
                  Get.snackbar(
                    'Success',
                    '${urls.length} links added successfully',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.green[100],
                  );
                  await campaignController.fetchCampaigns();
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                }
              } catch (e) {
                print('Error adding links: $e');
                Get.snackbar(
                  'Error',
                  'Failed to add links: ${e.toString()}',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red[100],
                );
              }
            },
            icon: Icon(Icons.upload),
            label: Text('Import Links'),
          ),
        ],
      ),
    );
  }

  void _showEditLinkDialog(BuildContext context, Campaign campaign, Link link) {
    final editNameController = TextEditingController(text: link.linkName);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.edit, color: Theme.of(context).primaryColor),
            SizedBox(width: 8),
            Text('Edit Link'),
          ],
        ),
        content: TextField(
          controller: editNameController,
          decoration: InputDecoration(
            labelText: 'Link Name',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.title),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              final newName = editNameController.text.trim();
              if (newName.isEmpty) return;
              
              try {
                await ApiService.updateLinkName(
                  link.id,
                  newName,
                );
                
                Get.snackbar(
                  'Success',
                  'Link name updated successfully',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.green[100],
                );
                await campaignController.fetchCampaigns();
                if (context.mounted) {
                  Navigator.pop(context);
                }
              } catch (e) {
                Get.snackbar(
                  'Error',
                  'Failed to update link name: ${e.toString()}',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red[100],
                );
              }
            },
            icon: Icon(Icons.save),
            label: Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteLinkDialog(BuildContext context, Campaign campaign, Link link) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.delete_forever, color: Colors.red),
            SizedBox(width: 8),
            Text('Delete Link'),
          ],
        ),
        content: Text('Are you sure you want to delete this link? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              try {
                final response = await ApiService.deleteLink(link.id);
                
                if (response['message'] == 'Links deleted successfully' || response['message'] == 'Link deleted successfully') {
                  Get.snackbar(
                    'Success',
                    'Link deleted successfully',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.green[100],
                  );
                  await campaignController.fetchCampaigns();
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                }
              } catch (e) {
                print('Error deleting link: $e');
                Get.snackbar(
                  'Error',
                  'Failed to delete link: ${e.toString()}',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red[100],
                );
              }
            },
            icon: Icon(Icons.delete),
            label: Text('Delete'),
          ),
        ],
      ),
    );
  }
}
