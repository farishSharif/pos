import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/savor_data_service.dart';
import '../models/restaurant_table.dart';

part 'tables_provider.g.dart';

@riverpod
Stream<List<RestaurantTable>> tablesStream(TablesStreamRef ref) {
  final service = ref.watch(savorServiceProvider);
  return service.tablesStream().asyncMap((rows) async {
    final list = rows.map((r) => RestaurantTable.fromJson(r)).toList();
    try {
      final sp = await SharedPreferences.getInstance();
      return list.map((table) {
        final x = sp.getDouble('table_pos_x_${table.id}');
        final y = sp.getDouble('table_pos_y_${table.id}');
        if (x != null && y != null) {
          return table.copyWith(positionX: x, positionY: y);
        }
        return table;
      }).toList();
    } catch (_) {
      return list;
    }
  });
}

@riverpod
class TablesNotifier extends _$TablesNotifier {
  @override
  FutureOr<void> build() {}

  Future<void> updateStatus(int tableId, String status, {String? currentOrderId}) async {
    final service = ref.read(savorServiceProvider);
    await service.updateTableStatus(tableId, status, currentOrderId: currentOrderId);
    ref.invalidate(tablesStreamProvider);
  }

  Future<void> updateTablePositions(List<RestaurantTable> tables) async {
    try {
      final sp = await SharedPreferences.getInstance();
      for (final t in tables) {
        await sp.setDouble('table_pos_x_${t.id}', t.positionX);
        await sp.setDouble('table_pos_y_${t.id}', t.positionY);
      }
    } catch (_) {}

    try {
      final service = ref.read(savorServiceProvider);
      final list = tables.map((t) => {'id': t.id, 'position_x': t.positionX, 'position_y': t.positionY}).toList();
      await service.updateTablePositions(list);
    } catch (_) {}
    ref.invalidate(tablesStreamProvider);
  }

  Future<void> setTableCount(int count) async {
    final service = ref.read(savorServiceProvider);
    await service.setTableCount(count);
    ref.invalidate(tablesStreamProvider);
  }

  Future<void> createOrUpdateTable(RestaurantTable table) async {
    try {
      final sp = await SharedPreferences.getInstance();
      await sp.setDouble('table_pos_x_${table.id}', table.positionX);
      await sp.setDouble('table_pos_y_${table.id}', table.positionY);
    } catch (_) {}

    final service = ref.read(savorServiceProvider);
    await service.createOrUpdateTable(table.toJson());
    ref.invalidate(tablesStreamProvider);
  }

  Future<void> deleteTable(int tableId) async {
    try {
      final sp = await SharedPreferences.getInstance();
      await sp.remove('table_pos_x_$tableId');
      await sp.remove('table_pos_y_$tableId');
    } catch (_) {}

    final service = ref.read(savorServiceProvider);
    await service.deleteTable(tableId);
    ref.invalidate(tablesStreamProvider);
  }

  Future<void> addTable({required int tableNumber, required int capacity}) async {
    final service = ref.read(savorServiceProvider);
    final tableData = {
      'table_number': tableNumber,
      'capacity': capacity,
      'status': 'available',
      'position_x': 40.0,
      'position_y': 40.0,
    };
    await service.createOrUpdateTable(tableData);
    ref.invalidate(tablesStreamProvider);
  }
}
