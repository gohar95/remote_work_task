class RecordModel {
  final String id;
  final String userId;
  final String title;
  final String? imageUrl;
  final String? pdfUrl;
  final DateTime createdAt;

  RecordModel({
    required this.id,
    required this.userId,
    required this.title,
    this.imageUrl,
    this.pdfUrl,
    required this.createdAt,
  });

  factory RecordModel.fromJson(Map<String, dynamic> json) {
    return RecordModel(
      id: json['id'],
      userId: json['user_id'] ?? '',
      title: json['title'] ?? '',
      imageUrl: json['image_url'],
      pdfUrl: json['pdf_url'],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'image_url': imageUrl,
      'pdf_url': pdfUrl,
      'user_id': userId,
    };
  }
}
