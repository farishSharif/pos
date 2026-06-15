import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'savor_data_service.dart';

class SupabaseSavorService implements SavorDataService {
  SupabaseClient get _client => Supabase.instance.client;

  // --- Auth & Profile ---

  @override
  Future<Map<String, dynamic>?> signIn(String email, String password) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    if (response.user != null) {
      return getCurrentProfile(response.user!.id);
    }
    return null;
  }

  @override
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  @override
  Future<Map<String, dynamic>> getCurrentProfile(String userId) async {
    final data = await _client.from('profiles').select().eq('id', userId).single();
    return data;
  }

  @override
  Future<List<Map<String, dynamic>>> getStaffProfiles() async {
    final List<dynamic> data = await _client.from('profiles').select().order('name');
    return List<Map<String, dynamic>>.from(data);
  }

  @override
  Future<Map<String, dynamic>> createStaffProfile(Map<String, dynamic> profileData) async {
    // Wait, the auth admin createUser creates the user, but we insert directly to profiles table as well.
    final data = await _client.from('profiles').insert(profileData).select().single();
    return data;
  }

  @override
  Future<void> updateStaffProfile(String id, Map<String, dynamic> profileData) async {
    await _client.from('profiles').update(profileData).eq('id', id);
  }

  // --- Tables ---

  @override
  Stream<List<Map<String, dynamic>>> tablesStream() {
    return _client
        .from('restaurant_tables')
        .stream(primaryKey: ['id'])
        .order('table_number')
        .map((rows) => List<Map<String, dynamic>>.from(rows));
  }

  @override
  Future<void> updateTableStatus(int tableId, String status, {String? currentOrderId}) async {
    await _client
        .from('restaurant_tables')
        .update({'status': status, 'current_order_id': currentOrderId}).eq('id', tableId);
  }

  @override
  Future<void> updateTablePositions(List<Map<String, dynamic>> positions) async {
    for (final pos in positions) {
      await _client
          .from('restaurant_tables')
          .update({
            'position_x': pos['position_x'],
            'position_y': pos['position_y'],
          })
          .eq('id', pos['id']);
    }
  }

  @override
  Future<void> setTableCount(int count) async {
    final List<dynamic> current = await _client.from('restaurant_tables').select().order('table_number');
    final currentList = List<Map<String, dynamic>>.from(current);
    final currentCount = currentList.length;

    if (count > currentCount) {
      final List<Map<String, dynamic>> toInsert = [];
      for (int i = currentCount + 1; i <= count; i++) {
        toInsert.add({
          'table_number': i,
          'capacity': 4,
          'status': 'available',
        });
      }
      try {
        final List<Map<String, dynamic>> withCoords = toInsert.map((t) {
          final idx = toInsert.indexOf(t) + currentCount;
          return {
            ...t,
            'position_x': (idx % 3) * 200.0 + 50.0,
            'position_y': (idx ~/ 3) * 150.0 + 50.0,
          };
        }).toList();
        await _client.from('restaurant_tables').insert(withCoords);
      } catch (_) {
        await _client.from('restaurant_tables').insert(toInsert);
      }
    } else if (count < currentCount) {
      final toDeleteIds = currentList.sublist(count).map((t) => t['id'] as int).toList();
      if (toDeleteIds.isNotEmpty) {
        await _client.from('restaurant_tables').delete().inFilter('id', toDeleteIds);
      }
    }
  }

  @override
  Future<void> createOrUpdateTable(Map<String, dynamic> tableData) async {
    if (tableData['id'] != null) {
      try {
        await _client.from('restaurant_tables').update(tableData).eq('id', tableData['id']);
      } catch (_) {
        final cleanData = Map<String, dynamic>.from(tableData)
          ..remove('position_x')
          ..remove('position_y');
        await _client.from('restaurant_tables').update(cleanData).eq('id', tableData['id']);
      }
    } else {
      try {
        await _client.from('restaurant_tables').insert(tableData);
      } catch (_) {
        final cleanData = Map<String, dynamic>.from(tableData)
          ..remove('position_x')
          ..remove('position_y');
        await _client.from('restaurant_tables').insert(cleanData);
      }
    }
  }

  @override
  Future<void> deleteTable(int tableId) async {
    await _client.from('restaurant_tables').delete().eq('id', tableId);
  }

  // --- Categories & Menu ---

  @override
  Future<List<Map<String, dynamic>>> getCategories() async {
    final List<dynamic> data = await _client.from('menu_categories').select().order('sort_order');
    return List<Map<String, dynamic>>.from(data);
  }

  @override
  Future<void> updateCategoryActiveStatus(String id, bool isActive) async {
    await _client.from('menu_categories').update({'is_active': isActive}).eq('id', id);
  }

  @override
  Future<List<Map<String, dynamic>>> getMenuItems() async {
    final List<dynamic> data = await _client.from('menu_items').select('*, menu_categories(*)').order('name');
    return List<Map<String, dynamic>>.from(data);
  }

  @override
  Future<Map<String, dynamic>> createMenuItem(Map<String, dynamic> itemData) async {
    final data = await _client.from('menu_items').insert(itemData).select().single();
    return data;
  }

  @override
  Future<Map<String, dynamic>> updateMenuItem(String id, Map<String, dynamic> itemData) async {
    final data = await _client.from('menu_items').update(itemData).eq('id', id).select().single();
    return data;
  }

  @override
  Future<void> deleteMenuItem(String id) async {
    await _client.from('menu_items').delete().eq('id', id);
  }

  @override
  Future<void> updateCategoryOrder(List<String> categoryIds) async {
    for (int i = 0; i < categoryIds.length; i++) {
      await _client.from('menu_categories').update({'sort_order': i + 1}).eq('id', categoryIds[i]);
    }
  }

  // --- Orders ---

  @override
  Future<List<Map<String, dynamic>>> getOrders() async {
    final List<dynamic> data = await _client
        .from('orders')
        .select('*, order_items(*), restaurant_tables(*)')
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(data);
  }

  @override
  Stream<List<Map<String, dynamic>>> kitchenOrdersStream() {
    return _client
        .from('orders')
        .stream(primaryKey: ['id'])
        .order('created_at')
        .asyncMap((rows) async {
          final activeOrders = List<Map<String, dynamic>>.from(rows)
              .where((r) => r['status'] != 'billed' && r['status'] != 'cancelled')
              .toList();
          
          if (activeOrders.isEmpty) return [];

          final futures = activeOrders.map((o) async {
            final items = await _client.from('order_items').select().eq('order_id', o['id']);
            final table = o['table_id'] != null 
                ? await _client.from('restaurant_tables').select().eq('id', o['table_id']).maybeSingle()
                : null;
            return {
              ...o,
              'order_items': items,
              'restaurant_tables': table,
            };
          });
          return Future.wait(futures);
        });
  }

  @override
  Future<Map<String, dynamic>> createOrder(Map<String, dynamic> orderData, List<Map<String, dynamic>> items) async {
    final orderResponse = await _client.from('orders').insert(orderData).select().single();
    final orderId = orderResponse['id'] as String;

    final itemsToInsert = items.map((it) => {...it, 'order_id': orderId}).toList();
    await _client.from('order_items').insert(itemsToInsert);

    if (orderData['order_type'] == 'dine_in') {
      final tableId = orderData['table_id'] as int;
      await updateTableStatus(tableId, 'ordered', currentOrderId: orderId);
    }

    return orderResponse;
  }

  @override
  Future<void> updateOrderStatus(String orderId, String status) async {
    await _client.from('orders').update({'status': status}).eq('id', orderId);

    // Also update order items status
    await _client.from('order_items').update({'status': switch (status) {
      'preparing' => 'preparing',
      'ready' => 'ready',
      'served' => 'served',
      'billed' => 'served',
      _ => 'pending',
    }}).eq('order_id', orderId);

    // Update table status if appropriate
    final orderData = await _client.from('orders').select().eq('id', orderId).single();
    final tableId = orderData['table_id'] as int?;
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

    // Insert Notification
    if (status == 'ready') {
      await _client.from('notifications').insert({
        'title': 'Order Ready',
        'body': 'Order #${orderId.substring(orderId.length - 4)} is ready for Table ${tableId ?? 'Takeaway'}.',
        'type': 'order_ready',
        'target_role': 'waiter',
      });
    }
  }

  @override
  Future<void> updateOrderItemStatus(String itemId, String status) async {
    await _client.from('order_items').update({'status': status}).eq('id', itemId);

    // Get order ID to touch the parent order
    final itemData = await _client.from('order_items').select('order_id').eq('id', itemId).single();
    final orderId = itemData['order_id'] as String;

    final List<dynamic> siblingItems = await _client.from('order_items').select('status').eq('order_id', orderId);
    final statuses = siblingItems.map((si) => si['status'] as String).toList();

    String? newOrderStatus;
    if (statuses.every((s) => s == 'ready' || s == 'served')) {
      newOrderStatus = 'ready';
    } else if (statuses.any((s) => s == 'preparing' || s == 'ready')) {
      newOrderStatus = 'preparing';
    }

    final updateData = <String, dynamic>{
      'updated_at': DateTime.now().toIso8601String(),
    };
    if (newOrderStatus != null) {
      updateData['status'] = newOrderStatus;
    }

    await _client.from('orders').update(updateData).eq('id', orderId);

    // Update table status if appropriate
    if (newOrderStatus != null) {
      final orderData = await _client.from('orders').select('table_id').eq('id', orderId).single();
      final tableId = orderData['table_id'] as int?;
      if (tableId != null) {
        final tableStatus = switch (newOrderStatus) {
          'preparing' => 'preparing',
          'ready' => 'ready',
          _ => 'ordered',
        };
        await updateTableStatus(tableId, tableStatus, currentOrderId: orderId);
      }

      // If it became ready, trigger a notification
      if (newOrderStatus == 'ready') {
        await _client.from('notifications').insert({
          'title': 'Order Ready',
          'body': 'Order #${orderId.substring(orderId.length - 4)} is ready for Table ${tableId ?? 'Takeaway'}.',
          'type': 'order_ready',
          'target_role': 'waiter',
        });
      }
    }
  }

  @override
  Future<void> updateOrderPayment(String orderId, Map<String, dynamic> paymentData) async {
    await _client.from('orders').update({...paymentData, 'status': 'billed'}).eq('id', orderId);

    // Fetch order to clean table
    final orderData = await _client.from('orders').select().eq('id', orderId).single();
    final tableId = orderData['table_id'] as int?;
    if (tableId != null) {
      await updateTableStatus(tableId, 'available', currentOrderId: null);
    }

    // Add notification for cashier
    await _client.from('notifications').insert({
      'title': 'Payment Settled',
      'body': 'Payment of ₹${orderData['total']} received via ${paymentData['payment_method']}.',
      'type': 'payment',
      'target_role': 'cashier',
    });
  }

  // --- Inventory ---

  @override
  Future<List<Map<String, dynamic>>> getInventory() async {
    final List<dynamic> data = await _client.from('inventory').select().order('name');
    return List<Map<String, dynamic>>.from(data);
  }

  @override
  Future<List<Map<String, dynamic>>> getPurchaseRecords() async {
    final List<dynamic> data = await _client.from('purchase_records').select('*, inventory(*)').order('purchased_at', ascending: false);
    return List<Map<String, dynamic>>.from(data);
  }

  @override
  Future<Map<String, dynamic>> addInventoryItem(Map<String, dynamic> itemData) async {
    final data = await _client.from('inventory').insert(itemData).select().single();
    return data;
  }

  @override
  Future<Map<String, dynamic>> updateInventoryStock(String id, double current, double minimum) async {
    final data = await _client.from('inventory').update({
      'current_stock': current,
      'minimum_stock': minimum,
    }).eq('id', id).select().single();

    // Trigger low stock notifications
    if (current < minimum) {
      await _client.from('notifications').insert({
        'title': 'Low Stock Alert',
        'body': '${data['name']} stock is low ($current ${data['unit']} left).',
        'type': 'low_stock',
        'target_role': 'admin',
      });
    }

    return data;
  }

  @override
  Future<Map<String, dynamic>> createPurchaseRecord(Map<String, dynamic> recordData) async {
    final data = await _client.from('purchase_records').insert(recordData).select().single();

    // Update inventory stock
    final invId = recordData['inventory_id'] as String;
    final quantity = recordData['quantity'] as double;

    final currentInv = await _client.from('inventory').select().eq('id', invId).single();
    final newStock = (currentInv['current_stock'] as num).toDouble() + quantity;

    await _client.from('inventory').update({'current_stock': newStock}).eq('id', invId);

    return data;
  }

  // --- Coupons ---

  @override
  Future<Map<String, dynamic>?> validateCoupon(String code) async {
    final data = await _client
        .from('coupons')
        .select()
        .eq('code', code.toUpperCase())
        .eq('is_active', true)
        .maybeSingle();
    return data;
  }

  // --- App Settings ---

  @override
  Future<Map<String, dynamic>> getAppSettings() async {
    final data = await _client.from('app_settings').select().single();
    return data;
  }

  @override
  Future<Map<String, dynamic>> updateAppSettings(Map<String, dynamic> settings) async {
    final data = await _client.from('app_settings').update(settings).select().single();
    return data;
  }

  // --- Notifications ---

  @override
  Stream<List<Map<String, dynamic>>> notificationsStream(String? role) {
    var query = _client.from('notifications').stream(primaryKey: ['id']).order('created_at', ascending: false);
    return query.map((rows) {
      final list = List<Map<String, dynamic>>.from(rows);
      if (role == null) return list;
      return list.where((n) {
        final target = n['target_role'] as String?;
        return target == null || target.toLowerCase() == role.toLowerCase();
      }).toList();
    });
  }

  @override
  Future<void> markNotificationAsRead(String id) async {
    await _client.from('notifications').update({'is_read': true}).eq('id', id);
  }
}
