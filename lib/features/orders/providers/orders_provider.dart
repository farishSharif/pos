import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/services/savor_data_service.dart';
import '../models/order.dart';

part 'orders_provider.g.dart';

@riverpod
Future<List<Map<String, dynamic>>> categories(CategoriesRef ref) async {
  final service = ref.watch(savorServiceProvider);
  return service.getCategories();
}

@riverpod
Future<List<Map<String, dynamic>>> menuItems(MenuItemsRef ref) async {
  final service = ref.watch(savorServiceProvider);
  return service.getMenuItems();
}

@riverpod
Future<List<Order>> ordersList(OrdersListRef ref) async {
  final service = ref.watch(savorServiceProvider);
  final list = await service.getOrders();
  return list.map((json) => Order.fromJson(json)).toList();
}

@riverpod
class OrdersNotifier extends _$OrdersNotifier {
  @override
  FutureOr<void> build() {}

  Future<Order> checkout({
    required int? tableId,
    required String? customerName,
    required String orderType,
    required String status,
    required double subtotal,
    required double cgst,
    required double sgst,
    required double serviceCharge,
    required double discount,
    required double total,
    required String? couponCode,
    required String? notes,
    required List<Map<String, dynamic>> items,
  }) async {
    state = const AsyncLoading();
    try {
      final service = ref.read(savorServiceProvider);
      final profile = ref.read(savorServiceProvider); // We'll get user id inside service or mock
      
      final orderData = {
        'table_id': tableId,
        'customer_name': customerName,
        'order_type': orderType,
        'status': status,
        'subtotal': subtotal,
        'cgst': cgst,
        'sgst': sgst,
        'service_charge': serviceCharge,
        'discount': discount,
        'total': total,
        'coupon_code': couponCode,
        'notes': notes,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final res = await service.createOrder(orderData, items);
      ref.invalidate(ordersListProvider);
      state = const AsyncData(null);
      return Order.fromJson(res);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> updateStatus(String orderId, String status) async {
    final service = ref.read(savorServiceProvider);
    await service.updateOrderStatus(orderId, status);
    ref.invalidate(ordersListProvider);
  }
}

@riverpod
Future<Map<String, dynamic>?> validateCoupon(ValidateCouponRef ref, String code) async {
  final service = ref.watch(savorServiceProvider);
  return service.validateCoupon(code);
}
