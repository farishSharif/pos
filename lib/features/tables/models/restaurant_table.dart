class RestaurantTable {
  final int id;
  final int tableNumber;
  final int capacity;
  final String status; // 'available','ordered','preparing','ready','occupied','billed'
  final String? currentOrderId;
  final String? updatedAt;

  RestaurantTable({
    required this.id,
    required this.tableNumber,
    required this.capacity,
    required this.status,
    this.currentOrderId,
    this.updatedAt,
  });

  factory RestaurantTable.fromJson(Map<String, dynamic> json) {
    return RestaurantTable(
      id: json['id'] as int,
      tableNumber: json['table_number'] as int,
      capacity: json['capacity'] as int? ?? 4,
      status: json['status'] as String? ?? 'available',
      currentOrderId: json['current_order_id'] as String?,
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
      'updated_at': updatedAt,
    };
  }

  RestaurantTable copyWith({
    int? id,
    int? tableNumber,
    int? capacity,
    String? status,
    String? currentOrderId,
    String? updatedAt,
  }) {
    return RestaurantTable(
      id: id ?? this.id,
      tableNumber: tableNumber ?? this.tableNumber,
      capacity: capacity ?? this.capacity,
      status: status ?? this.status,
      currentOrderId: currentOrderId ?? this.currentOrderId,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
