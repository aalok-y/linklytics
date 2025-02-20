import 'package:get/get.dart';
import '../api/api_service.dart';

class CampaignController extends GetxController {
  var isLoading = false.obs;
  var shortLinks = <String>[].obs;
  var campaignId = ''.obs;

  void shortenLinks(String camName, String? description, List<String> links) async {
    if (camName.isEmpty || links.isEmpty) {
      Get.snackbar("Error", "Campaign name and at least one link are required.");
      return;
    }

    try {
      isLoading(true);
      final response = await ApiService.shortenLinks(camName, description, links);
      
      if (response != null) {
        campaignId.value = response["campaignId"].toString();
        shortLinks.assignAll(List<String>.from(response["shortLinks"]));
        Get.snackbar("Success", "Links shortened successfully!");
      } else {
        // Handle null response as an error
        Get.snackbar("Error", "Failed to shorten links. Please check if you're logged in and the server is running.");
      }
    } catch (e) {
      print('Error shortening links: $e'); // Add logging
      Get.snackbar("Error", e.toString().replaceAll('Exception: ', ''));
    } finally {
      isLoading(false);
    }
  }
}
