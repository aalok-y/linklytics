class Campaign {
  final String id;
  final String campaignName;
  final List<Link> links;

  Campaign({
    required this.id,
    required this.campaignName,
    required this.links,
  });

  factory Campaign.fromJson(Map<String, dynamic> json) {
    return Campaign(
      id: json['id'],
      campaignName: json['campaignName'],
      links: (json['links'] as List<dynamic>?)
          ?.map((link) => Link.fromJson(link))
          .toList() ?? [],
    );
  }
}

class Link {
  final String id;
  final String originalUrl;
  final String shortUrl;
  final String? linkName;
  final int clicks;
  final String campaignId;
  final DateTime createdAt;

  Link({
    required this.id,
    required this.originalUrl,
    required this.shortUrl,
    this.linkName,
    required this.clicks,
    required this.campaignId,
    required this.createdAt,
  });

  factory Link.fromJson(Map<String, dynamic> json) {
    return Link(
      id: json['id'],
      originalUrl: json['originalUrl'],
      shortUrl: json['shortUrl'],
      linkName: json['linkName'],
      clicks: json['clicks'] ?? 0,
      campaignId: json['campaignId'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}
