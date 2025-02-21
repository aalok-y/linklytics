import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../controllers/portfolio_controller.dart';

class CreatePortfolioPage extends StatelessWidget {
  final PortfolioController portfolioController = Get.put(PortfolioController());
  final TextEditingController portNameController = TextEditingController();
  final TextEditingController endpointController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final RxString avatarPath = ''.obs;
  final RxList<Map<String, String>> links = <Map<String, String>>[].obs;
  final TextEditingController linkNameController = TextEditingController();
  final TextEditingController linkUrlController = TextEditingController();

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      avatarPath.value = image.path;
    }
  }

  void addLink() {
    if (linkNameController.text.isNotEmpty && linkUrlController.text.isNotEmpty) {
      links.add({
        'name': linkNameController.text,
        'link': linkUrlController.text,
      });
      linkNameController.clear();
      linkUrlController.clear();
    }
  }

  void removeLink(int index) {
    links.removeAt(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Portfolio'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: portNameController,
              decoration: InputDecoration(
                labelText: 'Portfolio Name',
                hintText: 'Enter your portfolio name',
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: endpointController,
              decoration: InputDecoration(
                labelText: 'Custom Endpoint',
                hintText: 'Enter your custom endpoint (e.g., my-portfolio)',
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Description (Optional)',
                hintText: 'Enter portfolio description',
              ),
            ),
            SizedBox(height: 16),
            Text('Avatar (Optional)', style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Obx(() => avatarPath.value.isNotEmpty
              ? Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: FileImage(File(avatarPath.value)),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                )
              : Container()
            ),
            ElevatedButton.icon(
              onPressed: pickImage,
              icon: Icon(Icons.image),
              label: Text('Pick Avatar'),
            ),
            SizedBox(height: 24),
            Text('Links (Optional)', style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            TextField(
              controller: linkNameController,
              decoration: InputDecoration(
                labelText: 'Link Name',
                hintText: 'Enter link name',
              ),
            ),
            SizedBox(height: 8),
            TextField(
              controller: linkUrlController,
              decoration: InputDecoration(
                labelText: 'Link URL',
                hintText: 'Enter link URL',
              ),
            ),
            SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: addLink,
              icon: Icon(Icons.add),
              label: Text('Add Link'),
            ),
            SizedBox(height: 16),
            Obx(() => Column(
              children: links.asMap().entries.map((entry) {
                final index = entry.key;
                final link = entry.value;
                return ListTile(
                  title: Text(link['name'] ?? ''),
                  subtitle: Text(link['link'] ?? ''),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => removeLink(index),
                  ),
                );
              }).toList(),
            )),
            SizedBox(height: 24),
            Obx(() => portfolioController.isLoading.value
              ? Center(child: CircularProgressIndicator())
              : SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      portfolioController.createPortfolio(
                        portName: portNameController.text,
                        endpoint: endpointController.text,
                        description: descriptionController.text.isEmpty ? null : descriptionController.text,
                        avatar: avatarPath.value.isEmpty ? null : avatarPath.value,
                        links: links.isEmpty ? null : links,
                      );
                    },
                    child: Text('Create Portfolio'),
                  ),
                ),
            ),
          ],
        ),
      ),
    );
  }
}
