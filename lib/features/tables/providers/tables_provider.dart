import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/services/savor_data_service.dart';
import '../models/restaurant_table.dart';

part 'tables_provider.g.dart';

@riverpod
Stream<List<RestaurantTable>> tablesStream(TablesStreamRef ref) {
  final service = ref.watch(savorServiceProvider);
  return service.tablesStream().map((rows) {
    return rows.map((r) => RestaurantTable.fromJson(r)).toList();
  });
}

@riverpod
class TablesNotifier extends _$TablesNotifier {
  @override
  FutureOr<void> build() {}

  Future<void> updateStatus(int tableId, String status, {String? currentOrderId}) async {
    final service = ref.read(savorServiceProvider);
    await service.updateTableStatus(tableId, status, currentOrderId: currentOrderId);
  }
}
