import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';
import 'confirmation_dialog.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    if (!authState.isLoggedIn) return const SizedBox.shrink();

    final role = authState.role;
    final currentLoc = GoRouterState.of(context).matchedLocation;

    final items = <_DrawerItem>[];

    // Build items depending on role
    if (role == 'admin') {
      items.addAll([
        _DrawerItem(route: '/dashboard', label: 'Dashboard Summary', icon: Icons.dashboard),
        _DrawerItem(route: '/tables', label: 'Tables View', icon: Icons.table_restaurant),
        _DrawerItem(route: '/orders', label: 'POS Orders', icon: Icons.shopping_basket),
        _DrawerItem(route: '/kitchen', label: 'Kitchen KDS', icon: Icons.kitchen),
        _DrawerItem(route: '/billing', label: 'Billing / Invoice', icon: Icons.receipt_long),
        _DrawerItem(route: '/menu', label: 'Menu Management', icon: Icons.restaurant_menu),
        _DrawerItem(route: '/inventory', label: 'Inventory', icon: Icons.inventory_2),
        _DrawerItem(route: '/staff', label: 'Staff Directory', icon: Icons.people),
        _DrawerItem(route: '/reports', label: 'Reports & Analytics', icon: Icons.analytics),
        _DrawerItem(route: '/settings', label: 'Settings', icon: Icons.settings),
      ]);
    } else if (role == 'cashier') {
      items.addAll([
        _DrawerItem(route: '/tables', label: 'Tables View', icon: Icons.table_restaurant),
        _DrawerItem(route: '/orders', label: 'POS Orders', icon: Icons.shopping_basket),
        _DrawerItem(route: '/billing', label: 'Billing / Cashier', icon: Icons.receipt_long),
        _DrawerItem(route: '/settings', label: 'Settings', icon: Icons.settings),
      ]);
    } else if (role == 'waiter') {
      items.addAll([
        _DrawerItem(route: '/tables', label: 'Tables View', icon: Icons.table_restaurant),
        _DrawerItem(route: '/orders', label: 'POS Orders', icon: Icons.shopping_basket),
        _DrawerItem(route: '/settings', label: 'Settings', icon: Icons.settings),
      ]);
    } else if (role == 'kitchen') {
      items.addAll([
        _DrawerItem(route: '/kitchen', label: 'Kitchen KDS', icon: Icons.kitchen),
        _DrawerItem(route: '/settings', label: 'Settings', icon: Icons.settings),
      ]);
    }

    return Drawer(
      backgroundColor: kSurface,
      child: SafeArea(
        child: Column(
          children: [
            // Logo / Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.asset('assets/royal_logo.png', width: 28, height: 28, fit: BoxFit.cover),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'ROYAL FF',
                    style: kDisplayLarge.copyWith(fontSize: 22, color: kTextPrimary),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: kDivider),
            // Nav Items
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  final isSelected = currentLoc.startsWith(item.route);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).pop(); // Close drawer
                        context.go(item.route);
                      },
                      borderRadius: BorderRadius.circular(kRadiusButton),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected ? kSurface2 : Colors.transparent,
                          borderRadius: BorderRadius.circular(kRadiusButton),
                          border: isSelected
                              ? const Border(left: BorderSide(color: kAccent, width: 4))
                              : null,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            Icon(
                              item.icon,
                              color: isSelected ? kAccent : kTextSecondary,
                              size: 20,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                item.label,
                                style: kBody.copyWith(
                                  color: isSelected ? kTextPrimary : kTextSecondary,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Profile Footer
            const Divider(height: 1, color: kDivider),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: kAccentDim,
                    radius: 18,
                    child: Text(
                      authState.profile?.name.isNotEmpty == true
                          ? authState.profile!.name.substring(0, 1).toUpperCase()
                          : 'U',
                      style: kTitle.copyWith(color: kAccent, fontSize: 14),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          authState.profile?.name ?? 'User',
                          style: kBody.copyWith(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          role.toUpperCase(),
                          style: kCaption.copyWith(fontSize: 10),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout, color: kError, size: 18),
                    onPressed: () {
                      final authNotifier = ref.read(authNotifierProvider.notifier);
                      Navigator.of(context).pop(); // Close drawer
                      ConfirmationDialog.show(
                        context: context,
                        title: 'Sign Out',
                        content: 'Are you sure you want to sign out from ROYAL FF?',
                        confirmLabel: 'Sign Out',
                        confirmColor: kError,
                        onConfirm: () => authNotifier.signOut(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem {
  final String route;
  final String label;
  final IconData icon;

  _DrawerItem({
    required this.route,
    required this.label,
    required this.icon,
  });
}
