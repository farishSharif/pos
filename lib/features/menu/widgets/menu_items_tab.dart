import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/breakpoints.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/confirmation_dialog.dart';
import '../../../core/widgets/custom_snackbar.dart';
import '../../orders/providers/orders_provider.dart';
import '../models/menu_item.dart';
import '../providers/menu_provider.dart';
import 'add_item_sheet.dart';

class MenuItemsTab extends ConsumerWidget {
  final List<Map<String, dynamic>> categories;

  const MenuItemsTab({
    super.key,
    required this.categories,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(menuItemsProvider);
    final isTablet = Breakpoints.isLargeScreen(context);

    void showEditSheet(MenuItem item) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => AddItemSheet(
          existingItem: item,
          categories: categories,
        ),
      );
    }

    void confirmDelete(MenuItem item) {
      ConfirmationDialog.show(
        context: context,
        title: 'Delete Menu Item',
        content: 'Are you sure you want to delete "${item.name}" from the menu?',
        confirmLabel: 'Delete',
        confirmColor: kError,
        onConfirm: () async {
          try {
            await ref.read(menuNotifierProvider.notifier).removeItem(item.id);
            if (context.mounted) CustomSnackBar.showSuccess(context, 'Menu item deleted');
          } catch (e) {
            if (context.mounted) CustomSnackBar.showError(context, 'Failed to delete item: $e');
          }
        },
      );
    }

    Widget buildPhoneList(List<MenuItem> items) {
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          final catName = categories.firstWhere(
            (c) => c['id'] == item.categoryId,
            orElse: () => {'name': 'Unknown'},
          )['name'] as String;

          return Dismissible(
            key: Key(item.id),
            background: Container(
              color: kAccentDim.withOpacity(0.5),
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 20),
              child: const Icon(Icons.edit, color: kAccent),
            ),
            secondaryBackground: Container(
              color: kError.withOpacity(0.2),
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child: const Icon(Icons.delete, color: kError),
            ),
            confirmDismiss: (direction) async {
              if (direction == DismissDirection.startToEnd) {
                showEditSheet(item);
                return false; // Don't swipe away
              } else {
                confirmDelete(item);
                return false; // Managed by dialog
              }
            },
            child: Card(
              color: kSurface,
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: kSurface2,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: item.imageUrl != null
                      ? Image.network(item.imageUrl!, fit: BoxFit.cover)
                      : const Icon(Icons.fastfood, color: kTextSecondary),
                ),
                title: Text(item.name, style: kBody.copyWith(fontWeight: FontWeight.bold)),
                subtitle: Text('$catName • ${item.prepTimeMinutes}m prep', style: kCaption),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(CurrencyFormatter.format(item.price), style: kPrice.copyWith(fontSize: 14)),
                    const SizedBox(width: 8),
                    Switch(
                      value: item.isAvailable,
                      activeColor: kAccent,
                      onChanged: (val) {
                        ref.read(menuNotifierProvider.notifier).toggleAvailability(item.id, val);
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    }

    Widget buildTabletTable(List<MenuItem> items) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Container(
          decoration: BoxDecoration(
            color: kSurface,
            borderRadius: BorderRadius.circular(kRadiusCard),
            border: Border.all(color: kDivider),
          ),
          child: DataTable(
            headingRowColor: MaterialStateProperty.all(kSurface2),
            columns: [
              DataColumn(label: Text('Preview', style: kTitle.copyWith(fontSize: 14))),
              DataColumn(label: Text('Item Name', style: kTitle.copyWith(fontSize: 14))),
              DataColumn(label: Text('Category', style: kTitle.copyWith(fontSize: 14))),
              DataColumn(label: Text('Price', style: kTitle.copyWith(fontSize: 14))),
              DataColumn(label: Text('Prep Time', style: kTitle.copyWith(fontSize: 14))),
              DataColumn(label: Text('Status', style: kTitle.copyWith(fontSize: 14))),
              DataColumn(label: Text('Actions', style: kTitle.copyWith(fontSize: 14))),
            ],
            rows: items.map((item) {
              final catName = categories.firstWhere(
                (c) => c['id'] == item.categoryId,
                orElse: () => {'name': 'Unknown'},
              )['name'] as String;

              return DataRow(
                cells: [
                  DataCell(
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: kSurface2,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: item.imageUrl != null
                          ? Image.network(item.imageUrl!, fit: BoxFit.cover)
                          : const Icon(Icons.fastfood, color: kTextSecondary, size: 20),
                    ),
                  ),
                  DataCell(Text(item.name, style: kBody.copyWith(fontWeight: FontWeight.bold))),
                  DataCell(Text(catName, style: kBody)),
                  DataCell(Text(CurrencyFormatter.format(item.price), style: kPrice.copyWith(fontSize: 14))),
                  DataCell(Text('${item.prepTimeMinutes} mins', style: kBody)),
                  DataCell(
                    Switch(
                      value: item.isAvailable,
                      activeColor: kAccent,
                      onChanged: (val) {
                        ref.read(menuNotifierProvider.notifier).toggleAvailability(item.id, val);
                      },
                    ),
                  ),
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: kAccent, size: 20),
                          onPressed: () => showEditSheet(item),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: kError, size: 20),
                          onPressed: () => confirmDelete(item),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      );
    }

    return itemsAsync.when(
      data: (rows) {
        final items = rows.map((r) => MenuItem.fromJson(r)).toList();
        return isTablet ? buildTabletTable(items) : buildPhoneList(items);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, __) => Center(child: Text('Error: $err')),
    );
  }
}
