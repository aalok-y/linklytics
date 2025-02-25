import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../api/api_service.dart';

class CampaignLink {
  final int linkId;
  final String linkName;
  final String originalUrl;
  final String shortUrl;
  final String createdAt;
  final int clicks;

  CampaignLink({
    required this.linkId,
    required this.linkName,
    required this.originalUrl,
    required this.shortUrl,
    required this.createdAt,
    this.clicks = 0,
  });

  factory CampaignLink.fromJson(Map<String, dynamic> json) {
    return CampaignLink(
      linkId: json['linkId'],
      linkName: json['linkName'],
      originalUrl: json['originalUrl'],
      shortUrl: json['shortUrl'],
      createdAt: json['createdAt'],
      clicks: json['clicks'] ?? 0,
    );
  }
}

class Campaign {
  final int campaignId;
  final String campaignName;
  final List<CampaignLink> links;

  Campaign({
    required this.campaignId,
    required this.campaignName,
    required this.links,
  });

  factory Campaign.fromJson(Map<String, dynamic> json) {
    return Campaign(
      campaignId: json['campaignId'],
      campaignName: json['campaignName'],
      links: (json['links'] as List)
          .map((link) => CampaignLink.fromJson(link))
          .toList(),
    );
  }
}

class CampaignController extends GetxController {
  var campaigns = <Campaign>[].obs;
  var isLoading = false.obs;
  var shortLinks = <String>[].obs;
  var campaignId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCampaigns();
  }

  Future<void> fetchCampaigns() async {
    try {
      isLoading(true);
      final response = await ApiService.getCampaigns();
      
      print('Campaign API Response: $response');
      
      if (response != null && response['campaigns'] != null) {
        final campaignsList = (response['campaigns'] as List)
            .map((campaign) => Campaign.fromJson(campaign))
            .toList();
        print('Parsed Campaigns: ${campaignsList.length}');
        campaigns.value = campaignsList;
      } else {
        print('No campaigns data in response');
        campaigns.value = [];
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

  Future<void> shortenLinks(String camName, String? description, List<String> links) async {
    if (camName.isEmpty) {
      Get.snackbar("Error", "Campaign name is required");
      return;
    }

    if (links.isEmpty) {
      Get.snackbar("Error", "Please add at least one link");
      return;
    }

    // Validate URLs
    for (var link in links) {
      try {
        final uri = Uri.parse(link);
        if (!uri.hasScheme || (uri.scheme != 'http' && uri.scheme != 'https')) {
          Get.snackbar(
            "Error",
            "Invalid URL format: $link. URLs must start with http:// or https://",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.withOpacity(0.1),
            colorText: Colors.red,
          );
          return;
        }
      } catch (e) {
        Get.snackbar(
          "Error",
          "Invalid URL format: $link",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red,
        );
        return;
      }
    }

    try {
      isLoading(true);
      final response = await ApiService.shortenLinks(camName, description, links);
      
      if (response != null) {
        campaignId.value = response["campaignId"].toString();
        shortLinks.assignAll(List<String>.from(response["shortLinks"]));
        Get.snackbar(
          "Success",
          "Links shortened successfully!",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.green,
        );
        fetchCampaigns(); // Refresh the campaigns list
      } else {
        Get.snackbar(
          "Error",
          "Failed to shorten links. Please check if you're logged in and the server is running.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red,
        );
      }
    } catch (e) {
      print('Error shortening links: $e');
      Get.snackbar(
        "Error",
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    } finally {
      isLoading(false);
    }
  }
}
