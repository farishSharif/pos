import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/services/savor_data_service.dart';
import '../models/inventory_item.dart';
import '../models/purchase_record.dart';

part 'inventory_provider.g.dart';

@riverpod
class InventoryNotifier extends _$InventoryNotifier {
  @override
  FutureOr<List<InventoryItem>> build() async {
    final service = ref.watch(savorServiceProvider);
    final list = await service.getInventory();
    return list.map((e) => InventoryItem.fromJson(e)).toList();
  }

  Future<void> addItem(String name, String unit, double currentStock, double minimumStock) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(savorServiceProvider);
      final itemData = {
        'name': name,
        'unit': unit,
        'current_stock': currentStock,
        'minimum_stock': minimumStock,
      };
      await service.addInventoryItem(itemData);
      final list = await service.getInventory();
      return list.map((e) => InventoryItem.fromJson(e)).toList();
    });
  }

  Future<void> updateStock(String id, double current, double minimum) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(savorServiceProvider);
      await service.updateInventoryStock(id, current, minimum);
      final list = await service.getInventory();
      return list.map((e) => InventoryItem.fromJson(e)).toList();
    });
  }
}

@riverpod
class PurchaseRecordsNotifier extends _$PurchaseRecordsNotifier {
  @override
  FutureOr<List<PurchaseRecord>> build() async {
    final service = ref.watch(savorServiceProvider);
    final list = await service.getPurchaseRecords();
    return list.map((e) => PurchaseRecord.fromJson(e)).toList();
  }

  Future<void> addRecord(String inventoryId, double quantity, double cost, String? supplier) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(savorServiceProvider);
      final recordData = {
        'inventory_id': inventoryId,
        'quantity': quantity,
        'cost': cost,
        'supplier': supplier,
        'purchased_at': DateTime.now().toIso8601String(),
      };
      await service.createPurchaseRecord(recordData);
      
      // Since inventory stock is updated as a result of purchase in backend (or mock)
      // we invalidate the inventory notifier so it fetches the new stock values.
      ref.invalidate(inventoryNotifierProvider);

      final list = await service.getPurchaseRecords();
      return list.map((e) => PurchaseRecord.fromJson(e)).toList();
    });
  }
}
