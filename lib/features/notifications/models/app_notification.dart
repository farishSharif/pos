class AppNotification {
  final String id;
  final String title;
  final String? body;
  final String type; // 'order_ready','low_stock','payment','new_order','general'
  final String? targetRole;
  final bool isRead;
  final String createdAt;

  AppNotification({
    required this.id,
    required this.title,
    this.body,
    required this.type,
    this.targetRole,
    required this.isRead,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String?,
      type: json['type'] as String? ?? 'general',
      targetRole: json['target_role'] as String?,
      isRead: json['is_read'] as bool? ?? false,
      createdAt: json['created_at'] as String? ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'type': type,
      'target_role': targetRole,
      'is_read': isRead,
      'created_at': createdAt,
    };
  }
}
