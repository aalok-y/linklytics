import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:linklytics/controllers/portfolio_controller.dart';
import 'package:linklytics/models/portfolio.dart';
import 'package:linklytics/widgets/qr_code_dialog.dart';
import 'package:linklytics/api/api_service.dart';

class PortfoliosPage extends StatelessWidget {
  PortfoliosPage({super.key});

  final portfolioController = Get.find<PortfolioController>();

  void _showEditPortfolioDialog(BuildContext context, Portfolio portfolio) {
    final nameController = TextEditingController(text: portfolio.name);
    final descriptionController = TextEditingController(text: portfolio.description);
    final endpointController = TextEditingController(text: portfolio.endpoint);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.edit, color: Theme.of(context).primaryColor),
            SizedBox(width: 8),
            Text('Edit Portfolio'),
          ],
        ),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Portfolio Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Portfolio name is required';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description (Optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: endpointController,
                  decoration: InputDecoration(
                    labelText: 'Custom Endpoint',
                    border: OutlineInputBorder(),
                    helperText: 'Must be at least 3 characters',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().length < 3) {
                      return 'Endpoint must be at least 3 characters';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;

              try {
                await ApiService.updatePortfolio(
                  portfolioId: portfolio.id.toString(),
                  portName: nameController.text.trim(),
                  description: descriptionController.text.trim(),
                  endpoint: endpointController.text.trim(),
                );

                Get.snackbar(
                  'Success',
                  'Portfolio updated successfully',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.green[100],
                );

                await portfolioController.fetchPortfolios();
                if (context.mounted) {
                  Navigator.pop(context);
                }
              } catch (e) {
                Get.snackbar(
                  'Error',
                  'Failed to update portfolio: ${e.toString()}',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red[100],
                );
              }
            },
            icon: Icon(Icons.save),
            label: Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  void _showEditLinksDialog(BuildContext context, Portfolio portfolio) {
    final links = portfolio.links.map((link) => {
      'name': link.name,
      'link': link.originalUrl,
    }).toList();
    
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.link, color: Theme.of(context).primaryColor),
            SizedBox(width: 8),
            Text('Edit Portfolio Links'),
          ],
        ),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ...links.asMap().entries.map((entry) {
                  final nameController = TextEditingController(text: entry.value['name']);
                  final urlController = TextEditingController(text: entry.value['link']);
                  
                  return Padding(
                    padding: EdgeInsets.only(bottom: 16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Link ${entry.key + 1}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                links.removeAt(entry.key);
                                (context as Element).markNeedsBuild();
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        TextFormField(
                          controller: nameController,
                          decoration: InputDecoration(
                            labelText: 'Link Name',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Link name is required';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            links[entry.key]['name'] = value;
                          },
                        ),
                        SizedBox(height: 8),
                        TextFormField(
                          controller: urlController,
                          decoration: InputDecoration(
                            labelText: 'URL',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'URL is required';
                            }
                            try {
                              final uri = Uri.parse(value);
                              if (!uri.hasScheme || !uri.hasAuthority) {
                                return 'Please enter a valid URL';
                              }
                            } catch (e) {
                              return 'Please enter a valid URL';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            links[entry.key]['link'] = value;
                          },
                        ),
                      ],
                    ),
                  );
                }).toList(),
                ElevatedButton.icon(
                  onPressed: () {
                    links.add({
                      'name': '',
                      'link': '',
                    });
                    (context as Element).markNeedsBuild();
                  },
                  icon: Icon(Icons.add),
                  label: Text('Add Link'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;

              try {
                await ApiService.updatePortfolio(
                  portfolioId: portfolio.id.toString(),
                  links: links,
                );

                Get.snackbar(
                  'Success',
                  'Portfolio links updated successfully',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.green[100],
                );

                await portfolioController.fetchPortfolios();
                if (context.mounted) {
                  Navigator.pop(context);
                }
              } catch (e) {
                Get.snackbar(
                  'Error',
                  'Failed to update portfolio links: ${e.toString()}',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red[100],
                );
              }
            },
            icon: Icon(Icons.save),
            label: Text('Save Links'),
          ),
        ],
      ),
    );
  }

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
            : RefreshIndicator(
                onRefresh: () async {
                  await portfolioController.fetchPortfolios();
                },
                child: portfolioController.portfolios.isEmpty
                    ? ListView(
                        children: [
                          SizedBox(height: MediaQuery.of(context).size.height / 3),
                          Center(
                            child: Text(
                              'No portfolios yet. Create one!',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      )
                    : ListView.builder(
                        physics: AlwaysScrollableScrollPhysics(),
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
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 1.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          portfolio.description ?? 'No description',
                                          style: TextStyle(color: Colors.grey[600]),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'linklytics-backend.onrender.com/p/${portfolio.endpoint}',
                                          style: TextStyle(
                                            color: Theme.of(context).primaryColor,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.copy, size: 16),
                                        onPressed: () {
                                          final fullUrl = 'https://linklytics-backend.onrender.com/p/${portfolio.endpoint}';
                                          Clipboard.setData(ClipboardData(text: fullUrl));
                                          Get.snackbar(
                                            'Copied',
                                            'Portfolio URL copied to clipboard',
                                            snackPosition: SnackPosition.BOTTOM,
                                          );
                                        },
                                        tooltip: 'Copy Portfolio URL',
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.qr_code, size: 16),
                                        onPressed: () {
                                          final fullUrl = 'https://linklytics-backend.onrender.com/p/${portfolio.endpoint}';
                                          showDialog(
                                            context: context,
                                            builder: (context) => QRCodeDialog(
                                              url: fullUrl,
                                              title: portfolio.name,
                                            ),
                                          );
                                        },
                                        tooltip: 'Generate QR Code',
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.edit, size: 16),
                                        onPressed: () => _showEditPortfolioDialog(context, portfolio),
                                        tooltip: 'Edit Portfolio',
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: () => _showEditLinksDialog(context, portfolio),
                                    tooltip: 'Edit Links',
                                  ),
                                ],
                              ),
                              children: [
                                if (portfolio.links.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Links',
                                          style: Theme.of(context).textTheme.titleMedium,
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed('/create-portfolio'),
        child: Icon(Icons.add),
        tooltip: 'Create Portfolio',
      ),
    );
  }
}
