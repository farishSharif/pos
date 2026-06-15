import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/services/savor_data_service.dart';
import '../../orders/providers/orders_provider.dart';

part 'billing_provider.g.dart';

@riverpod
class BillingNotifier extends _$BillingNotifier {
  @override
  FutureOr<void> build() {}

  Future<void> settlePayment({
    required String orderId,
    required String paymentMethod,
    required double paymentAmount,
    required double changeAmount,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final service = ref.read(savorServiceProvider);
      final paymentData = {
        'payment_status': 'paid',
        'payment_method': paymentMethod,
        'payment_amount': paymentAmount,
        'change_amount': changeAmount,
      };
      await service.updateOrderPayment(orderId, paymentData);
      
      // Invalidate the orders lists to refresh UI
      ref.invalidate(ordersListProvider);
    });
  }
}
