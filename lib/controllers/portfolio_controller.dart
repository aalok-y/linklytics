import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../api/api_service.dart';

class Portfolio {
  final int id;
  final String name;
  final String? description;
  final String endpoint;
  final String? avatar;
  final List<Map<String, String>> links;
  final DateTime createdAt;

  Portfolio({
    required this.id,
    required this.name,
    this.description,
    required this.endpoint,
    this.avatar,
    required this.links,
    required this.createdAt,
  });

  factory Portfolio.fromJson(Map<String, dynamic> json) {
    return Portfolio(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      endpoint: json['endpoint'] as String,
      avatar: json['avatar'] as String?,
      links: (json['links'] as List?)
          ?.map((link) => Map<String, String>.from(link))
          .toList() ?? [],
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class PortfolioController extends GetxController {
  final isLoading = false.obs;
  final error = RxString('');
  final portfolios = <Portfolio>[].obs;

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
      
      if (response != null) {
        portfolios.value = (response['portfolios'] as List)
            .map((portfolio) => Portfolio.fromJson(portfolio))
            .toList();
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
