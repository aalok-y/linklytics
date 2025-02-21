import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../api/api_service.dart';

class PortfolioController extends GetxController {
  final isLoading = false.obs;
  final error = RxString('');

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
        duration: Duration(seconds: 5),
      );
      
      // Add a small delay before navigating back to ensure the snackbar is visible
      await Future.delayed(Duration(seconds: 2));
      Get.back(); // Navigate back after successful creation
    } catch (e) {
      print('Portfolio Creation Error: $e');
      error.value = e.toString();
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 5),
        backgroundColor: Colors.red[100],
      );
    } finally {
      isLoading.value = false;
    }
  }
}
