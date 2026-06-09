import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/dashboard/screens/dashboard_screen.dart';
import 'features/tables/screens/tables_screen.dart';
import 'features/orders/screens/orders_screen.dart';
import 'features/kitchen/screens/kitchen_screen.dart';
import 'features/menu/screens/menu_screen.dart';
import 'features/inventory/screens/inventory_screen.dart';
import 'features/staff/screens/staff_screen.dart';
import 'features/billing/screens/billing_screen.dart';
import 'features/reports/screens/reports_screen.dart';
import 'features/settings/screens/settings_screen.dart';

part 'router.g.dart';

@riverpod
GoRouter router(RouterRef ref) {
  final authState = ref.watch(authNotifierProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isLoggedIn = authState.isLoggedIn;
      final isLoggingIn = state.matchedLocation == '/login';

      if (!isLoggedIn) {
        return isLoggingIn ? null : '/login';
      }

      if (isLoggingIn) {
        return switch (authState.role) {
          'kitchen' => '/kitchen',
          'waiter' => '/tables',
          _ => '/dashboard', // admin, cashier
        };
      }

      // Role authorization checks
      final loc = state.matchedLocation;
      final role = authState.role;

      if (loc == '/dashboard' && role != 'admin') {
        return role == 'kitchen' ? '/kitchen' : '/tables';
      }
      if (loc == '/kitchen' && role != 'kitchen' && role != 'admin') {
        return '/tables';
      }
      if (loc == '/billing' && role != 'cashier' && role != 'admin') {
        return role == 'kitchen' ? '/kitchen' : '/tables';
      }
      final adminOnlyRoutes = ['/menu', '/inventory', '/staff', '/reports', '/settings'];
      if (adminOnlyRoutes.contains(loc) && role != 'admin') {
        return role == 'kitchen' ? '/kitchen' : '/tables';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/tables',
        builder: (context, state) => const TablesScreen(),
      ),
      GoRoute(
        path: '/orders',
        builder: (context, state) => const OrdersScreen(),
      ),
      GoRoute(
        path: '/kitchen',
        builder: (context, state) => const KitchenScreen(),
      ),
      GoRoute(
        path: '/menu',
        builder: (context, state) => const MenuScreen(),
      ),
      GoRoute(
        path: '/inventory',
        builder: (context, state) => const InventoryScreen(),
      ),
      GoRoute(
        path: '/staff',
        builder: (context, state) => const StaffScreen(),
      ),
      GoRoute(
        path: '/billing',
        builder: (context, state) => const BillingScreen(),
      ),
      GoRoute(
        path: '/reports',
        builder: (context, state) => const ReportsScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
}
