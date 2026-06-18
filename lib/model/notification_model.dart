class NotificationModel {
  final String title;
  final String message;
  final String scheduledAt;

  NotificationModel({
    required this.title,
    required this.message,
    required this.scheduledAt,
  });

  // Factory untuk mengubah JSON dari Laravel menjadi Object Dart
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      title: json['title'],
      message: json['message'],
      scheduledAt: json['scheduled_at'],
    );
  }
}