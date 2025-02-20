import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Campaign {
  final int id;
  final String name;
  final List<Link> links;

  Campaign({required this.id, required this.name, required this.links});

  factory Campaign.fromJson(Map<String, dynamic> json) {
    return Campaign(
      id: json['campaignId'],
      name: json['campaignName'],
      links: (json['links'] as List)
          .map((link) => Link.fromJson(link))
          .toList(),
    );
  }
}

class Link {
  final int id;
  final String name;
  final String originalUrl;
  final String shortUrl;
  final DateTime createdAt;

  Link({
    required this.id,
    required this.name,
    required this.originalUrl,
    required this.shortUrl,
    required this.createdAt,
  });

  factory Link.fromJson(Map<String, dynamic> json) {
    return Link(
      id: json['linkId'],
      name: json['linkName'],
      originalUrl: json['originalUrl'],
      shortUrl: json['shortUrl'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class Analytics {
  final int id;
  final int linkId;
  final DateTime lastAccessed;
  final String country;
  final String region;
  final String city;
  final String deviceType;
  final String browser;
  final String os;

  Analytics({
    required this.id,
    required this.linkId,
    required this.lastAccessed,
    required this.country,
    required this.region,
    required this.city,
    required this.deviceType,
    required this.browser,
    required this.os,
  });

  factory Analytics.fromJson(Map<String, dynamic> json) {
    return Analytics(
      id: json['id'],
      linkId: json['linkId'],
      lastAccessed: DateTime.parse(json['lastAccessed']),
      country: json['country'],
      region: json['region'],
      city: json['city'],
      deviceType: json['deviceType'],
      browser: json['browser'],
      os: json['os'],
    );
  }
}

class AnalyticsController extends GetxController {
  var isLoading = true.obs;
  var campaigns = <Campaign>[].obs;
  var selectedCampaign = Rxn<Campaign>();
  var selectedLink = Rxn<Link>();
  var analyticsData = <Analytics>[].obs;

  // Chart data
  var browserData = <PieChartSectionData>[].obs;
  var osData = <PieChartSectionData>[].obs;
  var deviceData = <PieChartSectionData>[].obs;
  var countryData = <PieChartSectionData>[].obs;
  var regionData = <PieChartSectionData>[].obs;
  var cityData = <PieChartSectionData>[].obs;
  var timeSeriesData = <FlSpot>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchCampaigns();
  }

  Future<void> fetchCampaigns() async {
    try {
      isLoading(true);
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      final response = await http.get(
        Uri.parse('http://localhost:8000/api/v1/links'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        campaigns.value = (data['campaigns'] as List)
            .map((campaign) => Campaign.fromJson(campaign))
            .toList();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch campaigns');
    } finally {
      isLoading(false);
    }
  }

  void onCampaignSelected(Campaign? campaign) {
    selectedCampaign.value = campaign;
    selectedLink.value = null;
    analyticsData.clear();
    _clearChartData();
  }

  void onLinkSelected(Link? link) {
    selectedLink.value = link;
    if (link != null) {
      fetchAnalytics(link.id);
    } else {
      analyticsData.clear();
      _clearChartData();
    }
  }

  void _clearChartData() {
    browserData.clear();
    osData.clear();
    deviceData.clear();
    countryData.clear();
    regionData.clear();
    cityData.clear();
    timeSeriesData.clear();
  }

  Future<void> fetchAnalytics(int linkId) async {
    try {
      isLoading(true);
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      final response = await http.get(
        Uri.parse('http://localhost:8000/api/v1/analytics/$linkId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        analyticsData.value = (data['analytics'] as List)
            .map((analytics) => Analytics.fromJson(analytics))
            .toList();
        _processAnalyticsData();
      } else if (response.statusCode == 204) {
        analyticsData.clear();
        _clearChartData();
        Get.snackbar('Info', 'No analytics data available for this link');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch analytics');
    } finally {
      isLoading(false);
    }
  }

  void _processAnalyticsData() {
    _processBrowserData();
    _processDeviceData();
    _processLocationData();
    _processTimeSeriesData();
  }

  void _processBrowserData() {
    final browserCounts = <String, int>{};
    final osCounts = <String, int>{};
    
    for (var analytics in analyticsData) {
      browserCounts[analytics.browser] = (browserCounts[analytics.browser] ?? 0) + 1;
      osCounts[analytics.os] = (osCounts[analytics.os] ?? 0) + 1;
    }
    
    browserData.value = _createPieChartData(browserCounts);
    osData.value = _createPieChartData(osCounts);
  }

  List<PieChartSectionData> _createPieChartData(Map<String, int> data) {
    final total = data.values.reduce((a, b) => a + b);
    return data.entries.map((entry) {
      final percentage = (entry.value / total * 100).toStringAsFixed(1);
      return PieChartSectionData(
        title: '${entry.key}\n$percentage%',
        value: entry.value.toDouble(),
        color: _getRandomColor(entry.key.hashCode),
        radius: 100,
        titleStyle: TextStyle(color: Colors.white, fontSize: 14),
        showTitle: true,
      );
    }).toList();
  }

  void _processDeviceData() {
    final deviceCounts = <String, int>{};
    for (var analytics in analyticsData) {
      deviceCounts[analytics.deviceType] = (deviceCounts[analytics.deviceType] ?? 0) + 1;
    }
    
    deviceData.value = deviceCounts.entries.map((entry) {
      final total = deviceCounts.values.reduce((a, b) => a + b);
      final percentage = (entry.value / total * 100).toStringAsFixed(1);
      return PieChartSectionData(
        title: '${entry.key}\n$percentage%',
        value: entry.value.toDouble(),
        color: _getRandomColor(entry.key.hashCode),
        radius: 100,
        titleStyle: TextStyle(color: Colors.white, fontSize: 14),
      );
    }).toList();
  }

  void _processLocationData() {
    final countryCounts = <String, int>{};
    final regionCounts = <String, int>{};
    final cityCounts = <String, int>{};
    
    for (var analytics in analyticsData) {
      countryCounts[analytics.country] = (countryCounts[analytics.country] ?? 0) + 1;
      regionCounts[analytics.region] = (regionCounts[analytics.region] ?? 0) + 1;
      cityCounts[analytics.city] = (cityCounts[analytics.city] ?? 0) + 1;
    }
    
    countryData.value = _createPieChartData(countryCounts);
    regionData.value = _createPieChartData(regionCounts);
    cityData.value = _createPieChartData(cityCounts);
  }

  void _processTimeSeriesData() {
    if (analyticsData.isEmpty) {
      timeSeriesData.clear();
      return;
    }

    final sortedData = analyticsData.toList()
      ..sort((a, b) => a.lastAccessed.compareTo(b.lastAccessed));
    
    // Group clicks by hour
    final clicksByHour = <DateTime, int>{};
    for (var analytics in sortedData) {
      final hourKey = DateTime(
        analytics.lastAccessed.year,
        analytics.lastAccessed.month,
        analytics.lastAccessed.day,
        analytics.lastAccessed.hour,
      );
      clicksByHour[hourKey] = (clicksByHour[hourKey] ?? 0) + 1;
    }

    // Create spots for the line chart
    final spots = <FlSpot>[];
    final startTime = sortedData.first.lastAccessed;
    final endTime = sortedData.last.lastAccessed;
    
    // Fill in all hours between start and end time
    var currentHour = DateTime(
      startTime.year,
      startTime.month,
      startTime.day,
      startTime.hour,
    );

    int index = 0;
    while (currentHour.isBefore(endTime) || currentHour.isAtSameMomentAs(endTime)) {
      spots.add(FlSpot(
        index.toDouble(),
        (clicksByHour[currentHour] ?? 0).toDouble(),
      ));
      currentHour = currentHour.add(Duration(hours: 1));
      index++;
    }

    timeSeriesData.value = spots;
  }

  Color _getRandomColor(int seed) {
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
    ];
    return colors[seed % colors.length];
  }
}