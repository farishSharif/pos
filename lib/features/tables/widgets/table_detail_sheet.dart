import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/widgets/badge_widget.dart';
import '../../../core/widgets/confirmation_dialog.dart';
import '../models/restaurant_table.dart';
import '../providers/tables_provider.dart';

class TableDetailPanel extends ConsumerWidget {
  final RestaurantTable table;
  final bool isTablet;
  final VoidCallback? onClose;

  const TableDetailPanel({
    super.key,
    required this.table,
    this.isTablet = false,
    this.onClose,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: isTablet
            ? BorderRadius.zero
            : const BorderRadius.only(
                topLeft: Radius.circular(kRadiusSheet),
                topRight: Radius.circular(kRadiusSheet),
              ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Table ${table.tableNumber} Details',
                style: kHeadline.copyWith(fontSize: 22),
              ),
              if (onClose != null)
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: onClose,
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text('Capacity: ${table.capacity} guests', style: kCaption),
              const SizedBox(width: 16),
              BadgeWidget.tableStatus(table.status),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(color: kDivider),
          const SizedBox(height: 16),

          // Quick actions
          Text('ACTIONS', style: kCaption.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),

          if (table.status == 'available') ...[
            ElevatedButton.icon(
              onPressed: () {
                if (!isTablet) Navigator.of(context).pop();
                context.go('/orders?tableId=${table.id}');
              },
              icon: const Icon(Icons.add_shopping_cart, size: 18),
              label: const Text('Take New Order'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
            ),
          ] else if (table.status == 'occupied' || table.status == 'billed' || table.status == 'ready') ...[
            ElevatedButton.icon(
              onPressed: () {
                if (!isTablet) Navigator.of(context).pop();
                context.go('/billing?tableId=${table.id}');
              },
              icon: const Icon(Icons.receipt_long, size: 18),
              label: const Text('Settle Bill / Payment'),
              style: ElevatedButton.styleFrom(
                backgroundColor: kSuccess,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(50),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {
                if (!isTablet) Navigator.of(context).pop();
                context.go('/orders?tableId=${table.id}');
              },
              icon: const Icon(Icons.edit, size: 18),
              label: const Text('Add items / Edit Order'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
            ),
          ] else ...[
            // Statuses like ordered or preparing
            ElevatedButton.icon(
              onPressed: () {
                if (!isTablet) Navigator.of(context).pop();
                context.go('/orders?tableId=${table.id}');
              },
              icon: const Icon(Icons.shopping_basket, size: 18),
              label: const Text('View Current Order'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
            ),
          ],

          const SizedBox(height: 16),
          const Divider(color: kDivider),
          const SizedBox(height: 16),

          // Manual status changes
          Text('MANUAL STATUS OVERRIDE', style: kCaption.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: table.status,
            dropdownColor: kSurface2,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            items: ['available', 'ordered', 'preparing', 'ready', 'occupied', 'billed']
                .map((status) => DropdownMenuItem(
                      value: status,
                      child: Text(status.toUpperCase(), style: kBody),
                    ))
                .toList(),
            onChanged: (newStatus) {
              if (newStatus != null && newStatus != table.status) {
                ConfirmationDialog.show(
                  context: context,
                  title: 'Change Table Status',
                  content: 'Are you sure you want to change Table ${table.tableNumber} status to $newStatus?',
                  onConfirm: () {
                    ref.read(tablesNotifierProvider.notifier).updateStatus(table.id, newStatus);
                  },
                );
              }
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
