import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/constants/breakpoints.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/app_bar_widget.dart';
import '../../../core/widgets/bottom_nav.dart';
import '../../../core/widgets/sidebar_navigation.dart';
import '../../../core/widgets/app_drawer.dart';
import '../../../core/widgets/stat_card.dart';
import '../../../core/widgets/badge_widget.dart';
import '../../../core/widgets/loading_shimmer.dart';
import '../../inventory/providers/inventory_provider.dart';
import '../../orders/providers/orders_provider.dart';
import '../providers/dashboard_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTablet = Breakpoints.isLargeScreen(context);
    final stats = ref.watch(dashboardStatsProvider);
    final inventoryAsync = ref.watch(inventoryNotifierProvider);
    final ordersAsync = ref.watch(ordersListProvider);

    return Scaffold(
      appBar:
          isTablet ? null : const AppBarWidget(title: 'ROYAL FF Dashboard'),
      drawer: isTablet ? null : const AppDrawer(),
      bottomNavigationBar: isTablet ? null : const BottomNav(),
      body: Row(
        children: [
          if (isTablet) const SidebarNavigation(),
          Expanded(
            child: SafeArea(
              child: stats == null
                  ? Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: LoadingShimmer.grid(count: 4),
                    )
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (isTablet) ...[
                                Text('Dashboard Summary',
                                    style: kHeadline.copyWith(fontSize: 28)),
                                const SizedBox(height: 4),
                                Text(
                                    'Overview of daily operations and restaurant performance.',
                                    style: kCaption),
                                const SizedBox(height: 24),
                              ],
                              _buildMetricGrid(context, stats, isTablet),
                              const SizedBox(height: 24),
                              if (isTablet)
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Column(
                                        children: [
                                          _buildSalesTrendCard(context),
                                          const SizedBox(height: 24),
                                          _buildQuickActions(context),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 24),
                                    Expanded(
                                      flex: 2,
                                      child: Column(
                                        children: [
                                          _buildLowStockWarningCard(
                                              context, inventoryAsync),
                                          const SizedBox(height: 24),
                                          _buildRecentActivityCard(
                                              context, ordersAsync),
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                              else ...[
                                _buildSalesTrendCard(context),
                                const SizedBox(height: 16),
                                _buildQuickActions(context),
                                const SizedBox(height: 16),
                                _buildLowStockWarningCard(
                                    context, inventoryAsync),
                                const SizedBox(height: 16),
                                _buildRecentActivityCard(context, ordersAsync),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricGrid(
      BuildContext context, DashboardStats stats, bool isTablet) {
    final double sales = stats.totalSales;
    final int orders = stats.totalOrders;
    final double aov = stats.averageOrderValue;
    final int activeTables = stats.activeTablesCount;

    return GridView.count(
      crossAxisCount: isTablet ? 4 : 2,
      crossAxisSpacing: isTablet ? 16 : 12,
      mainAxisSpacing: isTablet ? 16 : 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: isTablet ? 1.6 : 1.4,
      children: [
        StatCard(
          title: 'TOTAL SALES',
          value: CurrencyFormatter.format(sales),
          icon: Icons.monetization_on,
          iconColor: kAccent,
          subtitle: '+12.4% vs yesterday',
        ),
        StatCard(
          title: 'TOTAL ORDERS',
          value: '$orders',
          icon: Icons.receipt_long,
          iconColor: kInfo,
          subtitle: '+8.2% vs yesterday',
        ),
        StatCard(
          title: 'AVERAGE TICKET',
          value: CurrencyFormatter.format(aov),
          icon: Icons.analytics,
          iconColor: kSuccess,
          subtitle: 'AOV metric',
        ),
        StatCard(
          title: 'ACTIVE TABLES',
          value: '$activeTables',
          icon: Icons.restaurant_menu,
          iconColor: kWarning,
          subtitle: 'Currently occupied',
        ),
      ],
    );
  }

  Widget _buildSalesTrendCard(BuildContext context) {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(kRadiusCard),
        border: Border.all(color: kDivider, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Sales Revenue Trend',
                  style: kHeadline.copyWith(fontSize: 18)),
              Text('Last 7 Days', style: kCaption),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) =>
                      const FlLine(color: kDivider, strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 46,
                      getTitlesWidget: (value, meta) {
                        if (value % 5000 != 0) return const SizedBox();
                        return Text(
                          '${(value / 1000).toStringAsFixed(0)}k',
                          style: kCaption.copyWith(fontSize: 10),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final days = [
                          'Mon',
                          'Tue',
                          'Wed',
                          'Thu',
                          'Fri',
                          'Sat',
                          'Sun'
                        ];
                        final int idx = value.toInt();
                        if (idx >= 0 && idx < days.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(days[idx],
                                style: kCaption.copyWith(fontSize: 10)),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 6,
                minY: 0,
                maxY: 25000,
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 12000),
                      FlSpot(1, 15000),
                      FlSpot(2, 11000),
                      FlSpot(3, 18000),
                      FlSpot(4, 22000),
                      FlSpot(5, 17000),
                      FlSpot(6, 24000),
                    ],
                    isCurved: true,
                    color: kAccent,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: kAccent.withOpacity(0.12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      _ActionItem(
          label: 'New Order',
          icon: Icons.shopping_cart,
          color: kAccent,
          route: '/orders'),
      _ActionItem(
          label: 'Table View',
          icon: Icons.grid_view,
          color: kInfo,
          route: '/tables'),
      _ActionItem(
          label: 'Kitchen Display',
          icon: Icons.kitchen,
          color: kWarning,
          route: '/kitchen'),
      _ActionItem(
          label: 'Manage Menu',
          icon: Icons.menu_book,
          color: kSuccess,
          route: '/menu'),
      _ActionItem(
          label: 'Staff Settings',
          icon: Icons.people,
          color: Colors.purple,
          route: '/staff'),
      _ActionItem(
          label: 'Analytics Reports',
          icon: Icons.bar_chart,
          color: Colors.teal,
          route: '/reports'),
    ];

    final isTablet = Breakpoints.isLargeScreen(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(kRadiusCard),
        border: Border.all(color: kDivider, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quick Management Actions',
              style: kHeadline.copyWith(fontSize: 18)),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: actions.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isTablet ? 3 : 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.4,
            ),
            itemBuilder: (context, idx) {
              final act = actions[idx];
              return InkWell(
                onTap: () => context.go(act.route),
                borderRadius: BorderRadius.circular(kRadiusCard),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: kBg,
                    borderRadius: BorderRadius.circular(kRadiusCard),
                    border: Border.all(color: kDivider, width: 1),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: act.color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(act.icon, color: act.color, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          act.label,
                          style: kBody.copyWith(
                              fontWeight: FontWeight.bold, fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLowStockWarningCard(
      BuildContext context, AsyncValue<List<dynamic>> inventoryAsync) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(kRadiusCard),
        border: Border.all(color: kDivider, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Low Stock Alerts', style: kHeadline.copyWith(fontSize: 18)),
              const Icon(Icons.warning_amber_rounded,
                  color: kWarning, size: 22),
            ],
          ),
          const SizedBox(height: 16),
          inventoryAsync.when(
            data: (items) {
              final lowStock =
                  items.where((i) => i.currentStock <= i.minimumStock).toList();
              if (lowStock.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle_outline,
                          color: kSuccess, size: 18),
                      const SizedBox(width: 8),
                      Text('All stock levels normal.',
                          style: kCaption.copyWith(color: kSuccess)),
                    ],
                  ),
                );
              }
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: lowStock.length > 3 ? 3 : lowStock.length,
                separatorBuilder: (_, __) =>
                    const Divider(color: kDivider, height: 16),
                itemBuilder: (context, idx) {
                  final item = lowStock[idx];
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.name,
                              style:
                                  kBody.copyWith(fontWeight: FontWeight.bold)),
                          Text(
                              'Min threshold: ${item.minimumStock} ${item.unit}',
                              style: kCaption),
                        ],
                      ),
                      BadgeWidget(
                        label: '${item.currentStock} ${item.unit}',
                        color: kWarning,
                      ),
                    ],
                  );
                },
              );
            },
            loading: () => Center(child: LoadingShimmer.list(count: 2)),
            error: (err, __) => Text('Error: $err', style: kCaption),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivityCard(
      BuildContext context, AsyncValue<List<dynamic>> ordersAsync) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(kRadiusCard),
        border: Border.all(color: kDivider, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Recent Orders', style: kHeadline.copyWith(fontSize: 18)),
              GestureDetector(
                onTap: () => context.go('/tables'),
                child: Text('View Tables',
                    style: kCaption.copyWith(color: kAccent)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ordersAsync.when(
            data: (orders) {
              if (orders.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: Center(
                    child: Text('No orders created yet.', style: kCaption),
                  ),
                );
              }
              // Display last 3 orders
              final recent = orders.reversed.take(3).toList();
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: recent.length,
                separatorBuilder: (_, __) =>
                    const Divider(color: kDivider, height: 16),
                itemBuilder: (context, idx) {
                  final ord = recent[idx];
                  final statusCol =
                      switch (ord.status.toString().toLowerCase()) {
                    'pending' => kWarning,
                    'cooking' => kInfo,
                    'prepared' => kSuccess,
                    'completed' => kAccent,
                    _ => kTextSecondary,
                  };
                  return Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: statusCol.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.receipt_long,
                            color: statusCol, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ord.customerName != null &&
                                      ord.customerName!.isNotEmpty
                                  ? ord.customerName!
                                  : 'Table ${ord.tableId ?? "Takeaway"}',
                              style:
                                  kBody.copyWith(fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'Type: ${ord.orderType.toUpperCase()} • ${ord.status.toUpperCase()}',
                              style: kCaption.copyWith(fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        CurrencyFormatter.format(ord.total),
                        style: kBody.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  );
                },
              );
            },
            loading: () => Center(child: LoadingShimmer.list(count: 2)),
            error: (err, __) => Text('Error: $err', style: kCaption),
          ),
        ],
      ),
    );
  }
}

class _ActionItem {
  final String label;
  final IconData icon;
  final Color color;
  final String route;

  _ActionItem({
    required this.label,
    required this.icon,
    required this.color,
    required this.route,
  });
}
