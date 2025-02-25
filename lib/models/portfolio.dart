class Portfolio {
  final int id;
  final String name;
  final String? description;
  final String endpoint;
  final String? avatar;
  final String createdAt;
  final List<PortfolioLink> links;

  Portfolio({
    required this.id,
    required this.name,
    this.description,
    required this.endpoint,
    this.avatar,
    required this.createdAt,
    required this.links,
  });

  factory Portfolio.fromJson(Map<String, dynamic> json) {
    return Portfolio(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      endpoint: json['endpoint'] as String,
      avatar: json['avatar'] as String?,
      createdAt: json['createdAt'] as String,
      links: (json['links'] as List<dynamic>?)
          ?.map((link) => PortfolioLink.fromJson(link as Map<String, dynamic>))
          .toList() ?? [],
    );
  }
}

class PortfolioLink {
  final int id;
  final String name;
  final String originalUrl;
  final String shortUrl;
  final int clicks;

  PortfolioLink({
    required this.id,
    required this.name,
    required this.originalUrl,
    required this.shortUrl,
    this.clicks = 0,
  });

  factory PortfolioLink.fromJson(Map<String, dynamic> json) {
    return PortfolioLink(
      id: json['id'] as int,
      name: json['name'] as String,
      originalUrl: json['originalUrl'] as String,
      shortUrl: json['shortUrl'] as String,
      clicks: (json['clicks'] as int?) ?? 0,
    );
  }
}
