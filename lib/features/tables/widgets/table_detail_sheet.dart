import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/widgets/badge_widget.dart';
import '../../../core/widgets/confirmation_dialog.dart';
import '../../../core/widgets/custom_snackbar.dart';
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
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'Table ${table.tableNumber} Details',
                style: kHeadline.copyWith(fontSize: 20),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(8),
                    icon: const Icon(Icons.edit_outlined, color: kAccent, size: 18),
                    tooltip: 'Edit Table',
                    onPressed: () => _showEditTableDialog(context, ref, table),
                  ),
                  IconButton(
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(8),
                    icon: const Icon(Icons.delete_outline, color: kError, size: 18),
                    tooltip: 'Delete Table',
                    onPressed: () => _confirmDeleteTable(context, ref, table),
                  ),
                  if (onClose != null) ...[
                    IconButton(
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(8),
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: onClose,
                    ),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text('Capacity: ${table.capacity} guests', style: kCaption),
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

  void _showEditTableDialog(BuildContext outerContext, WidgetRef ref, RestaurantTable table) {
    final numberController = TextEditingController(text: table.tableNumber.toString());
    final capacityController = TextEditingController(text: table.capacity.toString());
    showDialog(
      context: outerContext,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: kSurface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kRadiusCard)),
          title: Text('Edit Table ${table.tableNumber}', style: const TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: numberController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Table Number'),
                style: kBody,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: capacityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Capacity (Guests)'),
                style: kBody,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel', style: TextStyle(color: kTextSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: kAccent, foregroundColor: Colors.black),
              onPressed: () async {
                final numVal = int.tryParse(numberController.text.trim());
                final capVal = int.tryParse(capacityController.text.trim());
                if (numVal != null && capVal != null) {
                  Navigator.pop(dialogContext);
                  final updated = table.copyWith(
                    tableNumber: numVal,
                    capacity: capVal,
                  );
                  try {
                    await ref.read(tablesNotifierProvider.notifier).createOrUpdateTable(updated);
                    if (outerContext.mounted) CustomSnackBar.showSuccess(outerContext, 'Table details updated.');
                  } catch (e) {
                    if (outerContext.mounted) CustomSnackBar.showError(outerContext, 'Failed to update table: $e');
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteTable(BuildContext context, WidgetRef ref, RestaurantTable table) {
    ConfirmationDialog.show(
      context: context,
      title: 'Delete Table',
      content: 'Are you sure you want to delete Table ${table.tableNumber}?',
      confirmLabel: 'Delete',
      confirmColor: kError,
      onConfirm: () async {
        try {
          await ref.read(tablesNotifierProvider.notifier).deleteTable(table.id);
          if (context.mounted) CustomSnackBar.showSuccess(context, 'Table ${table.tableNumber} deleted.');
        } catch (e) {
          if (context.mounted) CustomSnackBar.showError(context, 'Failed to delete table: $e');
        }
      },
    );
  }
}
