import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../api/api_service.dart';
import '../models/portfolio.dart';
import 'package:logger/logger.dart';

final logger = Logger();

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
  final portfolios = <Portfolio>[].obs;
  final isLoading = false.obs;
  final error = ''.obs;

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
      final List<dynamic> portfolioList = response['portfolios'] ?? [];
      portfolios.value = portfolioList
          .map((portfolio) => Portfolio.fromJson(portfolio))
          .toList();

      logger.d('Fetched ${portfolios.length} portfolios');
    } catch (e) {
      logger.e('Error fetching portfolios: $e');
      error.value = e.toString();
      portfolios.value = [];
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

      final response = await ApiService.createPortfolio(
        portName: portName,
        endpoint: endpoint,
        description: description,
        avatar: avatar,
        links: links,
      );

      logger.i('Portfolio created successfully');
      Get.snackbar(
        'Success',
        'Portfolio created successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green[100],
      );

      await fetchPortfolios();
    } catch (e) {
      logger.e('Error creating portfolio: $e');
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
