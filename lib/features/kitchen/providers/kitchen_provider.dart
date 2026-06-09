import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/services/savor_data_service.dart';
import '../../orders/models/order.dart';

part 'kitchen_provider.g.dart';

@riverpod
Stream<List<Order>> kitchenOrdersStream(KitchenOrdersStreamRef ref) {
  final service = ref.watch(savorServiceProvider);
  return service.kitchenOrdersStream().map((rows) {
    return rows.map((r) => Order.fromJson(r)).toList();
  });
}
