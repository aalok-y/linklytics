import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import '../controllers/analytics_controller.dart';

class AnalyticsPage extends StatelessWidget {
  AnalyticsPage({Key? key}) : super(key: key);
  
  final controller = Get.put(AnalyticsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Analytics Dashboard'),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDropdowns(),
              SizedBox(height: 24),
              if (controller.selectedLink.value != null) ..._buildCharts(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildDropdowns() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Campaign and Link',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Obx(() => DropdownButtonFormField<Campaign>(
              decoration: InputDecoration(
                labelText: 'Campaign',
                border: OutlineInputBorder(),
              ),
              value: controller.selectedCampaign.value,
              items: controller.campaigns.map((campaign) {
                return DropdownMenuItem(
                  value: campaign,
                  child: Text(campaign.name),
                );
              }).toList(),
              onChanged: controller.onCampaignSelected,
            )),
            SizedBox(height: 16),
            Obx(() => DropdownButtonFormField<Link>(
              decoration: InputDecoration(
                labelText: 'Link',
                border: OutlineInputBorder(),
              ),
              value: controller.selectedLink.value,
              items: (controller.selectedCampaign.value?.links ?? []).map((link) {
                return DropdownMenuItem(
                  value: link,
                  child: Text(link.name.isEmpty ? link.shortUrl : link.name),
                );
              }).toList(),
              onChanged: controller.onLinkSelected,
            )),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCharts() {
    return [
      _buildTimeSeriesChart(),
      SizedBox(height: 24),
      _buildBrowserChart(),
      SizedBox(height: 24),
      _buildOSChart(),
      SizedBox(height: 24),
      _buildDeviceChart(),
      SizedBox(height: 24),
      _buildCountryChart(),
      SizedBox(height: 24),
      _buildRegionChart(),
      SizedBox(height: 24),
      _buildCityChart(),
      SizedBox(height: 24),
      _buildDetailedList(),
    ];
  }

  Widget _buildTimeSeriesChart() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Click Timeline',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Total Clicks: ${controller.analyticsData.length}',
                  style: TextStyle(fontSize: 16, color: Colors.blue),
                ),
              ],
            ),
            SizedBox(height: 16),
            Container(
              height: 300,
              child: controller.timeSeriesData.isEmpty
                  ? Center(child: Text('No timeline data available'))
                  : LineChart(
                      LineChartData(
                        gridData: FlGridData(show: true),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
                          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
                        ),
                        borderData: FlBorderData(show: true),
                        lineBarsData: [
                          LineChartBarData(
                            spots: controller.timeSeriesData,
                            isCurved: true,
                            color: Colors.blue,
                            barWidth: 3,
                            dotData: FlDotData(show: true),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrowserChart() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Browser Distribution',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Container(
              height: 300,
              child: controller.browserData.isEmpty
                  ? Center(child: Text('No browser data available'))
                  : PieChart(
                      PieChartData(
                        sections: controller.browserData,
                        sectionsSpace: 2,
                        centerSpaceRadius: 0,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOSChart() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Operating System Distribution',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Container(
              height: 300,
              child: controller.osData.isEmpty
                  ? Center(child: Text('No OS data available'))
                  : PieChart(
                      PieChartData(
                        sections: controller.osData,
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceChart() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Device Distribution',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Container(
              height: 300,
              child: controller.deviceData.isEmpty
                  ? Center(child: Text('No device data available'))
                  : PieChart(
                      PieChartData(
                        sections: controller.deviceData,
                        sectionsSpace: 2,
                        centerSpaceRadius: 0,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountryChart() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Country Distribution',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Container(
              height: 300,
              child: controller.countryData.isEmpty
                  ? Center(child: Text('No country data available'))
                  : PieChart(
                      PieChartData(
                        sections: controller.countryData,
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegionChart() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Region Distribution',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Container(
              height: 300,
              child: controller.regionData.isEmpty
                  ? Center(child: Text('No region data available'))
                  : PieChart(
                      PieChartData(
                        sections: controller.regionData,
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCityChart() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'City Distribution',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Container(
              height: 300,
              child: controller.cityData.isEmpty
                  ? Center(child: Text('No city data available'))
                  : PieChart(
                      PieChartData(
                        sections: controller.cityData,
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedList() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Detailed Analytics',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            ...controller.analyticsData.map((analytics) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  title: Text('Access Details', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Time: ${analytics.lastAccessed.toLocal()}'),
                      Text('Location: ${analytics.city}, ${analytics.region}, ${analytics.country}'),
                      Text('Device: ${analytics.deviceType}'),
                      Text('Browser: ${analytics.browser}'),
                      Text('OS: ${analytics.os}'),
                    ],
                  ),
                ),
                Divider(),
              ],
            )).toList(),
          ],
        ),
      ),
    );
  }
}