import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';
import 'confirmation_dialog.dart';

class SidebarNavigation extends ConsumerWidget {
  const SidebarNavigation({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    if (!authState.isLoggedIn) return const SizedBox.shrink();

    final role = authState.role;
    final currentLoc = GoRouterState.of(context).matchedLocation;

    final items = <_SidebarItem>[];

    // Build items depending on role
    if (role == 'admin') {
      items.addAll([
        _SidebarItem(route: '/dashboard', label: 'Dashboard', icon: Icons.dashboard),
        _SidebarItem(route: '/tables', label: 'Tables', icon: Icons.table_restaurant),
        _SidebarItem(route: '/orders', label: 'POS Orders', icon: Icons.shopping_basket),
        _SidebarItem(route: '/kitchen', label: 'KDS Screen', icon: Icons.kitchen),
        _SidebarItem(route: '/billing', label: 'Billing / POS', icon: Icons.receipt_long),
        _SidebarItem(route: '/menu', label: 'Menu Mgmt', icon: Icons.restaurant_menu),
        _SidebarItem(route: '/inventory', label: 'Inventory', icon: Icons.inventory_2),
        _SidebarItem(route: '/staff', label: 'Staff Directory', icon: Icons.people),
        _SidebarItem(route: '/reports', label: 'Reports', icon: Icons.analytics),
        _SidebarItem(route: '/settings', label: 'Settings', icon: Icons.settings),
      ]);
    } else if (role == 'cashier') {
      items.addAll([
        _SidebarItem(route: '/tables', label: 'Tables', icon: Icons.table_restaurant),
        _SidebarItem(route: '/orders', label: 'POS Orders', icon: Icons.shopping_basket),
        _SidebarItem(route: '/billing', label: 'Billing / Cashier', icon: Icons.receipt_long),
        _SidebarItem(route: '/settings', label: 'Settings', icon: Icons.settings),
      ]);
    } else if (role == 'waiter') {
      items.addAll([
        _SidebarItem(route: '/tables', label: 'Tables', icon: Icons.table_restaurant),
        _SidebarItem(route: '/orders', label: 'POS Orders', icon: Icons.shopping_basket),
        _SidebarItem(route: '/settings', label: 'Settings', icon: Icons.settings),
      ]);
    } else if (role == 'kitchen') {
      items.addAll([
        _SidebarItem(route: '/kitchen', label: 'Kitchen KDS', icon: Icons.kitchen),
        _SidebarItem(route: '/settings', label: 'Settings', icon: Icons.settings),
      ]);
    }

    return Container(
      width: 260,
      decoration: const BoxDecoration(
        color: kSurface,
        border: Border(right: BorderSide(color: kDivider, width: 1)),
      ),
      child: Column(
        children: [
          // Logo Section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                const Icon(Icons.restaurant, color: kAccent, size: 28),
                const SizedBox(width: 12),
                Text(
                  'SAVOR POS',
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
                    onTap: () => context.go(item.route),
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
                    authState.profile?.name.substring(0, 1).toUpperCase() ?? 'U',
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
                    ConfirmationDialog.show(
                      context: context,
                      title: 'Sign Out',
                      content: 'Are you sure you want to sign out from Savor POS?',
                      confirmLabel: 'Sign Out',
                      confirmColor: kError,
                      onConfirm: () => ref.read(authNotifierProvider.notifier).signOut(),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem {
  final String route;
  final String label;
  final IconData icon;

  _SidebarItem({
    required this.route,
    required this.label,
    required this.icon,
  });
}
