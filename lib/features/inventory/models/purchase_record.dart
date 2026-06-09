import 'inventory_item.dart';

class PurchaseRecord {
  final String id;
  final String inventoryId;
  final double quantity;
  final String? supplier;
  final double cost;
  final String purchasedAt;
  final InventoryItem? inventory;

  PurchaseRecord({
    required this.id,
    required this.inventoryId,
    required this.quantity,
    this.supplier,
    required this.cost,
    required this.purchasedAt,
    this.inventory,
  });

  factory PurchaseRecord.fromJson(Map<String, dynamic> json) {
    return PurchaseRecord(
      id: json['id'] as String,
      inventoryId: json['inventory_id'] as String,
      quantity: (json['quantity'] as num? ?? 0.0).toDouble(),
      supplier: json['supplier'] as String?,
      cost: (json['cost'] as num? ?? 0.0).toDouble(),
      purchasedAt: json['purchased_at'] as String? ?? DateTime.now().toIso8601String(),
      inventory: json['inventory'] != null ? InventoryItem.fromJson(json['inventory'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'inventory_id': inventoryId,
      'quantity': quantity,
      'supplier': supplier,
      'cost': cost,
      'purchased_at': purchasedAt,
    };
  }
}
