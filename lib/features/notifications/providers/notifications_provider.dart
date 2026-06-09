import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/services/savor_data_service.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../models/app_notification.dart';

part 'notifications_provider.g.dart';

@riverpod
Stream<List<AppNotification>> notificationsStream(NotificationsStreamRef ref) {
  final service = ref.watch(savorServiceProvider);
  final role = ref.watch(authNotifierProvider).profile?.role;
  return service.notificationsStream(role).map((rows) {
    return rows.map((r) => AppNotification.fromJson(r)).toList();
  });
}

@riverpod
class NotificationsNotifier extends _$NotificationsNotifier {
  @override
  FutureOr<void> build() {}

  Future<void> markAsRead(String id) async {
    final service = ref.read(savorServiceProvider);
    await service.markNotificationAsRead(id);
    ref.invalidate(notificationsStreamProvider);
  }
}
