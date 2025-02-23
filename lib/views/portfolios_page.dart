import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/portfolio_controller.dart';

class PortfoliosPage extends StatelessWidget {
  final portfolioController = Get.find<PortfolioController>();

  PortfoliosPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Portfolios'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (portfolioController.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        if (portfolioController.portfolios.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.work_outline,
                  size: 64,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'No portfolios yet',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () => Get.toNamed('/create-portfolio'),
                  icon: Icon(Icons.add),
                  label: Text('Create Portfolio'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: portfolioController.portfolios.length,
          itemBuilder: (context, index) {
            final portfolio = portfolioController.portfolios[index];
            return Card(
              margin: EdgeInsets.only(bottom: 16),
              child: Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.all(16),
                    title: Text(
                      portfolio.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: portfolio.description != null
                        ? Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Text(
                              portfolio.description!,
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                          )
                        : null,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.analytics),
                          onPressed: () {
                            // Navigate to portfolio analytics
                            Get.toNamed('/analytics', arguments: portfolio);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            // Navigate to edit portfolio
                            Get.toNamed('/edit-portfolio', arguments: portfolio);
                          },
                        ),
                      ],
                    ),
                  ),
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
                                child: Text(
                                  link['shortUrl'] ?? '',
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              )),
                        ],
                      ),
                    ),
                ],
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed('/create-portfolio'),
        child: Icon(Icons.add),
        tooltip: 'Create Portfolio',
      ),
    );
  }
}
