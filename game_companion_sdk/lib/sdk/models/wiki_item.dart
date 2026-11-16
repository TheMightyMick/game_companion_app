class WikiItem {
  final String id;
  final String title;
  final String category;
  final String? subCategory;
  final Map<String, dynamic> stats;
  final String description;
  final String thumbnailUrl;
  final List<String> acquisitionTips;
  final List<String> spawnLocations;
  final String? relatedPoiId;

  WikiItem({
    required this.id,
    required this.title,
    required this.category,
    this.subCategory,
    required this.stats,
    required this.description,
    required this.thumbnailUrl,
    this.acquisitionTips = const [],
    this.spawnLocations = const [],
    this.relatedPoiId,
  });

  factory WikiItem.fromJson(Map<String, dynamic> json) {
    return WikiItem(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? 'Unknown',
      category: json['category'] as String? ?? 'Uncategorized',
      subCategory: json['subCategory'] as String?,
      stats: json['stats'] as Map<String, dynamic>? ?? {},
      description: json['description'] as String? ?? '',
      thumbnailUrl: json['thumbnailUrl'] as String? ?? '',
      acquisitionTips: (json['acquisitionTips'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      spawnLocations: (json['spawnLocations'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      relatedPoiId: json['relatedPoiId'] as String?,
    );
  }
}
