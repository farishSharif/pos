import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../theme/colors.dart';

class BottomNav extends ConsumerWidget {
  const BottomNav({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    if (!authState.isLoggedIn) return const SizedBox.shrink();

    final role = authState.role;
    final currentLoc = GoRouterState.of(context).matchedLocation;

    final items = <_NavItem>[];

    if (role == 'admin') {
      items.addAll([
        _NavItem(route: '/dashboard', label: 'Dashboard', icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard),
        _NavItem(route: '/tables', label: 'Tables', icon: Icons.table_restaurant_outlined, activeIcon: Icons.table_restaurant),
        _NavItem(route: '/orders', label: 'POS', icon: Icons.shopping_basket_outlined, activeIcon: Icons.shopping_basket),
        _NavItem(route: '/settings', label: 'Settings', icon: Icons.settings_outlined, activeIcon: Icons.settings),
      ]);
    } else if (role == 'cashier') {
      items.addAll([
        _NavItem(route: '/tables', label: 'Tables', icon: Icons.table_restaurant_outlined, activeIcon: Icons.table_restaurant),
        _NavItem(route: '/orders', label: 'POS', icon: Icons.shopping_basket_outlined, activeIcon: Icons.shopping_basket),
        _NavItem(route: '/billing', label: 'Billing', icon: Icons.receipt_long_outlined, activeIcon: Icons.receipt_long),
        _NavItem(route: '/settings', label: 'Settings', icon: Icons.settings_outlined, activeIcon: Icons.settings),
      ]);
    } else if (role == 'waiter') {
      items.addAll([
        _NavItem(route: '/tables', label: 'Tables', icon: Icons.table_restaurant_outlined, activeIcon: Icons.table_restaurant),
        _NavItem(route: '/orders', label: 'POS', icon: Icons.shopping_basket_outlined, activeIcon: Icons.shopping_basket),
        _NavItem(route: '/settings', label: 'Settings', icon: Icons.settings_outlined, activeIcon: Icons.settings),
      ]);
    } else if (role == 'kitchen') {
      items.addAll([
        _NavItem(route: '/kitchen', label: 'KDS', icon: Icons.kitchen_outlined, activeIcon: Icons.kitchen),
        _NavItem(route: '/settings', label: 'Settings', icon: Icons.settings_outlined, activeIcon: Icons.settings),
      ]);
    }

    if (items.isEmpty) return const SizedBox.shrink();

    final activeIndex = items.indexWhere((item) => currentLoc.startsWith(item.route));
    final currentIndex = activeIndex == -1 ? 0 : activeIndex;

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        context.go(items[index].route);
      },
      items: items.map((item) {
        return BottomNavigationBarItem(
          icon: Icon(item.icon),
          activeIcon: Icon(item.activeIcon, color: kAccent),
          label: item.label,
        );
      }).toList(),
    );
  }
}

class _NavItem {
  final String route;
  final String label;
  final IconData icon;
  final IconData activeIcon;

  _NavItem({
    required this.route,
    required this.label,
    required this.icon,
    required this.activeIcon,
  });
}
