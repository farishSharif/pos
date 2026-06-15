import 'dart:async';
import '../../data/seed_data.dart';
import 'savor_data_service.dart';

class MockSavorService implements SavorDataService {
  // Streams
  final _tableController =
      StreamController<List<Map<String, dynamic>>>.broadcast();
  final _kitchenOrderController =
      StreamController<List<Map<String, dynamic>>>.broadcast();
  final _notificationController =
      StreamController<List<Map<String, dynamic>>>.broadcast();

  // Local state references
  final List<Map<String, dynamic>> _profiles = List.from(SeedData.profiles);
  final List<Map<String, dynamic>> _tables =
      List.from(SeedData.restaurantTables);
  final List<Map<String, dynamic>> _categories = List.from(SeedData.categories);
  final List<Map<String, dynamic>> _menuItems = List.from(SeedData.menuItems);
  final List<Map<String, dynamic>> _orders = List.from(SeedData.orders);
  final List<Map<String, dynamic>> _orderItems = List.from(SeedData.orderItems);
  final List<Map<String, dynamic>> _inventory = List.from(SeedData.inventory);
  final List<Map<String, dynamic>> _purchaseRecords =
      List.from(SeedData.purchaseRecords);
  final List<Map<String, dynamic>> _coupons = List.from(SeedData.coupons);
  final Map<String, dynamic> _settings = Map.from(SeedData.appSettings);
  final List<Map<String, dynamic>> _notifications =
      List.from(SeedData.notifications);

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
    final activeOrders = _ordersWithDetails().where((o) {
      final s = o['status'] as String;
      return s != 'billed' && s != 'cancelled';
    }).toList();
    _kitchenOrderController.add(List.unmodifiable(activeOrders));
  }

  List<Map<String, dynamic>> _filteredNotifications(String? role) {
    return _notifications.where((n) {
      final target = n['target_role'] as String?;
      return target == null ||
          role == null ||
          target.toLowerCase() == role.toLowerCase();
    }).toList();
  }

  void _notifyNotifications(String? role) {
    final filtered = _filteredNotifications(role);
    _notificationController.add(List.unmodifiable(filtered));
  }

  List<Map<String, dynamic>> _ordersWithDetails() {
    final formatted = _orders.map((o) {
      final items =
          _orderItems.where((oi) => oi['order_id'] == o['id']).toList();
      final table =
          _tables.firstWhere((t) => t['id'] == o['table_id'], orElse: () => {});
      return {
        ...o,
        'order_items': items,
        'restaurant_tables': table,
      };
    }).toList();
    formatted.sort((a, b) =>
        b['created_at'].toString().compareTo(a['created_at'].toString()));
    return formatted;
  }

  // --- Auth & Profile ---

  @override
  Future<Map<String, dynamic>?> signIn(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 600));
    try {
      final user = _profiles.firstWhere(
        (p) =>
            (p['email'] as String).toLowerCase() == email.trim().toLowerCase(),
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
  Future<Map<String, dynamic>> createStaffProfile(
      Map<String, dynamic> profileData) async {
    final newProfile = {
      'id': 'profile-${DateTime.now().millisecondsSinceEpoch}',
      'is_active': true,
      ...profileData,
    };
    _profiles.add(newProfile);
    return newProfile;
  }

  @override
  Future<void> updateStaffProfile(
      String id, Map<String, dynamic> profileData) async {
    final idx = _profiles.indexWhere((p) => p['id'] == id);
    if (idx != -1) {
      _profiles[idx] = {..._profiles[idx], ...profileData};
    }
  }

  // --- Tables ---

  @override
  Stream<List<Map<String, dynamic>>> tablesStream() async* {
    yield List.unmodifiable(_tables);
    yield* _tableController.stream;
  }

  @override
  Future<void> updateTableStatus(int tableId, String status,
      {String? currentOrderId}) async {
    final idx = _tables.indexWhere((t) => t['id'] == tableId);
    if (idx != -1) {
      _tables[idx]['status'] = status;
      _tables[idx]['current_order_id'] = currentOrderId;
      _notifyTables();
    }
  }

  @override
  Future<void> updateTablePositions(List<Map<String, dynamic>> positions) async {
    for (final pos in positions) {
      final idx = _tables.indexWhere((t) => t['id'] == pos['id']);
      if (idx != -1) {
        _tables[idx]['position_x'] = pos['position_x'];
        _tables[idx]['position_y'] = pos['position_y'];
      }
    }
    _notifyTables();
  }

  @override
  Future<void> setTableCount(int count) async {
    if (count > _tables.length) {
      int startNum = _tables.isEmpty ? 1 : (_tables.map((t) => t['table_number'] as int).reduce((a, b) => a > b ? a : b) + 1);
      for (int i = 0; i < (count - _tables.length); i++) {
        final nextNum = startNum + i;
        final index = _tables.length;
        final x = (index % 3) * 200.0 + 50.0;
        final y = (index ~/ 3) * 150.0 + 50.0;
        _tables.add({
          'id': nextNum,
          'table_number': nextNum,
          'capacity': 4,
          'status': 'available',
          'current_order_id': null,
          'position_x': x,
          'position_y': y,
        });
      }
    } else if (count < _tables.length) {
      _tables.removeRange(count, _tables.length);
    }
    _notifyTables();
  }

  @override
  Future<void> createOrUpdateTable(Map<String, dynamic> tableData) async {
    if (tableData['id'] != null) {
      final idx = _tables.indexWhere((t) => t['id'] == tableData['id']);
      if (idx != -1) {
        _tables[idx].addAll(tableData);
      }
    } else {
      final newId = _tables.isEmpty ? 1 : (_tables.map((t) => t['id'] as int).reduce((a, b) => a > b ? a : b) + 1);
      final newNum = _tables.isEmpty ? 1 : (_tables.map((t) => t['table_number'] as int).reduce((a, b) => a > b ? a : b) + 1);
      final index = _tables.length;
      final x = (index % 3) * 200.0 + 50.0;
      final y = (index ~/ 3) * 150.0 + 50.0;
      _tables.add({
        'id': newId,
        'table_number': tableData['table_number'] ?? newNum,
        'capacity': tableData['capacity'] ?? 4,
        'status': tableData['status'] ?? 'available',
        'current_order_id': null,
        'position_x': tableData['position_x'] ?? x,
        'position_y': tableData['position_y'] ?? y,
      });
    }
    _notifyTables();
  }

  @override
  Future<void> deleteTable(int tableId) async {
    _tables.removeWhere((t) => t['id'] == tableId);
    _notifyTables();
  }

  // --- Categories & Menu ---

  @override
  Future<List<Map<String, dynamic>>> getCategories() async {
    return List.from(_categories);
  }

  @override
  Future<void> updateCategoryActiveStatus(String id, bool isActive) async {
    final idx = _categories.indexWhere((c) => c['id'] == id);
    if (idx != -1) {
      _categories[idx]['is_active'] = isActive;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getMenuItems() async {
    return List.from(_menuItems);
  }

  @override
  Future<Map<String, dynamic>> createMenuItem(
      Map<String, dynamic> itemData) async {
    final newItem = {
      'id': 'item-${DateTime.now().millisecondsSinceEpoch}',
      ...itemData,
    };
    _menuItems.add(newItem);
    return newItem;
  }

  @override
  Future<Map<String, dynamic>> updateMenuItem(
      String id, Map<String, dynamic> itemData) async {
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
    return _ordersWithDetails();
  }

  @override
  Stream<List<Map<String, dynamic>>> kitchenOrdersStream() async* {
    yield List.unmodifiable(_ordersWithDetails().where((o) {
      final s = o['status'] as String;
      return s != 'billed' && s != 'cancelled';
    }).toList());
    yield* _kitchenOrderController.stream;
  }

  @override
  Future<Map<String, dynamic>> createOrder(
      Map<String, dynamic> orderData, List<Map<String, dynamic>> items) async {
    final orderId =
        orderData['id'] ?? 'order-${DateTime.now().millisecondsSinceEpoch}';
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
      'body':
          'Order for Table ${orderData['table_id'] ?? 'Takeaway'} has been created.',
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
      final items =
          _orderItems.where((oi) => oi['order_id'] == orderId).toList();
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
        await updateTableStatus(tableId, tableStatus,
            currentOrderId:
                status == 'billed' || status == 'cancelled' ? null : orderId);
      }

      // Notification
      if (status == 'ready') {
        final newNotif = {
          'id': 'n-${DateTime.now().millisecondsSinceEpoch}',
          'title': 'Order Ready',
          'body':
              'Order #${orderId.substring(orderId.length - 4)} is ready for Table ${tableId ?? 'Takeaway'}.',
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
  Future<void> updateOrderItemStatus(String itemId, String status) async {
    final idx = _orderItems.indexWhere((oi) => oi['id'] == itemId);
    if (idx != -1) {
      _orderItems[idx]['status'] = status;
      final orderId = _orderItems[idx]['order_id'] as String;

      // Check siblings
      final siblings = _orderItems.where((oi) => oi['order_id'] == orderId).toList();
      final statuses = siblings.map((si) => si['status'] as String).toList();

      String? newOrderStatus;
      if (statuses.every((s) => s == 'ready' || s == 'served')) {
        newOrderStatus = 'ready';
      } else if (statuses.any((s) => s == 'preparing' || s == 'ready')) {
        newOrderStatus = 'preparing';
      }

      final oIdx = _orders.indexWhere((o) => o['id'] == orderId);
      if (oIdx != -1) {
        _orders[oIdx]['updated_at'] = DateTime.now().toIso8601String();
        if (newOrderStatus != null) {
          _orders[oIdx]['status'] = newOrderStatus;

          final tableId = _orders[oIdx]['table_id'] as int?;
          if (tableId != null) {
            final tableStatus = switch (newOrderStatus) {
              'preparing' => 'preparing',
              'ready' => 'ready',
              _ => 'ordered',
            };
            await updateTableStatus(tableId, tableStatus, currentOrderId: orderId);
          }

          if (newOrderStatus == 'ready') {
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
            _notifyNotifications(null);
          }
        }
      }
      _notifyKitchen();
    }
  }

  @override
  Future<void> updateOrderPayment(
      String orderId, Map<String, dynamic> paymentData) async {
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
        'body':
            'Payment of ₹${_orders[idx]['total']} received via ${paymentData['payment_method']}.',
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
      final invItem = _inventory
          .firstWhere((i) => i['id'] == pr['inventory_id'], orElse: () => {});
      return {
        ...pr,
        'inventory': invItem,
      };
    }).toList();
  }

  @override
  Future<Map<String, dynamic>> addInventoryItem(
      Map<String, dynamic> itemData) async {
    final newItem = {
      'id': 'inv-${DateTime.now().millisecondsSinceEpoch}',
      'current_stock': 0.0,
      ...itemData,
    };
    _inventory.add(newItem);
    return newItem;
  }

  @override
  Future<Map<String, dynamic>> updateInventoryStock(
      String id, double current, double minimum) async {
    final idx = _inventory.indexWhere((i) => i['id'] == id);
    if (idx != -1) {
      _inventory[idx]['current_stock'] = current;
      _inventory[idx]['minimum_stock'] = minimum;

      // Low stock notification trigger
      if (current < minimum) {
        final newNotif = {
          'id': 'n-${DateTime.now().millisecondsSinceEpoch}',
          'title': 'Low Stock Alert',
          'body':
              '${_inventory[idx]['name']} stock is low ($current ${_inventory[idx]['unit']} left).',
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
  Future<Map<String, dynamic>> createPurchaseRecord(
      Map<String, dynamic> recordData) async {
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
      _inventory[idx]['current_stock'] =
          (_inventory[idx]['current_stock'] as num).toDouble() + quantity;
    }

    return newPr;
  }

  // --- Coupons ---

  @override
  Future<Map<String, dynamic>?> validateCoupon(String code) async {
    try {
      return _coupons.firstWhere(
        (c) =>
            (c['code'] as String).toLowerCase() == code.trim().toLowerCase() &&
            c['is_active'] == true,
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
  Future<Map<String, dynamic>> updateAppSettings(
      Map<String, dynamic> settings) async {
    _settings.addAll(settings);
    return Map.from(_settings);
  }

  // --- Notifications ---

  @override
  Stream<List<Map<String, dynamic>>> notificationsStream(String? role) async* {
    yield List.unmodifiable(_filteredNotifications(role));
    yield* _notificationController.stream.map((rows) {
      return rows.where((n) {
        final target = n['target_role'] as String?;
        return target == null ||
            role == null ||
            target.toLowerCase() == role.toLowerCase();
      }).toList();
    });
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
