import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/services/savor_data_service.dart';
import '../../orders/providers/orders_provider.dart';

part 'menu_provider.g.dart';

@riverpod
class MenuNotifier extends _$MenuNotifier {
  @override
  FutureOr<void> build() {}

  Future<void> toggleAvailability(String itemId, bool isAvailable) async {
    final service = ref.read(savorServiceProvider);
    await service.updateMenuItem(itemId, {'is_available': isAvailable});
    ref.invalidate(menuItemsProvider);
  }

  Future<void> addItem(Map<String, dynamic> itemData) async {
    final service = ref.read(savorServiceProvider);
    await service.createMenuItem(itemData);
    ref.invalidate(menuItemsProvider);
  }

  Future<void> editItem(String id, Map<String, dynamic> itemData) async {
    final service = ref.read(savorServiceProvider);
    await service.updateMenuItem(id, itemData);
    ref.invalidate(menuItemsProvider);
  }

  Future<void> removeItem(String id) async {
    final service = ref.read(savorServiceProvider);
    await service.deleteMenuItem(id);
    ref.invalidate(menuItemsProvider);
  }

  Future<void> reorderCategories(List<String> categoryIds) async {
    final service = ref.read(savorServiceProvider);
    await service.updateCategoryOrder(categoryIds);
    ref.invalidate(categoriesProvider);
  }

  Future<void> updateCategoryActiveStatus(String id, bool isActive) async {
    final service = ref.read(savorServiceProvider);
    await service.updateCategoryActiveStatus(id, isActive);
    ref.invalidate(categoriesProvider);
    ref.invalidate(menuItemsProvider);
  }
}
