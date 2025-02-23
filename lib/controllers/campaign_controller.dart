import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../api/api_service.dart';

class Campaign {
  final int id;
  final String name;
  final String? description;
  final String originalUrl;
  final String shortUrl;
  final DateTime createdAt;

  Campaign({
    required this.id,
    required this.name,
    this.description,
    required this.originalUrl,
    required this.shortUrl,
    required this.createdAt,
  });

  factory Campaign.fromJson(Map<String, dynamic> json) {
    return Campaign(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      originalUrl: json['originalUrl'] as String,
      shortUrl: json['shortUrl'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class CampaignController extends GetxController {
  var isLoading = false.obs;
  var shortLinks = <String>[].obs;
  var campaignId = ''.obs;
  var campaigns = <Campaign>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchCampaigns();
  }

  Future<void> fetchCampaigns() async {
    try {
      isLoading(true);
      final response = await ApiService.getCampaigns();
      
      if (response != null) {
        campaigns.value = (response['campaigns'] as List)
            .map((campaign) => Campaign.fromJson(campaign))
            .toList();
      }
    } catch (e) {
      print('Error fetching campaigns: $e');
      Get.snackbar(
        'Error',
        'Failed to fetch campaigns',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading(false);
    }
  }

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
        fetchCampaigns(); // Refresh the campaigns list
      } else {
        Get.snackbar("Error", "Failed to shorten links. Please check if you're logged in and the server is running.");
      }
    } catch (e) {
      print('Error shortening links: $e');
      Get.snackbar("Error", e.toString().replaceAll('Exception: ', ''));
    } finally {
      isLoading(false);
    }
  }
}
