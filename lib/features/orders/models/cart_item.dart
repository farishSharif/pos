import '../../menu/models/menu_item.dart';

class CartItem {
  final MenuItem menuItem;
  final int quantity;
  final String? notes;

  CartItem({
    required this.menuItem,
    required this.quantity,
    this.notes,
  });

  CartItem copyWith({
    MenuItem? menuItem,
    int? quantity,
    String? notes,
  }) {
    return CartItem(
      menuItem: menuItem ?? this.menuItem,
      quantity: quantity ?? this.quantity,
      notes: notes ?? this.notes,
    );
  }
}
