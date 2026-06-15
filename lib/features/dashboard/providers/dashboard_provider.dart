import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../orders/providers/orders_provider.dart';
import '../../tables/providers/tables_provider.dart';
import '../../inventory/providers/inventory_provider.dart';

part 'dashboard_provider.g.dart';

class DashboardStats {
  final double totalSales;
  final int totalOrders;
  final double averageOrderValue;
  final int activeTablesCount;
  final int lowStockItemsCount;

  DashboardStats({
    required this.totalSales,
    required this.totalOrders,
    required this.averageOrderValue,
    required this.activeTablesCount,
    required this.lowStockItemsCount,
  });
}

@riverpod
DashboardStats? dashboardStats(DashboardStatsRef ref) {
  final ordersAsync = ref.watch(ordersListProvider);
  final tablesAsync = ref.watch(tablesStreamProvider);
  final inventoryAsync = ref.watch(inventoryNotifierProvider);

  if (ordersAsync.value == null || tablesAsync.value == null || inventoryAsync.value == null) {
    return null;
  }

  final orders = ordersAsync.value!;
  final tables = tablesAsync.value!;
  final inventory = inventoryAsync.value!;

  // Daily sales stats (assuming today's orders or general database orders for simplicity)
  // Let's filter orders that are paid or completed to get the sales figure.
  // Actually, we can sum all paid orders.
  final completedPaidOrders = orders.where((o) => o.status == 'completed' || o.status == 'billed' || o.paymentMethod != null).toList();
  final totalSales = completedPaidOrders.fold<double>(0, (sum, o) => sum + o.total);
  final totalOrders = orders.length;
  final aov = totalOrders > 0 ? (totalSales / totalOrders) : 0.0;

  final activeTablesCount = tables.where((t) => t.status == 'occupied').length;
  final lowStockItemsCount = inventory.where((i) => i.currentStock <= i.minimumStock).length;

  return DashboardStats(
    totalSales: totalSales,
    totalOrders: totalOrders,
    averageOrderValue: aov,
    activeTablesCount: activeTablesCount,
    lowStockItemsCount: lowStockItemsCount,
  );
}
