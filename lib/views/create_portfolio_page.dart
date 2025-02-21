import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../controllers/portfolio_controller.dart';

class CreatePortfolioPage extends StatefulWidget {
  @override
  _CreatePortfolioPageState createState() => _CreatePortfolioPageState();
}

class _CreatePortfolioPageState extends State<CreatePortfolioPage> {
  final PortfolioController portfolioController = Get.put(PortfolioController());
  final TextEditingController portNameController = TextEditingController();
  final TextEditingController endpointController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final RxString avatarPath = ''.obs;
  final RxString avatarUrl = ''.obs;
  final RxBool isUploading = false.obs;
  final RxList<Map<String, String>> links = <Map<String, String>>[].obs;
  final TextEditingController linkNameController = TextEditingController();
  final TextEditingController linkUrlController = TextEditingController();
  
  static const String cloudName = 'dhps8sgqe';
  static const String apiKey = '297531545326424';
  static const String apiSecret = 'kjVi8poyU64477Y2rL0pOOrhN4s';

  @override
  void initState() {
    super.initState();
  }

  Future<String?> uploadImageToCloudinary(String imagePath) async {
    try {
      // Create upload URL
      final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
      
      // Read file as bytes
      final bytes = await File(imagePath).readAsBytes();
      final base64Image = base64Encode(bytes);
      
      // Create form data
      final formData = {
        'file': 'data:image/jpeg;base64,$base64Image',
        'api_key': apiKey,
        'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
        'folder': 'avatars'
      };
      
      // Generate signature
      final signature = _generateSignature(formData);
      formData['signature'] = signature;
      
      // Make the HTTP request
      final response = await http.post(uri, body: formData);
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['secure_url'];
      } else {
        print('Upload failed with status: ${response.statusCode}');
        print('Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error uploading to Cloudinary: $e');
      Get.snackbar('Error', 'Failed to upload image');
      return null;
    }
  }

  String _generateSignature(Map<String, String> formData) {
    // Sort parameters
    final sortedKeys = formData.keys.toList()..sort();
    final params = sortedKeys.where((key) => key != 'file' && key != 'api_key')
        .map((key) => '$key=${formData[key]}')
        .join('&');
    
    // Generate signature
    final signatureString = params + apiSecret;
    final bytes = utf8.encode(signatureString);
    final digest = sha1.convert(bytes);
    return digest.toString();
  }

  Future<void> pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      
      if (image != null) {
        avatarPath.value = image.path;
        isUploading.value = true;
        
        final cloudinaryUrl = await uploadImageToCloudinary(image.path);
        if (cloudinaryUrl != null) {
          avatarUrl.value = cloudinaryUrl;
          Get.snackbar('Success', 'Image uploaded successfully');
        }
      }
    } catch (e) {
      print('Error picking image: $e');
      Get.snackbar('Error', 'Failed to pick image');
    } finally {
      isUploading.value = false;
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

  Future<void> submitPortfolio() async {
    if (portNameController.text.isEmpty) {
      Get.snackbar('Error', 'Portfolio name is required');
      return;
    }
    if (endpointController.text.isEmpty) {
      Get.snackbar('Error', 'Custom endpoint is required');
      return;
    }

    await portfolioController.createPortfolio(
      portName: portNameController.text,
      endpoint: endpointController.text,
      description: descriptionController.text.isNotEmpty ? descriptionController.text : null,
      avatar: avatarUrl.value.isNotEmpty ? avatarUrl.value : null,
      links: links.isNotEmpty ? links : null,
    );
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
            Obx(() => Column(
              children: [
                if (avatarPath.value.isNotEmpty)
                  Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: FileImage(File(avatarPath.value)),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                if (isUploading.value)
                  Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: CircularProgressIndicator(),
                  ),
                if (avatarUrl.value.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text('Upload complete! Image URL available.',
                        style: TextStyle(color: Colors.green)),
                  ),
              ],
            )),
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
            
            // Submit Button
            SizedBox(height: 32),
            Obx(() => ElevatedButton(
              onPressed: portfolioController.isLoading.value ? null : submitPortfolio,
              child: portfolioController.isLoading.value
                ? CircularProgressIndicator()
                : Text('Create Portfolio'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
            )),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
