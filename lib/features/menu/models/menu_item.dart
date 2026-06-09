class MenuItem {
  final String id;
  final String categoryId;
  final String name;
  final String? description;
  final double price;
  final int prepTimeMinutes;
  final String? imageUrl;
  final bool isAvailable;
  final String? createdAt;

  MenuItem({
    required this.id,
    required this.categoryId,
    required this.name,
    this.description,
    required this.price,
    required this.prepTimeMinutes,
    this.imageUrl,
    required this.isAvailable,
    this.createdAt,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'] as String,
      categoryId: json['category_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      price: (json['price'] as num).toDouble(),
      prepTimeMinutes: json['prep_time_minutes'] as int? ?? 15,
      imageUrl: json['image_url'] as String?,
      isAvailable: json['is_available'] as bool? ?? true,
      createdAt: json['created_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category_id': categoryId,
      'name': name,
      'description': description,
      'price': price,
      'prep_time_minutes': prepTimeMinutes,
      'image_url': imageUrl,
      'is_available': isAvailable,
      'created_at': createdAt,
    };
  }

  MenuItem copyWith({
    String? id,
    String? categoryId,
    String? name,
    String? description,
    double? price,
    int? prepTimeMinutes,
    String? imageUrl,
    bool? isAvailable,
    String? createdAt,
  }) {
    return MenuItem(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      prepTimeMinutes: prepTimeMinutes ?? this.prepTimeMinutes,
      imageUrl: imageUrl ?? this.imageUrl,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
