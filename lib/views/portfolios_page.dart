import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/portfolio_controller.dart';

class PortfoliosPage extends StatelessWidget {
  PortfoliosPage({super.key});

  final portfolioController = Get.find<PortfolioController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Portfolios'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => Get.toNamed('/create-portfolio'),
          ),
        ],
      ),
      body: Obx(
        () => portfolioController.isLoading.value
            ? Center(child: CircularProgressIndicator())
            : portfolioController.portfolios.isEmpty
                ? Center(
                    child: Text(
                      'No portfolios yet. Create one!',
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    itemCount: portfolioController.portfolios.length,
                    itemBuilder: (context, index) {
                      final portfolio = portfolioController.portfolios[index];
                      return Card(
                        margin: EdgeInsets.all(8),
                        child: ExpansionTile(
                          leading: portfolio.avatar != null
                              ? CircleAvatar(
                                  backgroundImage: NetworkImage(portfolio.avatar!),
                                )
                              : CircleAvatar(
                                  child: Text(portfolio.name[0].toUpperCase()),
                                ),
                          title: Text(
                            portfolio.name,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: portfolio.description != null
                              ? Text(portfolio.description!)
                              : null,
                          children: [
                            if (portfolio.links.isNotEmpty)
                              Padding(
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Links',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    ...portfolio.links.map((link) => Padding(
                                          padding: EdgeInsets.only(bottom: 8),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${link.name}',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                'Original URL: ${link.originalUrl}',
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                              Text(
                                                'Short URL: ${link.shortUrl}',
                                                style: TextStyle(
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                ),
                                              ),
                                              Text(
                                                'Clicks: ${link.clicks}',
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                        )),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed('/create-portfolio'),
        child: Icon(Icons.add),
        tooltip: 'Create Portfolio',
      ),
    );
  }
}
