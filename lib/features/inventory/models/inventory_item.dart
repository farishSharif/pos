class InventoryItem {
  final String id;
  final String name;
  final String unit; // 'kg', 'litre', 'g', etc.
  final double currentStock;
  final double minimumStock;
  final String? updatedAt;

  InventoryItem({
    required this.id,
    required this.name,
    required this.unit,
    required this.currentStock,
    required this.minimumStock,
    this.updatedAt,
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      id: json['id'] as String,
      name: json['name'] as String,
      unit: json['unit'] as String? ?? 'kg',
      currentStock: (json['current_stock'] as num? ?? 0.0).toDouble(),
      minimumStock: (json['minimum_stock'] as num? ?? 0.0).toDouble(),
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'unit': unit,
      'current_stock': currentStock,
      'minimum_stock': minimumStock,
      'updated_at': updatedAt,
    };
  }

  InventoryItem copyWith({
    String? id,
    String? name,
    String? unit,
    double? currentStock,
    double? minimumStock,
    String? updatedAt,
  }) {
    return InventoryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      unit: unit ?? this.unit,
      currentStock: currentStock ?? this.currentStock,
      minimumStock: minimumStock ?? this.minimumStock,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
