import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class PortfolioAnalyticsPage extends StatefulWidget {
  final int linkId;
  final String linkName;
  final bool isPortfolioView;
  final List<dynamic>? initialAnalytics;

  const PortfolioAnalyticsPage({
    Key? key,
    required this.linkId,
    required this.linkName,
    this.isPortfolioView = true,
    this.initialAnalytics,
  }) : super(key: key);

  @override
  _PortfolioAnalyticsPageState createState() => _PortfolioAnalyticsPageState();
}

class _PortfolioAnalyticsPageState extends State<PortfolioAnalyticsPage> {
  List<dynamic> analytics = [];
  bool isLoading = false;
  String? error;

  @override
  void initState() {
    super.initState();
    if (widget.initialAnalytics != null) {
      analytics = widget.initialAnalytics!;
    } else {
      fetchAnalytics();
    }
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> fetchAnalytics() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Not authenticated');
      }

      final response = await http.get(
        Uri.parse(widget.isPortfolioView 
          ? 'http://localhost:8000/api/v1/portfolio/analytics/${widget.linkId}'
          : 'http://localhost:8000/api/v1/analytics/campaign'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          analytics = data['analytics'];
          isLoading = false;
        });
      } else if (response.statusCode == 204) {
        setState(() {
          analytics = [];
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load analytics');
      }
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Analytics for ${widget.linkName}'),
      ),
      body: RefreshIndicator(
        onRefresh: fetchAnalytics,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : error != null
                ? Center(child: Text(error!))
                : analytics.isEmpty
                    ? const Center(child: Text('No analytics data available'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: analytics.length,
                        itemBuilder: (context, index) {
                          final analytic = analytics[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Access Time:',
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    DateFormat('MMM dd, yyyy HH:mm:ss')
                                        .format(DateTime.parse(analytic['lastAccessed'])),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Device Info:',
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(analytic['deviceInfo'] ?? 'Not available'),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Location:',
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(analytic['location'] ?? 'Not available'),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
      ),
    );
  }
}
