import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../orders/models/order.dart';
import '../../orders/providers/orders_provider.dart';
import 'order_card.dart';

class KdsColumn extends ConsumerWidget {
  final String status;
  final String title;
  final List<Order> orders;

  const KdsColumn({
    super.key,
    required this.status,
    required this.title,
    required this.orders,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DragTarget<Order>(
      onAccept: (order) {
        if (order.status != status) {
          ref.read(ordersNotifierProvider.notifier).updateStatus(order.id, status);
        }
      },
      builder: (context, candidateData, rejectedData) {
        final isOver = candidateData.isNotEmpty;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: isOver ? kSurface2 : kSurface.withOpacity(0.5),
            borderRadius: BorderRadius.circular(kRadiusCard),
            border: Border.all(
              color: isOver ? kAccent : kDivider,
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: kSurface2,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(kRadiusCard),
                    topRight: Radius.circular(kRadiusCard),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title.toUpperCase(),
                      style: kTitle.copyWith(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: kBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${orders.length}',
                        style: kCaption.copyWith(fontWeight: FontWeight.bold, color: kAccent),
                      ),
                    ),
                  ],
                ),
              ),
              // Card List
              Expanded(
                child: orders.isEmpty
                    ? Center(
                        child: Text(
                          'No orders',
                          style: kCaption,
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: orders.length,
                        itemBuilder: (context, index) {
                          final order = orders[index];
                          return LongPressDraggable<Order>(
                            data: order,
                            feedback: SizedBox(
                              width: 240,
                              child: Material(
                                color: Colors.transparent,
                                child: OrderCard(order: order),
                              ),
                            ),
                            childWhenDragging: Opacity(
                              opacity: 0.3,
                              child: OrderCard(order: order),
                            ),
                            child: OrderCard(
                              order: order,
                              onTap: () {
                                // Double tap or single tap to quick advance status
                                _showQuickAdvanceDialog(context, ref, order);
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showQuickAdvanceDialog(BuildContext context, WidgetRef ref, Order order) {
    final nextStatus = switch (order.status) {
      'pending' => 'preparing',
      'preparing' => 'ready',
      'ready' => 'served',
      _ => null,
    };

    if (nextStatus == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kSurface,
        title: Text('Update Order Status', style: kTitle),
        content: Text(
          'Move Order #${order.id.substring(order.id.length - 4).toUpperCase()} to ${nextStatus.toUpperCase()}?',
          style: kBody,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel', style: kBody.copyWith(color: kTextSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(ordersNotifierProvider.notifier).updateStatus(order.id, nextStatus);
              Navigator.of(context).pop();
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}
