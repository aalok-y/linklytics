import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


class ApiService {
  static const String baseUrl = "http://localhost:8000/api/v1";

  static Future<Map<String, dynamic>> createPortfolio({
    required String portName,
    required String endpoint,
    String? description,
    String? avatar,
    List<Map<String, String>>? links,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      throw Exception('Not logged in. Please log in first.');
    }

    final response = await http.post(
      Uri.parse("$baseUrl/portfolio"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "portName": portName,
        "endpoint": endpoint,
        if (description != null && description.isNotEmpty) "description": description,
        if (avatar != null && avatar.isNotEmpty) "avatar": avatar,
        if (links != null && links.isNotEmpty) "links": links,
      }),
    );

    print('API Response Status: ${response.statusCode}');
    print('API Response Body: ${response.body}');
    
    final responseBody = jsonDecode(response.body);
    
    if (response.statusCode == 201) {
      print('Portfolio created successfully: $responseBody');
      return responseBody;
    } else {
      print('API Error Response: ${response.body}');
      throw Exception(responseBody['error'] ?? responseBody['message'] ?? 'Failed to create portfolio');
    }
  }

  static Future<Map<String, dynamic>?> signUp(String name, String email, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/auth/signup"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"name": name, "username": email, "password": password}),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      return null;
    }
  }

  static Future<String?> signIn(String email, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/auth/signin"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"username": email, "password": password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['token'];
    } else {
      return null;
    }
  }

  static Future<Map<String, dynamic>?> shortenLinks(String camName, String? description, List<String> links) async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token'); // Read token from SharedPreferences

    if (token == null) {
      throw Exception('Not logged in. Please log in first.');
    }

    final response = await http.post(
      Uri.parse("$baseUrl/shorten"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",},
      body: jsonEncode({
        "camName": camName,
        "description": description,
        "links": links,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getCampaigns() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      throw Exception('Not logged in. Please log in first.');
    }

    final response = await http.get(
      Uri.parse("$baseUrl/campaigns"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('Error fetching campaigns: ${response.body}');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getPortfolios() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      throw Exception('Not logged in. Please log in first.');
    }

    final response = await http.get(
      Uri.parse("$baseUrl/portfolios"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('Error fetching portfolios: ${response.body}');
      return null;
    }
  }
}
