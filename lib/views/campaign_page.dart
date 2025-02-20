import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/campaign_controller.dart';

class CampaignPage extends StatelessWidget {
  final CampaignController campaignController = Get.put(CampaignController());

  final TextEditingController campaignNameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController linkController = TextEditingController();
  final RxList<String> links = <String>[].obs;

  void addLink() {
    if (linkController.text.isNotEmpty) {
      links.add(linkController.text);
      linkController.clear();
    }
  }

  void removeLink(int index) {
    links.removeAt(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Shorten Links")),
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
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: linkController,
                    decoration: InputDecoration(labelText: "Enter Link"),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: addLink,
                ),
              ],
            ),
            Obx(() => Column(
                  children: links
                      .asMap()
                      .entries
                      .map((entry) => ListTile(
                            title: Text(entry.value),
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
                      links,
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
