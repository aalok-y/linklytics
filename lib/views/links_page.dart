import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'analytics_page.dart';
import 'portfolio_analytics_page.dart';

class LinksPage extends StatefulWidget {
  const LinksPage({Key? key}) : super(key: key);

  @override
  _LinksPageState createState() => _LinksPageState();
}

class _LinksPageState extends State<LinksPage> {
  bool showPortfolios = true;
  Map<String, dynamic>? portfoliosData;
  Map<String, dynamic>? campaignsData;
  bool isLoadingPortfolios = false;
  bool isLoadingCampaigns = false;

  @override
  void initState() {
    super.initState();
    fetchPortfolios();
    fetchCampaigns();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> fetchPortfolios() async {
    if (isLoadingPortfolios) return;
    setState(() => isLoadingPortfolios = true);
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }
      final response = await http.get(
        Uri.parse('https://linklytics-backend.onrender.com/api/v1/portfolio'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        setState(() {
          portfoliosData = json.decode(response.body);
          isLoadingPortfolios = false;
        });
      } else {
        throw Exception('Failed to load portfolios: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => isLoadingPortfolios = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> fetchCampaigns() async {
    if (isLoadingCampaigns) return;
    setState(() => isLoadingCampaigns = true);
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }
      final response = await http.get(
        Uri.parse('https://linklytics-backend.onrender.com/api/v1/links'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        setState(() {
          campaignsData = json.decode(response.body);
          isLoadingCampaigns = false;
        });
      } else {
        throw Exception('Failed to load campaigns: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => isLoadingCampaigns = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Widget _buildToggleButtons() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: showPortfolios ? Colors.blue : Colors.grey[300],
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => setState(() => showPortfolios = true),
            child: Text(
              'View Portfolios',
              style: TextStyle(
                color: showPortfolios ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: !showPortfolios ? Colors.blue : Colors.grey[300],
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => setState(() => showPortfolios = false),
            child: Text(
              'View Campaigns',
              style: TextStyle(
                color: !showPortfolios ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToPortfolioAnalytics(Map<String, dynamic> link) {
    Get.to(() => PortfolioAnalyticsPage(
      linkId: link['id'] as int,
      linkName: link['name']?.toString() ?? 'Unnamed Link',
    ));
  }

  void _navigateToCampaignAnalytics(Map<String, dynamic> campaign) {
    Get.to(() => AnalyticsPage());
  }

  Widget _buildPortfolioCard(Map<String, dynamic> portfolio) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (portfolio['avatar'] != null && portfolio['avatar'].toString().isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                portfolio['avatar'].toString(),
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    width: double.infinity,
                    color: Colors.grey[200],
                    child: const Icon(Icons.image_not_supported, size: 50),
                  );
                },
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  portfolio['name']?.toString() ?? 'Untitled Portfolio',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  portfolio['description']?.toString() ?? 'No description',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Links:',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                if (portfolio['links'] != null && portfolio['links'] is List && (portfolio['links'] as List).isNotEmpty)
                  Column(
                    children: List<Widget>.from(
                      (portfolio['links'] as List).map((link) => ListTile(
                        leading: const Icon(Icons.link),
                        title: Text(link['name']?.toString() ?? 'Unnamed Link'),
                        subtitle: Text(link['originalUrl']?.toString() ?? ''),
                        trailing: Text('Clicks: ${link['clicks']?.toString() ?? '0'}'),
                        onTap: () => _navigateToPortfolioAnalytics(link),
                      )),
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('No links available'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCampaignCard(Map<String, dynamic> campaign) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () => _navigateToCampaignAnalytics(campaign),
              child: Text(
                campaign['campaignName'],
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Links:',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ...List<Widget>.from(
              (campaign['links'] as List).map((link) => ListTile(
                leading: const Icon(Icons.link),
                title: Text(link['linkName']),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(link['originalUrl']),
                    Text(
                      'Created: ${DateFormat('MMM dd, yyyy').format(DateTime.parse(link['createdAt']))}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
                trailing: SelectableText(link['shortUrl']),
              )),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildToggleButtons(),
          Expanded(
              child: showPortfolios
                  ? isLoadingPortfolios
                      ? const Center(child: CircularProgressIndicator())
                      : portfoliosData != null
                          ? RefreshIndicator(
                              onRefresh: fetchPortfolios,
                              child: ListView.builder(
                              padding: const EdgeInsets.all(8.0),
                              itemCount: (portfoliosData?['portfolios'] as List?)?.length ?? 0,
                              itemBuilder: (context, index) {
                                final portfolio = portfoliosData!['portfolios'][index];
                                return _buildPortfolioCard(portfolio);
                              },
                            ),
                            )
                          : RefreshIndicator(
                              onRefresh: fetchPortfolios,
                              child: const Center(child: Text('No portfolios found')),
                            )
                  : isLoadingCampaigns
                      ? const Center(child: CircularProgressIndicator())
                      : campaignsData != null
                          ? RefreshIndicator(
                              onRefresh: fetchCampaigns,
                              child: ListView.builder(
                              padding: const EdgeInsets.all(8.0),
                              itemCount: (campaignsData?['campaigns'] as List?)?.length ?? 0,
                              itemBuilder: (context, index) {
                                final campaign = campaignsData!['campaigns'][index];
                                return _buildCampaignCard(campaign);
                              },
                            ),
                            )
                          : RefreshIndicator(
                              onRefresh: fetchCampaigns,
                              child: const Center(child: Text('No campaigns found')),
                            ),
            ),
        ],
      ),
    );
  }
}
