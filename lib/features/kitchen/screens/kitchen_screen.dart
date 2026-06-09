import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/breakpoints.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/app_bar_widget.dart';
import '../../../core/widgets/bottom_nav.dart';
import '../../../core/widgets/sidebar_navigation.dart';
import '../../../core/widgets/loading_shimmer.dart';
import '../../../core/widgets/error_state_widget.dart';
import '../../orders/models/order.dart';
import '../providers/kitchen_provider.dart';
import '../widgets/kds_column.dart';

class KitchenScreen extends ConsumerStatefulWidget {
  const KitchenScreen({super.key});

  @override
  ConsumerState<KitchenScreen> createState() => _KitchenScreenState();
}

class _KitchenScreenState extends ConsumerState<KitchenScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _lastOrderCount = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _triggerNewOrderEffect() {
    HapticFeedback.heavyImpact();
    // In a full implementation, we could play a local notification sound here.
  }

  @override
  Widget build(BuildContext context) {
    final ordersStream = ref.watch(kitchenOrdersStreamProvider);
    final isTablet = Breakpoints.isLargeScreen(context);

    // Listen to changes in order list size to trigger haptics
    ordersStream.whenData((orders) {
      final newOrders = orders.where((o) => o.status == 'pending').toList();
      if (newOrders.length > _lastOrderCount) {
        _triggerNewOrderEffect();
      }
      _lastOrderCount = newOrders.length;
    });

    Widget buildColumns(List<Order> allOrders) {
      final newOrders = allOrders.where((o) => o.status == 'pending').toList();
      final prepOrders = allOrders.where((o) => o.status == 'preparing').toList();
      final readyOrders = allOrders.where((o) => o.status == 'ready').toList();
      final servedOrders = allOrders.where((o) => o.status == 'served').toList();

      if (isTablet) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: KdsColumn(status: 'pending', title: 'New Orders', orders: newOrders)),
            Expanded(child: KdsColumn(status: 'preparing', title: 'Preparing', orders: prepOrders)),
            Expanded(child: KdsColumn(status: 'ready', title: 'Ready', orders: readyOrders)),
            Expanded(child: KdsColumn(status: 'served', title: 'Served', orders: servedOrders)),
          ],
        );
      }

      return Column(
        children: [
          TabBar(
            controller: _tabController,
            isScrollable: false,
            indicatorColor: kAccent,
            labelColor: kAccent,
            unselectedLabelColor: kTextSecondary,
            tabs: [
              Tab(text: 'New (${newOrders.length})'),
              Tab(text: 'Prep (${prepOrders.length})'),
              Tab(text: 'Ready (${readyOrders.length})'),
              Tab(text: 'Served (${servedOrders.length})'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                KdsColumn(status: 'pending', title: 'New Orders', orders: newOrders),
                KdsColumn(status: 'preparing', title: 'Preparing', orders: prepOrders),
                KdsColumn(status: 'ready', title: 'Ready', orders: readyOrders),
                KdsColumn(status: 'served', title: 'Served', orders: servedOrders),
              ],
            ),
          ),
        ],
      );
    }

    return Scaffold(
      appBar: isTablet ? null : const AppBarWidget(title: 'Kitchen Display'),
      bottomNavigationBar: isTablet ? null : const BottomNav(),
      body: Row(
        children: [
          if (isTablet) const SidebarNavigation(),
          Expanded(
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (isTablet)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Kitchen Display System (KDS)',
                            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: kTextPrimary),
                          ),
                          IconButton(
                            icon: const Icon(Icons.refresh),
                            onPressed: () => ref.invalidate(kitchenOrdersStreamProvider),
                          ),
                        ],
                      ),
                    ),
                  Expanded(
                    child: ordersStream.when(
                      data: (orders) => buildColumns(orders),
                      loading: () => Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: LoadingShimmer.list(count: 6),
                        ),
                      ),
                      error: (err, stack) => ErrorStateWidget(
                        errorMessage: err.toString(),
                        onRetry: () => ref.invalidate(kitchenOrdersStreamProvider),
                      ),
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
}
