import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../providers/notifications_provider.dart';

class NotificationsSheet extends ConsumerWidget {
  const NotificationsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifAsync = ref.watch(notificationsStreamProvider);

    IconData _typeIcon(String type) {
      return switch (type) {
        'order_ready' => Icons.room_service,
        'low_stock' => Icons.inventory,
        'payment' => Icons.payment,
        'new_order' => Icons.receipt_long,
        _ => Icons.notifications,
      };
    }

    Color _typeColor(String type) {
      return switch (type) {
        'order_ready' => kInfo,
        'low_stock' => kWarning,
        'payment' => kSuccess,
        'new_order' => kAccent,
        _ => kTextSecondary,
      };
    }

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: kSurface,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(kRadiusSheet),
              topRight: Radius.circular(kRadiusSheet),
            ),
          ),
          child: Column(
            children: [
              // Handle + Title
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: kDivider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Notifications', style: kHeadline.copyWith(fontSize: 22)),
                    IconButton(
                      icon: const Icon(Icons.close, color: kTextSecondary),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: kDivider),
              // List
              Expanded(
                child: notifAsync.when(
                  data: (notifications) {
                    if (notifications.isEmpty) {
                      return const EmptyStateWidget(
                        title: 'All Caught Up!',
                        subtitle: 'No new notifications right now.',
                        fallbackIcon: Icons.notifications_none,
                      );
                    }
                    return ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: notifications.length,
                      separatorBuilder: (_, __) => const Divider(height: 1, color: kDivider),
                      itemBuilder: (context, index) {
                        final n = notifications[index];
                        final createdAt = DateTime.tryParse(n.createdAt);
                        return ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _typeColor(n.type).withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(_typeIcon(n.type), color: _typeColor(n.type), size: 20),
                          ),
                          title: Text(
                            n.title,
                            style: kBody.copyWith(
                              fontWeight: n.isRead ? FontWeight.normal : FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (n.body != null) Text(n.body!, style: kCaption, maxLines: 2, overflow: TextOverflow.ellipsis),
                              if (createdAt != null)
                                Text(DateFormatter.timeElapsedSince(createdAt), style: kCaption.copyWith(fontSize: 10)),
                            ],
                          ),
                          trailing: n.isRead
                              ? null
                              : GestureDetector(
                                  onTap: () => ref.read(notificationsNotifierProvider.notifier).markAsRead(n.id),
                                  child: Container(
                                    width: 8, height: 8,
                                    decoration: const BoxDecoration(color: kAccent, shape: BoxShape.circle),
                                  ),
                                ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 8),
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, __) => Center(child: Text('Error: $err')),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
