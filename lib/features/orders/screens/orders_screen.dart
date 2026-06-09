import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:badges/badges.dart' as bg;
import 'package:go_router/go_router.dart';
import '../../../core/constants/breakpoints.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/widgets/app_bar_widget.dart';
import '../../../core/widgets/bottom_nav.dart';
import '../../../core/widgets/sidebar_navigation.dart';
import '../providers/cart_provider.dart';
import '../widgets/cart_panel.dart';
import '../widgets/menu_grid.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTablet = Breakpoints.isLargeScreen(context);
    final cart = ref.watch(cartNotifierProvider);
    
    // Check if tableId was passed in search/query params (e.g. /orders?tableId=3)
    final uri = GoRouterState.of(context).uri;
    final tableIdStr = uri.queryParameters['tableId'];
    final tableId = tableIdStr != null ? int.tryParse(tableIdStr) : null;

    final cartItemCount = cart.values.fold(0, (sum, item) => sum + item.quantity);

    Widget buildPhoneCartButton(BuildContext ctx) {
      return FloatingActionButton.extended(
        backgroundColor: kAccent,
        foregroundColor: Colors.black,
        onPressed: () {
          showModalBottomSheet(
            context: ctx,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => SizedBox(
              height: MediaQuery.of(context).size.height * 0.85,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(kRadiusSheet),
                  topRight: Radius.circular(kRadiusSheet),
                ),
                child: CartPanel(
                  initialTableId: tableId,
                  onCompleted: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          );
        },
        label: Row(
          children: [
            bg.Badge(
              badgeContent: Text(
                '$cartItemCount',
                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              ),
              showBadge: cartItemCount > 0,
              badgeStyle: const bg.BadgeStyle(badgeColor: kError),
              child: const Icon(Icons.shopping_cart),
            ),
            const SizedBox(width: 8),
            const Text('View Cart'),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: isTablet ? null : const AppBarWidget(title: 'Place Order'),
      bottomNavigationBar: isTablet ? null : const BottomNav(),
      floatingActionButton: !isTablet && cartItemCount > 0 ? buildPhoneCartButton(context) : null,
      body: Row(
        children: [
          if (isTablet) const SidebarNavigation(),
          Expanded(
            child: SafeArea(
              child: Row(
                children: [
                  // Left panel: Menu
                  Expanded(
                    flex: isTablet ? 55 : 100,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isTablet)
                          Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Menu POS', style: kHeadline.copyWith(fontSize: 28)),
                                if (tableId != null)
                                  Chip(
                                    label: Text('Table $tableId'),
                                    backgroundColor: kAccentDim,
                                    labelStyle: kCaption.copyWith(color: kAccent, fontWeight: FontWeight.bold),
                                  ),
                              ],
                            ),
                          ),
                        const Expanded(child: MenuGrid()),
                      ],
                    ),
                  ),
                  // Right panel: Cart (Tablet only)
                  if (isTablet)
                    Expanded(
                      flex: 45,
                      child: CartPanel(
                        initialTableId: tableId,
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
