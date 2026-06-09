import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:badges/badges.dart' as bg;
import '../../features/auth/providers/auth_provider.dart';
import '../../features/notifications/providers/notifications_provider.dart';
import '../../features/notifications/widgets/notifications_sheet.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';
import 'badge_widget.dart';

class AppBarWidget extends ConsumerWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? extraActions;

  const AppBarWidget({
    super.key,
    required this.title,
    this.extraActions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final notificationsAsync = ref.watch(notificationsStreamProvider);

    final unreadCount = notificationsAsync.value?.where((n) => !n.isRead).length ?? 0;

    return AppBar(
      title: Text(title, style: kHeadline),
      actions: [
        if (extraActions != null) ...extraActions!,
        if (authState.isLoggedIn) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: BadgeWidget.role(authState.role),
          ),
          const SizedBox(width: 8),
          bg.Badge(
            position: bg.BadgePosition.topEnd(top: 10, end: 6),
            badgeAnimation: const bg.BadgeAnimation.fade(),
            showBadge: unreadCount > 0,
            badgeStyle: const bg.BadgeStyle(
              badgeColor: kAccent,
              padding: EdgeInsets.all(4),
            ),
            badgeContent: Text(
              '$unreadCount',
              style: kCaption.copyWith(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold),
            ),
            child: IconButton(
              icon: const Icon(Icons.notifications_outlined, color: kTextPrimary),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => const NotificationsSheet(),
                );
              },
            ),
          ),
        ],
        const SizedBox(width: 8),
      ],
    );
  }
}
