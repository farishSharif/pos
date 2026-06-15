class RestaurantTable {
  final int id;
  final int tableNumber;
  final int capacity;
  final String status; // 'available','ordered','preparing','ready','occupied','billed'
  final String? currentOrderId;
  final double positionX;
  final double positionY;
  final String? updatedAt;

  RestaurantTable({
    required this.id,
    required this.tableNumber,
    required this.capacity,
    required this.status,
    this.currentOrderId,
    this.positionX = 0.0,
    this.positionY = 0.0,
    this.updatedAt,
  });

  factory RestaurantTable.fromJson(Map<String, dynamic> json) {
    return RestaurantTable(
      id: json['id'] as int,
      tableNumber: json['table_number'] as int,
      capacity: json['capacity'] as int? ?? 4,
      status: json['status'] as String? ?? 'available',
      currentOrderId: json['current_order_id'] as String?,
      positionX: (json['position_x'] as num?)?.toDouble() ?? 0.0,
      positionY: (json['position_y'] as num?)?.toDouble() ?? 0.0,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'table_number': tableNumber,
      'capacity': capacity,
      'status': status,
      'current_order_id': currentOrderId,
      'position_x': positionX,
      'position_y': positionY,
      'updated_at': updatedAt,
    };
  }

  RestaurantTable copyWith({
    int? id,
    int? tableNumber,
    int? capacity,
    String? status,
    String? currentOrderId,
    double? positionX,
    double? positionY,
    String? updatedAt,
  }) {
    return RestaurantTable(
      id: id ?? this.id,
      tableNumber: tableNumber ?? this.tableNumber,
      capacity: capacity ?? this.capacity,
      status: status ?? this.status,
      currentOrderId: currentOrderId ?? this.currentOrderId,
      positionX: positionX ?? this.positionX,
      positionY: positionY ?? this.positionY,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
