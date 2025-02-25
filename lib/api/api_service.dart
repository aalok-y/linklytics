import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = "https://linklytics-backend.onrender.com/api/v1";

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

    try {
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
    } catch (e) {
      print('Network error creating portfolio: $e');
      throw Exception('Failed to create portfolio');
    }
  }

  static Future<Map<String, dynamic>?> signUp(String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/auth/signup"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"name": name, "username": email, "password": password}),
      );

      print('Sign Up API Status: ${response.statusCode}'); // Debug log
      print('Sign Up API Response: ${response.body}'); // Debug log

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        print('Error signing up: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Network error signing up: $e');
      return null;
    }
  }

  static Future<String?> signIn(String email, String password) async {
    try {
      print('Making sign in request to: $baseUrl/auth/signin'); // Debug URL
      final response = await http.post(
        Uri.parse("$baseUrl/auth/signin"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"username": email, "password": password}),
      );

      print('Sign In API Status: ${response.statusCode}');
      print('Sign In API Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['token'] != null) {
          return data['token'];
        } else {
          print('Token missing from response');
          return null;
        }
      } else {
        print('Error signing in: Status ${response.statusCode}, Body: ${response.body}');
        return null;
      }
    } catch (e, stackTrace) {
      print('Network error signing in: $e');
      print('Stack trace: $stackTrace');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> shortenLinks(String camName, String? description, List<String> links) async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token'); // Read token from SharedPreferences

    if (token == null) {
      throw Exception('Not logged in. Please log in first.');
    }

    try {
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

      print('Shorten Links API Status: ${response.statusCode}'); // Debug log
      print('Shorten Links API Response: ${response.body}'); // Debug log

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        print('Error shortening links: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Network error shortening links: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getCampaigns() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      throw Exception('Not logged in. Please log in first.');
    }

    try {
      final response = await http.get(
        Uri.parse("$baseUrl/links"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      print('Campaigns API Status: ${response.statusCode}');
      print('Campaigns API Response: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Error fetching campaigns: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Network error fetching campaigns: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> getPortfolios() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      throw Exception('Not logged in. Please log in first.');
    }

    try {
      final response = await http.get(
        Uri.parse("$baseUrl/portfolio"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      print('Portfolios API Status: ${response.statusCode}');
      print('Portfolios API Response: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Error fetching portfolios: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Network error fetching portfolios: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>> addLinksToCampaign(String campaignId, List<String> urls, {String? name}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      if (token == null) {
        throw Exception('Not logged in. Please log in first.');
      }

      print('Adding links to campaign: $campaignId');
      print('URLs: $urls');
      
      final requestBody = {
        'camId': int.parse(campaignId),
        'links': urls,
      };
      
      print('Request body: ${jsonEncode(requestBody)}');
      
      final response = await http.put(
        Uri.parse('$baseUrl/shorten'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      print('Add links API Status: ${response.statusCode}');
      print('Add links API Response: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        try {
          final responseData = jsonDecode(response.body);
          print('Decoded response: $responseData');
          return responseData;
        } catch (e) {
          print('Error decoding response: $e');
          print('Response body: ${response.body}');
          throw Exception('Invalid response format from server');
        }
      } else {
        String errorMessage;
        try {
          final error = jsonDecode(response.body);
          errorMessage = error['message'] ?? error['error'] ?? 'Unknown error occurred';
        } catch (e) {
          print('Error body: ${response.body}');
          errorMessage = 'Server error: ${response.statusCode}\nResponse: ${response.body}';
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('Error adding links to campaign: $e');
      throw Exception('Failed to add links to campaign: $e');
    }
  }

  static Future<Map<String, dynamic>> deleteLink(String linkId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      if (token == null) {
        throw Exception('Not logged in. Please log in first.');
      }

      print('Deleting link: $linkId');
      
      final response = await http.delete(
        Uri.parse('$baseUrl/shorten'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'linkIds': [int.parse(linkId)],
        }),
      );

      print('Delete link API Status: ${response.statusCode}');
      print('Delete link API Response: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        try {
          if (response.body.isEmpty) {
            return {'message': 'Link deleted successfully'};
          }
          final responseData = jsonDecode(response.body);
          print('Decoded response: $responseData');
          return responseData;
        } catch (e) {
          print('Error decoding response: $e');
          print('Response body: ${response.body}');
          if (response.statusCode == 204) {
            return {'message': 'Link deleted successfully'};
          }
          throw Exception('Invalid response format from server');
        }
      } else {
        String errorMessage;
        try {
          final error = jsonDecode(response.body);
          errorMessage = error['message'] ?? error['error'] ?? 'Unknown error occurred';
        } catch (e) {
          print('Error body: ${response.body}');
          errorMessage = 'Server error: ${response.statusCode}\nResponse: ${response.body}';
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('Error deleting link: $e');
      throw Exception('Failed to delete link: $e');
    }
  }

  static Future<Map<String, dynamic>> deleteLinks(List<String> linkIds) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      if (token == null) {
        throw Exception('Not logged in. Please log in first.');
      }

      print('Deleting links: $linkIds');
      
      final response = await http.delete(
        Uri.parse('$baseUrl/shorten'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'linkIds': linkIds.map((id) => int.parse(id)).toList(),
        }),
      );

      print('Delete links API Status: ${response.statusCode}');
      print('Delete links API Response: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        try {
          if (response.body.isEmpty) {
            return {'message': 'Links deleted successfully'};
          }
          final responseData = jsonDecode(response.body);
          print('Decoded response: $responseData');
          return responseData;
        } catch (e) {
          print('Error decoding response: $e');
          print('Response body: ${response.body}');
          if (response.statusCode == 204) {
            return {'message': 'Links deleted successfully'};
          }
          throw Exception('Invalid response format from server');
        }
      } else {
        String errorMessage;
        try {
          final error = jsonDecode(response.body);
          errorMessage = error['message'] ?? error['error'] ?? 'Unknown error occurred';
        } catch (e) {
          print('Error body: ${response.body}');
          errorMessage = 'Server error: ${response.statusCode}\nResponse: ${response.body}';
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('Error deleting links: $e');
      throw Exception('Failed to delete links: $e');
    }
  }

  static Future<void> updateLinkName(String linkId, String newName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      final response = await http.put(
        Uri.parse('https://linklytics-backend.onrender.com/api/v1/links/$linkId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': newName,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update link name: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to update link name: $e');
    }
  }
}
