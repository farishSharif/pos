import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../supabase_config.dart';
import 'mock_savor_service.dart';
import 'supabase_savor_service.dart';

part 'savor_data_service.g.dart';

abstract class SavorDataService {
  // Auth & Profile
  Future<Map<String, dynamic>?> signIn(String email, String password);
  Future<void> signOut();
  Future<Map<String, dynamic>> getCurrentProfile(String userId);
  Future<List<Map<String, dynamic>>> getStaffProfiles();
  Future<Map<String, dynamic>> createStaffProfile(Map<String, dynamic> profileData);
  Future<void> updateStaffProfile(String id, Map<String, dynamic> profileData);

  // Tables
  Stream<List<Map<String, dynamic>>> tablesStream();
  Future<void> updateTableStatus(int tableId, String status, {String? currentOrderId});

  // Categories & Menu
  Future<List<Map<String, dynamic>>> getCategories();
  Future<List<Map<String, dynamic>>> getMenuItems();
  Future<Map<String, dynamic>> createMenuItem(Map<String, dynamic> itemData);
  Future<Map<String, dynamic>> updateMenuItem(String id, Map<String, dynamic> itemData);
  Future<void> deleteMenuItem(String id);
  Future<void> updateCategoryOrder(List<String> categoryIds);

  // Orders
  Future<List<Map<String, dynamic>>> getOrders();
  Stream<List<Map<String, dynamic>>> kitchenOrdersStream();
  Future<Map<String, dynamic>> createOrder(Map<String, dynamic> orderData, List<Map<String, dynamic>> items);
  Future<void> updateOrderStatus(String orderId, String status);
  Future<void> updateOrderPayment(String orderId, Map<String, dynamic> paymentData);

  // Inventory
  Future<List<Map<String, dynamic>>> getInventory();
  Future<List<Map<String, dynamic>>> getPurchaseRecords();
  Future<Map<String, dynamic>> addInventoryItem(Map<String, dynamic> itemData);
  Future<Map<String, dynamic>> updateInventoryStock(String id, double current, double minimum);
  Future<Map<String, dynamic>> createPurchaseRecord(Map<String, dynamic> recordData);

  // Coupons
  Future<Map<String, dynamic>?> validateCoupon(String code);

  // App Settings
  Future<Map<String, dynamic>> getAppSettings();
  Future<Map<String, dynamic>> updateAppSettings(Map<String, dynamic> settings);

  // Notifications
  Stream<List<Map<String, dynamic>>> notificationsStream(String? role);
  Future<void> markNotificationAsRead(String id);
}

@riverpod
SavorDataService savorService(SavorServiceRef ref) {
  final isConfigured = supabaseUrl.isNotEmpty &&
      supabaseUrl != 'YOUR_SUPABASE_URL' &&
      supabaseAnon.isNotEmpty &&
      supabaseAnon != 'YOUR_SUPABASE_ANON_KEY';
  return isConfigured ? SupabaseSavorService() : MockSavorService();
}
