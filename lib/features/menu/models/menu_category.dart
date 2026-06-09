class MenuCategory {
  final String id;
  final String name;
  final String? icon;
  final String? color;
  final int sortOrder;
  final bool isActive;

  MenuCategory({
    required this.id,
    required this.name,
    this.icon,
    this.color,
    required this.sortOrder,
    required this.isActive,
  });

  factory MenuCategory.fromJson(Map<String, dynamic> json) {
    return MenuCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String?,
      color: json['color'] as String?,
      sortOrder: json['sort_order'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'color': color,
      'sort_order': sortOrder,
      'is_active': isActive,
    };
  }
}
