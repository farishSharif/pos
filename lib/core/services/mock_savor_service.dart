import 'dart:async';
import '../../data/seed_data.dart';
import 'savor_data_service.dart';

class MockSavorService implements SavorDataService {
  // Streams
  final _tableController = StreamController<List<Map<String, dynamic>>>.broadcast();
  final _kitchenOrderController = StreamController<List<Map<String, dynamic>>>.broadcast();
  final _notificationController = StreamController<List<Map<String, dynamic>>>.broadcast();

  // Local state references
  final List<Map<String, dynamic>> _profiles = List.from(SeedData.profiles);
  final List<Map<String, dynamic>> _tables = List.from(SeedData.restaurantTables);
  final List<Map<String, dynamic>> _categories = List.from(SeedData.categories);
  final List<Map<String, dynamic>> _menuItems = List.from(SeedData.menuItems);
  final List<Map<String, dynamic>> _orders = List.from(SeedData.orders);
  final List<Map<String, dynamic>> _orderItems = List.from(SeedData.orderItems);
  final List<Map<String, dynamic>> _inventory = List.from(SeedData.inventory);
  final List<Map<String, dynamic>> _purchaseRecords = List.from(SeedData.purchaseRecords);
  final List<Map<String, dynamic>> _coupons = List.from(SeedData.coupons);
  final Map<String, dynamic> _settings = Map.from(SeedData.appSettings);
  final List<Map<String, dynamic>> _notifications = List.from(SeedData.notifications);

  MockSavorService() {
    // Push initial values to streams
    _notifyTables();
    _notifyKitchen();
    _notifyNotifications(null);
  }

  void _notifyTables() {
    _tableController.add(List.unmodifiable(_tables));
  }

  void _notifyKitchen() {
    final activeOrders = _orders.where((o) {
      final s = o['status'] as String;
      return s != 'billed' && s != 'cancelled';
    }).toList();
    _kitchenOrderController.add(List.unmodifiable(activeOrders));
  }

  void _notifyNotifications(String? role) {
    final filtered = _notifications.where((n) {
      final target = n['target_role'] as String?;
      return target == null || role == null || target.toLowerCase() == role.toLowerCase();
    }).toList();
    _notificationController.add(List.unmodifiable(filtered));
  }

  // --- Auth & Profile ---

  @override
  Future<Map<String, dynamic>?> signIn(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 600));
    try {
      final user = _profiles.firstWhere(
        (p) => (p['email'] as String).toLowerCase() == email.trim().toLowerCase(),
      );
      // In offline mode we accept any password
      return user;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> signOut() async {
    return;
  }

  @override
  Future<Map<String, dynamic>> getCurrentProfile(String userId) async {
    try {
      return _profiles.firstWhere((p) => p['id'] == userId);
    } catch (_) {
      // Fallback
      return _profiles.first;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getStaffProfiles() async {
    return List.from(_profiles);
  }

  @override
  Future<Map<String, dynamic>> createStaffProfile(Map<String, dynamic> profileData) async {
    final newProfile = {
      'id': 'profile-${DateTime.now().millisecondsSinceEpoch}',
      'is_active': true,
      ...profileData,
    };
    _profiles.add(newProfile);
    return newProfile;
  }

  @override
  Future<void> updateStaffProfile(String id, Map<String, dynamic> profileData) async {
    final idx = _profiles.indexWhere((p) => p['id'] == id);
    if (idx != -1) {
      _profiles[idx] = {..._profiles[idx], ...profileData};
    }
  }

  // --- Tables ---

  @override
  Stream<List<Map<String, dynamic>>> tablesStream() {
    return _tableController.stream;
  }

  @override
  Future<void> updateTableStatus(int tableId, String status, {String? currentOrderId}) async {
    final idx = _tables.indexWhere((t) => t['id'] == tableId);
    if (idx != -1) {
      _tables[idx]['status'] = status;
      _tables[idx]['current_order_id'] = currentOrderId;
      _notifyTables();
    }
  }

  // --- Categories & Menu ---

  @override
  Future<List<Map<String, dynamic>>> getCategories() async {
    return List.from(_categories);
  }

  @override
  Future<List<Map<String, dynamic>>> getMenuItems() async {
    return List.from(_menuItems);
  }

  @override
  Future<Map<String, dynamic>> createMenuItem(Map<String, dynamic> itemData) async {
    final newItem = {
      'id': 'item-${DateTime.now().millisecondsSinceEpoch}',
      ...itemData,
    };
    _menuItems.add(newItem);
    return newItem;
  }

  @override
  Future<Map<String, dynamic>> updateMenuItem(String id, Map<String, dynamic> itemData) async {
    final idx = _menuItems.indexWhere((m) => m['id'] == id);
    if (idx != -1) {
      _menuItems[idx] = {..._menuItems[idx], ...itemData};
      return _menuItems[idx];
    }
    throw Exception('Menu item not found');
  }

  @override
  Future<void> deleteMenuItem(String id) async {
    _menuItems.removeWhere((m) => m['id'] == id);
  }

  @override
  Future<void> updateCategoryOrder(List<String> categoryIds) async {
    for (int i = 0; i < categoryIds.length; i++) {
      final idx = _categories.indexWhere((c) => c['id'] == categoryIds[i]);
      if (idx != -1) {
        _categories[idx]['sort_order'] = i + 1;
      }
    }
  }

  // --- Orders ---

  @override
  Future<List<Map<String, dynamic>>> getOrders() async {
    // Return orders containing their items and table details
    final formatted = _orders.map((o) {
      final items = _orderItems.where((oi) => oi['order_id'] == o['id']).toList();
      final table = _tables.firstWhere((t) => t['id'] == o['table_id'], orElse: () => {});
      return {
        ...o,
        'order_items': items,
        'restaurant_tables': table,
      };
    }).toList();
    // Sort descending
    formatted.sort((a, b) => b['created_at'].toString().compareTo(a['created_at'].toString()));
    return formatted;
  }

  @override
  Stream<List<Map<String, dynamic>>> kitchenOrdersStream() {
    return _kitchenOrderController.stream;
  }

  @override
  Future<Map<String, dynamic>> createOrder(Map<String, dynamic> orderData, List<Map<String, dynamic>> items) async {
    final orderId = orderData['id'] ?? 'order-${DateTime.now().millisecondsSinceEpoch}';
    final newOrder = {
      ...orderData,
      'id': orderId,
      'created_at': DateTime.now().toIso8601String(),
    };
    _orders.add(newOrder);

    int index = 0;
    for (final it in items) {
      final newItem = {
        'id': 'oi-${DateTime.now().microsecondsSinceEpoch}_$index',
        'order_id': orderId,
        'status': 'pending',
        ...it,
      };
      _orderItems.add(newItem);
      index++;
    }

    // Update table status if dine_in
    if (orderData['order_type'] == 'dine_in') {
      final tableId = orderData['table_id'] as int;
      await updateTableStatus(tableId, 'ordered', currentOrderId: orderId);
    }

    // Notification for kitchen
    final newNotif = {
      'id': 'n-${DateTime.now().millisecondsSinceEpoch}',
      'title': 'New Order Received',
      'body': 'Order for Table ${orderData['table_id'] ?? 'Takeaway'} has been created.',
      'type': 'new_order',
      'target_role': 'kitchen',
      'is_read': false,
      'created_at': DateTime.now().toIso8601String(),
    };
    _notifications.add(newNotif);

    _notifyKitchen();
    _notifyNotifications(null);

    return newOrder;
  }

  @override
  Future<void> updateOrderStatus(String orderId, String status) async {
    final idx = _orders.indexWhere((o) => o['id'] == orderId);
    if (idx != -1) {
      _orders[idx]['status'] = status;
      _orders[idx]['updated_at'] = DateTime.now().toIso8601String();

      // Update order items status too
      final items = _orderItems.where((oi) => oi['order_id'] == orderId).toList();
      for (final it in items) {
        it['status'] = switch (status) {
          'preparing' => 'preparing',
          'ready' => 'ready',
          'served' => 'served',
          'billed' => 'served',
          _ => it['status'],
        };
      }

      // Sync Table Status
      final tableId = _orders[idx]['table_id'] as int?;
      if (tableId != null) {
        final tableStatus = switch (status) {
          'preparing' => 'preparing',
          'ready' => 'ready',
          'served' => 'occupied',
          'billed' => 'available',
          'cancelled' => 'available',
          _ => 'ordered',
        };
        await updateTableStatus(tableId, tableStatus, currentOrderId: status == 'billed' || status == 'cancelled' ? null : orderId);
      }

      // Notification
      if (status == 'ready') {
        final newNotif = {
          'id': 'n-${DateTime.now().millisecondsSinceEpoch}',
          'title': 'Order Ready',
          'body': 'Order #${orderId.substring(orderId.length - 4)} is ready for Table ${tableId ?? 'Takeaway'}.',
          'type': 'order_ready',
          'target_role': 'waiter',
          'is_read': false,
          'created_at': DateTime.now().toIso8601String(),
        };
        _notifications.add(newNotif);
      }

      _notifyKitchen();
      _notifyNotifications(null);
    }
  }

  @override
  Future<void> updateOrderPayment(String orderId, Map<String, dynamic> paymentData) async {
    final idx = _orders.indexWhere((o) => o['id'] == orderId);
    if (idx != -1) {
      _orders[idx] = {..._orders[idx], ...paymentData, 'status': 'billed'};
      _orders[idx]['updated_at'] = DateTime.now().toIso8601String();

      // Clear Table
      final tableId = _orders[idx]['table_id'] as int?;
      if (tableId != null) {
        await updateTableStatus(tableId, 'available', currentOrderId: null);
      }

      // Add payment notification for Cashier
      final newNotif = {
        'id': 'n-${DateTime.now().millisecondsSinceEpoch}',
        'title': 'Payment Settled',
        'body': 'Payment of ₹${_orders[idx]['total']} received via ${paymentData['payment_method']}.',
        'type': 'payment',
        'target_role': 'cashier',
        'is_read': false,
        'created_at': DateTime.now().toIso8601String(),
      };
      _notifications.add(newNotif);

      _notifyKitchen();
      _notifyNotifications(null);
    }
  }

  // --- Inventory ---

  @override
  Future<List<Map<String, dynamic>>> getInventory() async {
    return List.from(_inventory);
  }

  @override
  Future<List<Map<String, dynamic>>> getPurchaseRecords() async {
    return _purchaseRecords.map((pr) {
      final invItem = _inventory.firstWhere((i) => i['id'] == pr['inventory_id'], orElse: () => {});
      return {
        ...pr,
        'inventory': invItem,
      };
    }).toList();
  }

  @override
  Future<Map<String, dynamic>> addInventoryItem(Map<String, dynamic> itemData) async {
    final newItem = {
      'id': 'inv-${DateTime.now().millisecondsSinceEpoch}',
      'current_stock': 0.0,
      ...itemData,
    };
    _inventory.add(newItem);
    return newItem;
  }

  @override
  Future<Map<String, dynamic>> updateInventoryStock(String id, double current, double minimum) async {
    final idx = _inventory.indexWhere((i) => i['id'] == id);
    if (idx != -1) {
      _inventory[idx]['current_stock'] = current;
      _inventory[idx]['minimum_stock'] = minimum;
      
      // Low stock notification trigger
      if (current < minimum) {
        final newNotif = {
          'id': 'n-${DateTime.now().millisecondsSinceEpoch}',
          'title': 'Low Stock Alert',
          'body': '${_inventory[idx]['name']} stock is low (${current} ${_inventory[idx]['unit']} left).',
          'type': 'low_stock',
          'target_role': 'admin',
          'is_read': false,
          'created_at': DateTime.now().toIso8601String(),
        };
        _notifications.add(newNotif);
        _notifyNotifications('admin');
      }

      return _inventory[idx];
    }
    throw Exception('Inventory item not found');
  }

  @override
  Future<Map<String, dynamic>> createPurchaseRecord(Map<String, dynamic> recordData) async {
    final recordId = 'pr-${DateTime.now().millisecondsSinceEpoch}';
    final newPr = {
      'id': recordId,
      'purchased_at': DateTime.now().toIso8601String(),
      ...recordData,
    };
    _purchaseRecords.add(newPr);

    // Increment Inventory current_stock
    final invId = recordData['inventory_id'] as String;
    final quantity = (recordData['quantity'] as num).toDouble();
    final idx = _inventory.indexWhere((i) => i['id'] == invId);
    if (idx != -1) {
      _inventory[idx]['current_stock'] = (_inventory[idx]['current_stock'] as num).toDouble() + quantity;
    }

    return newPr;
  }

  // --- Coupons ---

  @override
  Future<Map<String, dynamic>?> validateCoupon(String code) async {
    try {
      return _coupons.firstWhere(
        (c) => (c['code'] as String).toLowerCase() == code.trim().toLowerCase() && c['is_active'] == true,
      );
    } catch (_) {
      return null;
    }
  }

  // --- App Settings ---

  @override
  Future<Map<String, dynamic>> getAppSettings() async {
    return Map.from(_settings);
  }

  @override
  Future<Map<String, dynamic>> updateAppSettings(Map<String, dynamic> settings) async {
    _settings.addAll(settings);
    return Map.from(_settings);
  }

  // --- Notifications ---

  @override
  Stream<List<Map<String, dynamic>>> notificationsStream(String? role) {
    _notifyNotifications(role);
    return _notificationController.stream;
  }

  @override
  Future<void> markNotificationAsRead(String id) async {
    final idx = _notifications.indexWhere((n) => n['id'] == id);
    if (idx != -1) {
      _notifications[idx]['is_read'] = true;
      _notifyNotifications(null);
    }
  }
}

