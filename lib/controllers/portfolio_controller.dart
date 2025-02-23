import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../api/api_service.dart';

class Portfolio {
  final int id;
  final String name;
  final String? description;
  final String endpoint;
  final String? avatar;
  final String createdAt;
  final List<PortfolioLink> links;

  Portfolio({
    required this.id,
    required this.name,
    this.description,
    required this.endpoint,
    this.avatar,
    required this.createdAt,
    required this.links,
  });

  factory Portfolio.fromJson(Map<String, dynamic> json) {
    return Portfolio(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      endpoint: json['endpoint'],
      avatar: json['avatar'],
      createdAt: json['createdAt'],
      links: (json['links'] as List)
          .map((link) => PortfolioLink.fromJson(link))
          .toList(),
    );
  }
}

class PortfolioLink {
  final int id;
  final String name;
  final String originalUrl;
  final String shortUrl;
  final int clicks;
  final String createdAt;

  PortfolioLink({
    required this.id,
    required this.name,
    required this.originalUrl,
    required this.shortUrl,
    required this.clicks,
    required this.createdAt,
  });

  factory PortfolioLink.fromJson(Map<String, dynamic> json) {
    return PortfolioLink(
      id: json['id'],
      name: json['name'],
      originalUrl: json['originalUrl'],
      shortUrl: json['shortUrl'],
      clicks: json['clicks'],
      createdAt: json['createdAt'],
    );
  }
}

class PortfolioController extends GetxController {
  var portfolios = <Portfolio>[].obs;
  var isLoading = false.obs;
  var error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPortfolios();
  }

  Future<void> fetchPortfolios() async {
    try {
      isLoading.value = true;
      error.value = '';
      
      final response = await ApiService.getPortfolios();
      
      print('Portfolio API Response: $response');
      
      if (response != null && response['portfolios'] != null) {
        final portfoliosList = (response['portfolios'] as List)
            .map((portfolio) => Portfolio.fromJson(portfolio))
            .toList();
        print('Parsed Portfolios: ${portfoliosList.length}');
        portfolios.value = portfoliosList;
      } else {
        print('No portfolios data in response');
        portfolios.value = [];
      }
    } catch (e) {
      print('Error fetching portfolios: $e');
      error.value = 'Failed to fetch portfolios';
      Get.snackbar(
        'Error',
        'Failed to fetch portfolios',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createPortfolio({
    required String portName,
    required String endpoint,
    String? description,
    String? avatar,
    List<Map<String, String>>? links,
  }) async {
    try {
      isLoading.value = true;
      error.value = '';
      
      final result = await ApiService.createPortfolio(
        portName: portName,
        endpoint: endpoint,
        description: description,
        avatar: avatar,
        links: links,
      );

      print('Portfolio creation result: $result');
      Get.snackbar(
        'Success',
        result['message'] ?? 'Portfolio created successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green[100],
      );
      
      // Refresh portfolios list after creating a new one
      fetchPortfolios();
    } catch (e) {
      print('Error creating portfolio: $e');
      error.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to create portfolio: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[100],
      );
    } finally {
      isLoading.value = false;
    }
  }
}
