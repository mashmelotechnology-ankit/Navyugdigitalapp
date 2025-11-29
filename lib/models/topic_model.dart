class TopicModel {
  final int id;
  final String title;
  final String description;
  final String image;
  final bool status;
  final int webinarsCount;
  final String createdAt;
  final String updatedAt;

  TopicModel({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
    required this.status,
    required this.webinarsCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TopicModel.fromJson(Map<String, dynamic> json) {
    return TopicModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      image: json['image'] ?? '',
      status: json['status'] ?? false,
      webinarsCount: json['webinars_count'] ?? 0,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'image': image,
      'status': status,
      'webinars_count': webinarsCount,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
