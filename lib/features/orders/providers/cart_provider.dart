import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../menu/models/menu_item.dart';
import '../models/cart_item.dart';

part 'cart_provider.g.dart';

@riverpod
class CartNotifier extends _$CartNotifier {
  @override
  Map<String, CartItem> build() => {};

  void addItem(MenuItem item) {
    final existing = state[item.id];
    state = {
      ...state,
      item.id: existing != null
          ? existing.copyWith(quantity: existing.quantity + 1)
          : CartItem(menuItem: item, quantity: 1),
    };
  }

  void removeItem(String id) {
    final copy = Map<String, CartItem>.from(state);
    copy.remove(id);
    state = copy;
  }

  void updateQty(String id, int qty) {
    if (qty <= 0) {
      removeItem(id);
      return;
    }
    final existing = state[id];
    if (existing != null) {
      state = {
        ...state,
        id: existing.copyWith(quantity: qty),
      };
    }
  }

  void updateNotes(String id, String notes) {
    final existing = state[id];
    if (existing != null) {
      state = {
        ...state,
        id: existing.copyWith(notes: notes),
      };
    }
  }

  void clear() => state = {};

  double get subtotal => state.values.fold(0.0, (sum, item) => sum + (item.menuItem.price * item.quantity));
}
