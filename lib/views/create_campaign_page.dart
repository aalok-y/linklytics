import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/campaign_controller.dart';

class CreateCampaignPage extends StatelessWidget {
  final CampaignController campaignController = Get.find<CampaignController>();
  final TextEditingController campaignNameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController linkController = TextEditingController();
  final TextEditingController linkNameController = TextEditingController();
  final RxList<Map<String, String>> links = <Map<String, String>>[].obs;

  bool isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  void addLink() {
    if (linkController.text.isNotEmpty) {
      String url = linkController.text.trim();
      
      // Add http:// if no scheme is present
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        url = 'https://$url';
      }
      
      if (!isValidUrl(url)) {
        Get.snackbar(
          "Error",
          "Please enter a valid URL (e.g., https://example.com)",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red,
        );
        return;
      }

      links.add({
        'url': url,
        'name': linkNameController.text.trim().isEmpty ? '' : linkNameController.text.trim()
      });
      linkController.clear();
      linkNameController.clear();
    }
  }

  void removeLink(int index) {
    links.removeAt(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Campaign'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: campaignNameController,
              decoration: InputDecoration(labelText: "Campaign Name"),
            ),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: "Description (Optional)"),
            ),
            SizedBox(height: 20),
            Text('Add Links', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Column(
              children: [
                TextField(
                  controller: linkController,
                  decoration: InputDecoration(labelText: "Enter Link"),
                ),
                TextField(
                  controller: linkNameController,
                  decoration: InputDecoration(labelText: "Link Name (Optional)"),
                ),
                SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: addLink,
                  icon: Icon(Icons.add),
                  label: Text("Add Link"),
                ),
              ],
            ),
            SizedBox(height: 20),
            Obx(() => Column(
              children: links
                  .asMap()
                  .entries
                  .map((entry) => ListTile(
                        title: Text(entry.value['url']!),
                        subtitle: entry.value['name']!.isNotEmpty
                            ? Text(entry.value['name']!)
                            : null,
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => removeLink(entry.key),
                        ),
                      ))
                  .toList(),
            )),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (campaignNameController.text.isNotEmpty) {
                    campaignController.shortenLinks(
                      campaignNameController.text,
                      descriptionController.text.isEmpty
                          ? null
                          : descriptionController.text,
                      links.map((link) => link['url']!).toList(),
                    );
                  }
                },
                child: Text("Create Campaign"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
