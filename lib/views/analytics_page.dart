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
              _buildViewToggle(context),
              SizedBox(height: 24),
              if (!controller.isPortfolioView.value) ...[
                _buildDropdowns(),
                SizedBox(height: 24),
                if (controller.selectedLink.value != null) ..._buildCharts(),
              ] else ...[
                _buildPortfolioDropdown(),
                SizedBox(height: 24),
                if (controller.selectedPortfolio.value != null) ..._buildCharts(),
              ],
            ],
          ),
        );
      }),
    );
  }

  Widget _buildViewToggle(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Analytics Type',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => controller.toggleView(false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: !controller.isPortfolioView.value 
                          ? Theme.of(context).primaryColor 
                          : null,
                      foregroundColor: !controller.isPortfolioView.value 
                          ? Colors.white
                          : Theme.of(context).primaryColor,
                    ),
                    child: Text('Campaign Analytics'),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => controller.toggleView(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: controller.isPortfolioView.value 
                          ? Theme.of(context).primaryColor 
                          : null,
                      foregroundColor: controller.isPortfolioView.value 
                          ? Colors.white
                          : Theme.of(context).primaryColor,
                    ),
                    child: Text('Portfolio Analytics'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
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

  Widget _buildPortfolioDropdown() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Portfolio',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Obx(() {
              print('Building dropdown. Portfolios: ${controller.portfolios.length}'); 
              print('Selected portfolio: ${controller.selectedPortfolio.value?.name}'); 
              
              return DropdownButtonFormField<Portfolio>(
                value: controller.selectedPortfolio.value,
                hint: Text('Select a portfolio'),
                isExpanded: true,
                items: controller.portfolios.map((portfolio) {
                  return DropdownMenuItem(
                    value: portfolio,
                    child: Text(portfolio.name),
                  );
                }).toList(),
                onChanged: (portfolio) {
                  print('Dropdown onChanged: ${portfolio?.name}'); 
                  controller.onPortfolioSelected(portfolio);
                },
              );
            }),
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
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: true,
                          horizontalInterval: 1,
                        ),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 1,
                              reservedSize: 40,
                            ),
                            axisNameWidget: Text('Clicks per Hour'),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 6,
                              reservedSize: 40,
                            ),
                            axisNameWidget: Text('Time (hours)'),
                          ),
                        ),
                        borderData: FlBorderData(show: true),
                        minX: 0,
                        maxX: (controller.timeSeriesData.length - 1).toDouble(),
                        minY: 0,
                        maxY: controller.timeSeriesData.isEmpty ? 1 : 
                             controller.timeSeriesData.map((spot) => spot.y).reduce((a, b) => a > b ? a : b) + 1,
                        lineBarsData: [
                          LineChartBarData(
                            spots: controller.timeSeriesData,
                            isCurved: true,
                            color: Colors.blue,
                            barWidth: 2,
                            isStrokeCapRound: true,
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, barData, index) {
                                return FlDotCirclePainter(
                                  radius: 4,
                                  color: Colors.blue,
                                  strokeWidth: 1,
                                  strokeColor: Colors.white,
                                );
                              },
                            ),
                            belowBarData: BarAreaData(
                              show: true,
                              color: Colors.blue.withOpacity(0.2),
                            ),
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
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: controller.deviceData,
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
            SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: controller.analyticsData
                  .map((analytics) => analytics.device ?? 'Unknown')
                  .toSet()
                  .map((device) => Chip(
                        label: Text(device),
                        backgroundColor: Colors.blue.withOpacity(0.1),
                      ))
                  .toList(),
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
                Divider(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Time: ${analytics.lastAccessed.toLocal()}'),
                    Text('Location: ${analytics.city ?? "Unknown"}, ${analytics.region ?? "Unknown"}, ${analytics.country ?? "Unknown"}'),
                    Text('Device: ${analytics.device ?? "Unknown"}'),
                    Text('Browser: ${analytics.browser ?? "Unknown"}'),
                    Text('OS: ${analytics.os ?? "Unknown"}'),
                  ],
                ),
              ],
            )).toList(),
          ],
        ),
      ),
    );
  }
}