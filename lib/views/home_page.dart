
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/campaign_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();
  final CampaignController campaignController = Get.put(CampaignController());

  final TextEditingController campaignNameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController linkController = TextEditingController();
  final TextEditingController linkNameController = TextEditingController();
  final RxList<Map<String, String>> links = <Map<String, String>>[].obs;

  void addLink() {
    if (linkController.text.isNotEmpty) {
      links.add({
        'url': linkController.text,
        'name': linkNameController.text.isEmpty ? '' : linkNameController.text
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
        title: Text("Campaign Page"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: authController.logout, // Logout button
          ),
        ],
      ),
      body: Padding(
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
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => removeLink(entry.key),
                            ),
                          ))
                      .toList(),
                )),
            SizedBox(height: 20),
            Obx(() => campaignController.isLoading.value
                ? Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: () => campaignController.shortenLinks(
                      campaignNameController.text,
                      descriptionController.text,
                      links.map((link) => link['url']!).toList(),
                    ),
                    child: Text("Shorten"),
                  )),
            SizedBox(height: 20),
            Obx(() => campaignController.shortLinks.isNotEmpty
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Shortened Links:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ...campaignController.shortLinks.map((link) => ListTile(
                            title: Text(link, style: TextStyle(color: Colors.blue)),
                          )),
                    ],
                  )
                : Container()),
          ],
        ),
      ),
    );
  }
}
