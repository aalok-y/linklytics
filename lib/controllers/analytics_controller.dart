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
      links:
          (json['links'] as List).map((link) => Link.fromJson(link)).toList(),
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

class Portfolio {
  final int id;
  final String name;
  final List<Analytics> analytics;

  Portfolio({required this.id, required this.name, required this.analytics});

  factory Portfolio.fromJson(Map<String, dynamic> json) {
    return Portfolio(
      id: json['portfolioId'] as int,
      name: json['portfolioName'] as String,
      analytics:
          (json['analytics'] as List? ?? [])
              .map((a) => Analytics.fromJson(a))
              .toList(),
    );
  }

  @override
  String toString() => name; // For dropdown display
}

class Analytics {
  final int id;
  final int? linkId;
  final int? portfolioLinkId;
  final DateTime lastAccessed;
  final String? ipAddress;
  final String? country;
  final String? region;
  final String? city;
  final String? device;
  final String? browser;
  final String? os;
  final DateTime updatedAt;

  Analytics({
    required this.id,
    this.linkId,
    this.portfolioLinkId,
    required this.lastAccessed,
    this.ipAddress,
    this.country,
    this.region,
    this.city,
    this.device,
    this.browser,
    this.os,
    required this.updatedAt,
  });

  factory Analytics.fromJson(Map<String, dynamic> json) {
    return Analytics(
      id: json['id'] as int,
      linkId: json['linkId'] as int?,
      portfolioLinkId: json['portfolioLinkId'] as int?,
      lastAccessed: DateTime.parse(json['lastAccessed'] as String),
      ipAddress: json['ipAddress'] as String?,
      country: json['country'] as String?,
      region: json['region'] as String?,
      city: json['city'] as String?,
      device: json['deviceType'] as String?,
      browser: json['browser'] as String?,
      os: json['os'] as String?,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

class AnalyticsController extends GetxController {
  var isLoading = true.obs;
  var campaigns = <Campaign>[].obs;
  var portfolios = <Portfolio>[].obs;
  var selectedCampaign = Rxn<Campaign>();
  var selectedLink = Rxn<Link>();
  var selectedPortfolio = Rxn<Portfolio>();
  var analyticsData = <Analytics>[].obs;
  var isPortfolioView = false.obs;

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
        Uri.parse('https://linklytics-backend.onrender.com/api/v1/links'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        campaigns.value =
            (data['campaigns'] as List)
                .map((campaign) => Campaign.fromJson(campaign))
                .toList();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch campaigns');
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchPortfolios() async {
    try {
      isLoading(true);
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.get(
        Uri.parse(
          'https://linklytics-backend.onrender.com/api/v1/portfolios/analytics',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('Portfolio response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        portfolios.value =
            (data['analytics'] as List)
                .map((portfolio) => Portfolio.fromJson(portfolio))
                .toList();
        print('Fetched portfolios: ${portfolios.length}');
      } else {
        print('Failed to fetch portfolios: ${response.statusCode}');
        Get.snackbar('Error', 'Failed to fetch portfolios');
      }
    } catch (e) {
      print('Error fetching portfolios: $e');
      Get.snackbar('Error', 'Failed to fetch portfolios');
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

  void onPortfolioSelected(Portfolio? portfolio) {
    print('Selected portfolio: ${portfolio?.name}');
    selectedPortfolio.value = portfolio;
    if (portfolio != null) {
      analyticsData.value = portfolio.analytics;
      if (analyticsData.isNotEmpty) {
        _processAnalyticsData();
      } else {
        _clearChartData();
        Get.snackbar('Info', 'No analytics data available for this portfolio');
      }
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
        Uri.parse(
          'https://linklytics-backend.onrender.com/api/v1/analytics/$linkId',
        ),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        analyticsData.value =
            (data['analytics'] as List)
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
      var browser =
          analytics.browser?.trim().isEmpty == true
              ? 'Unknown'
              : (analytics.browser ?? 'Unknown');
      var os =
          analytics.os?.trim().isEmpty == true
              ? 'Unknown'
              : (analytics.os ?? 'Unknown');

      browserCounts[browser] = (browserCounts[browser] ?? 0) + 1;
      osCounts[os] = (osCounts[os] ?? 0) + 1;
    }

    browserData.value = _createPieChartData(browserCounts);
    osData.value = _createPieChartData(osCounts);
  }

  void _processDeviceData() {
    final deviceCounts = <String, int>{};
    for (var analytics in analyticsData) {
      var device =
          analytics.device?.trim().isEmpty == true
              ? 'Unknown'
              : (analytics.device ?? 'Unknown');
      deviceCounts[device] = (deviceCounts[device] ?? 0) + 1;
    }

    deviceData.value = _createPieChartData(deviceCounts);
  }

  void _processLocationData() {
    final countryCounts = <String, int>{};
    final regionCounts = <String, int>{};
    final cityCounts = <String, int>{};

    for (var analytics in analyticsData) {
      var country =
          analytics.country?.trim().isEmpty == true
              ? 'Unknown'
              : (analytics.country ?? 'Unknown');
      var region =
          analytics.region?.trim().isEmpty == true
              ? 'Unknown'
              : (analytics.region ?? 'Unknown');
      var city =
          analytics.city?.trim().isEmpty == true
              ? 'Unknown'
              : (analytics.city ?? 'Unknown');

      countryCounts[country] = (countryCounts[country] ?? 0) + 1;
      regionCounts[region] = (regionCounts[region] ?? 0) + 1;
      cityCounts[city] = (cityCounts[city] ?? 0) + 1;
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

    final sortedData =
        analyticsData.toList()
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
    while (currentHour.isBefore(endTime) ||
        currentHour.isAtSameMomentAs(endTime)) {
      spots.add(
        FlSpot(index.toDouble(), (clicksByHour[currentHour] ?? 0).toDouble()),
      );
      currentHour = currentHour.add(Duration(hours: 1));
      index++;
    }

    timeSeriesData.value = spots;
  }

  void toggleView(bool isPortfolio) async {
    isPortfolioView.value = isPortfolio;
    _clearChartData();
    analyticsData.clear();
    selectedCampaign.value = null;
    selectedLink.value = null;
    selectedPortfolio.value = null;

    if (isPortfolio) {
      await fetchPortfolios();
      if (portfolios.isEmpty) {
        Get.snackbar('Info', 'No portfolios available');
      }
    }
  }

  // Keep track of used colors to ensure unique colors for each section
  final List<Color> _usedColors = [];
  final List<Color> _availableColors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
    Colors.cyan,
    Colors.amber,
    Colors.deepPurple,
    Colors.lightBlue,
  ];

  Color _getRandomColor(int seed) {
    if (_usedColors.length >= _availableColors.length) {
      _usedColors.clear(); // Reset if we've used all colors
    }

    // Find first unused color
    Color color = _availableColors.firstWhere(
      (c) => !_usedColors.contains(c),
      orElse: () => _availableColors[0],
    );

    _usedColors.add(color);
    return color;
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
}
