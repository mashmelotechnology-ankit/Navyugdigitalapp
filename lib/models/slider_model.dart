class SliderModel {
  final int id;
  final String title;
  final String image;
  final bool status;
  final int sort;
  final String createdAt;
  final String updatedAt;

  SliderModel({
    required this.id,
    required this.title,
    required this.image,
    required this.status,
    required this.sort,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SliderModel.fromJson(Map<String, dynamic> json) {
    return SliderModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      image: json['image'] ?? '',
      status: json['status'] ?? false,
      sort: json['sort'] ?? 0,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'image': image,
      'status': status,
      'sort': sort,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
