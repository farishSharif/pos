import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/breakpoints.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/app_bar_widget.dart';
import '../../../core/widgets/bottom_nav.dart';
import '../../../core/widgets/sidebar_navigation.dart';
import '../../../core/widgets/app_drawer.dart';
import '../../../core/widgets/badge_widget.dart';
import '../../../core/widgets/loading_shimmer.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../models/inventory_item.dart';
import '../models/purchase_record.dart';
import '../providers/inventory_provider.dart';

class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  String _searchQuery = '';
  String _filterStatus = 'All'; // All, Low Stock, In Stock

  @override
  Widget build(BuildContext context) {
    final isTablet = Breakpoints.isLargeScreen(context);
    final inventoryAsync = ref.watch(inventoryNotifierProvider);
    final purchaseAsync = ref.watch(purchaseRecordsNotifierProvider);

    return Scaffold(
      appBar: isTablet ? null : const AppBarWidget(title: 'Inventory & Stock'),
      drawer: isTablet ? null : const AppDrawer(),
      bottomNavigationBar: isTablet ? null : const BottomNav(),
      body: Row(
        children: [
          if (isTablet) const SidebarNavigation(),
          Expanded(
            child: SafeArea(
              child: inventoryAsync.when(
                data: (items) {
                  final filteredItems = items.where((item) {
                    final matchesSearch = item.name
                        .toLowerCase()
                        .contains(_searchQuery.toLowerCase());
                    final isLowStock = item.currentStock <= item.minimumStock;
                    if (_filterStatus == 'Low Stock') {
                      return matchesSearch && isLowStock;
                    } else if (_filterStatus == 'In Stock') {
                      return matchesSearch && !isLowStock;
                    }
                    return matchesSearch;
                  }).toList();

                  final lowStockCount = items
                      .where((item) => item.currentStock <= item.minimumStock)
                      .length;

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      if (isTablet) {
                        return Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Main content: inventory items
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildHeader(lowStockCount),
                                    const SizedBox(height: 20),
                                    _buildFilters(),
                                    const SizedBox(height: 16),
                                    Expanded(
                                      child: _buildInventoryGrid(
                                          filteredItems, items),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 24),
                              // Side panel: Purchase Records
                              Expanded(
                                flex: 2,
                                child:
                                    _buildPurchaseRecordsPanel(purchaseAsync),
                              ),
                            ],
                          ),
                        );
                      } else {
                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLowStockSummaryCard(lowStockCount),
                              const SizedBox(height: 16),
                              _buildFilters(),
                              const SizedBox(height: 12),
                              Expanded(
                                child:
                                    _buildInventoryList(filteredItems, items),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: kSurface,
                                  foregroundColor: kAccent,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(kRadiusCard),
                                    side: const BorderSide(
                                        color: kAccent, width: 1),
                                  ),
                                ),
                                onPressed: () {
                                  _showPurchaseRecordsBottomSheet(
                                      context, purchaseAsync);
                                },
                                icon: const Icon(Icons.receipt_long),
                                label: const Center(
                                    child: Text('View Purchase Log')),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                  );
                },
                loading: () => Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Center(child: LoadingShimmer.grid(count: 6)),
                ),
                error: (err, __) =>
                    Center(child: Text('Error: $err', style: kBody)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(int lowStockCount) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Inventory Management',
                style: kHeadline.copyWith(fontSize: 28)),
            const SizedBox(height: 4),
            Text(
              lowStockCount > 0
                  ? '$lowStockCount items require attention'
                  : 'All items sufficiently stocked',
              style: kCaption.copyWith(
                  color: lowStockCount > 0 ? kWarning : kSuccess),
            ),
          ],
        ),
        _buildQuickAddButton(),
      ],
    );
  }

  Widget _buildFilters() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            onChanged: (val) => setState(() => _searchQuery = val),
            style: kBody,
            decoration: InputDecoration(
              hintText: 'Search items...',
              prefixIcon: const Icon(Icons.search, color: kTextSecondary),
              filled: true,
              fillColor: kSurface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(kRadiusCard),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: kSurface,
            borderRadius: BorderRadius.circular(kRadiusCard),
          ),
          child: DropdownButton<String>(
            value: _filterStatus,
            dropdownColor: kSurface,
            underline: const SizedBox(),
            style: kBody,
            iconEnabledColor: kAccent,
            items: ['All', 'Low Stock', 'In Stock'].map((String val) {
              return DropdownMenuItem<String>(
                value: val,
                child: Text(val),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _filterStatus = val);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLowStockSummaryCard(int lowStockCount) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: lowStockCount > 0
            ? kWarning.withOpacity(0.12)
            : kSuccess.withOpacity(0.12),
        borderRadius: BorderRadius.circular(kRadiusCard),
        border: Border.all(
            color: lowStockCount > 0 ? kWarning : kSuccess, width: 1),
      ),
      child: Row(
        children: [
          Icon(
            lowStockCount > 0
                ? Icons.warning_amber_rounded
                : Icons.check_circle_outline,
            color: lowStockCount > 0 ? kWarning : kSuccess,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lowStockCount > 0 ? 'Action Required' : 'Status Healthy',
                  style: kHeadline.copyWith(
                      fontSize: 16,
                      color: lowStockCount > 0 ? kWarning : kSuccess),
                ),
                Text(
                  lowStockCount > 0
                      ? '$lowStockCount raw materials are below minimum stock limits.'
                      : 'All raw materials are above thresholds.',
                  style: kCaption,
                ),
              ],
            ),
          ),
          if (!Breakpoints.isLargeScreen(context))
            _buildQuickAddButton(isMini: true),
        ],
      ),
    );
  }

  Widget _buildQuickAddButton({bool isMini = false}) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: kAccent,
        foregroundColor: Colors.black,
        padding:
            EdgeInsets.symmetric(horizontal: isMini ? 12 : 20, vertical: 12),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kRadiusButton)),
      ),
      onPressed: () => _showAddItemDialog(),
      icon: const Icon(Icons.add, size: 18),
      label: Text(isMini ? 'Add' : 'Add Stock Item',
          style: kButtonLabel.copyWith(color: Colors.black)),
    );
  }

  Widget _buildInventoryGrid(
      List<InventoryItem> filtered, List<InventoryItem> all) {
    if (filtered.isEmpty) {
      return const EmptyStateWidget(
        title: 'No Items Found',
        subtitle: 'Try adjusting your search query or status filter.',
        fallbackIcon: Icons.inventory_2_outlined,
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = (constraints.maxWidth / 190).floor().clamp(1, 4);
        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            mainAxisExtent: 150,
          ),
          itemCount: filtered.length,
          itemBuilder: (context, idx) => _buildInventoryCard(filtered[idx]),
        );
      },
    );
  }

  Widget _buildInventoryList(
      List<InventoryItem> filtered, List<InventoryItem> all) {
    if (filtered.isEmpty) {
      return const EmptyStateWidget(
        title: 'No Items Found',
        subtitle: 'Try adjusting your search or status filter.',
        fallbackIcon: Icons.inventory_2_outlined,
      );
    }
    return ListView.separated(
      itemCount: filtered.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, idx) => _buildInventoryTile(filtered[idx]),
    );
  }

  Widget _buildInventoryCard(InventoryItem item) {
    final isLow = item.currentStock <= item.minimumStock;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(kRadiusCard),
        border: Border.all(
            color: isLow ? kWarning.withOpacity(0.5) : Colors.transparent,
            width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  item.name,
                  style: kHeadline.copyWith(fontSize: 18),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              BadgeWidget(
                label: isLow ? 'Low Stock' : 'In Stock',
                color: isLow ? kWarning : kSuccess,
              ),
            ],
          ),
          const Spacer(),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Current Stock', style: kCaption),
                  Text('${item.currentStock} ${item.unit}',
                      style: kHeadline.copyWith(
                          fontSize: 20,
                          color: isLow ? kWarning : kTextPrimary)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Min Threshold', style: kCaption),
                  Text('${item.minimumStock} ${item.unit}', style: kBody),
                ],
              ),
              IconButton(
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(8),
                style: IconButton.styleFrom(
                    backgroundColor: kBg, foregroundColor: kAccent),
                icon: const Icon(Icons.edit, size: 16),
                onPressed: () => _showUpdateStockDialog(item),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryTile(InventoryItem item) {
    final isLow = item.currentStock <= item.minimumStock;
    return Container(
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(kRadiusCard),
      ),
      child: ListTile(
        title:
            Text(item.name, style: kBody.copyWith(fontWeight: FontWeight.bold)),
        subtitle: Text('Threshold: ${item.minimumStock} ${item.unit}',
            style: kCaption),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${item.currentStock} ${item.unit}',
                  style: kBody.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isLow ? kWarning : kSuccess,
                  ),
                ),
                Text(isLow ? 'Low Stock' : 'Healthy',
                    style: kCaption.copyWith(
                        fontSize: 10, color: isLow ? kWarning : kSuccess)),
              ],
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.edit, size: 18, color: kAccent),
              onPressed: () => _showUpdateStockDialog(item),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPurchaseRecordsPanel(
      AsyncValue<List<PurchaseRecord>> purchaseAsync) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(kRadiusCard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text('Purchase History', style: kHeadline.copyWith(fontSize: 18)),
              IconButton(
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(8),
                style: IconButton.styleFrom(
                    backgroundColor: kBg, foregroundColor: kAccent),
                icon: const Icon(Icons.add, size: 18),
                onPressed: () => _showLogPurchaseDialog(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: purchaseAsync.when(
              data: (records) {
                if (records.isEmpty) {
                  return const EmptyStateWidget(
                    title: 'No Purchases Logged',
                    subtitle: 'Create a log to track stock refills.',
                    fallbackIcon: Icons.receipt_long,
                  );
                }
                return ListView.separated(
                  itemCount: records.length,
                  separatorBuilder: (_, __) =>
                      const Divider(color: kDivider, height: 16),
                  itemBuilder: (context, idx) {
                    final rec = records[idx];
                    final date =
                        DateTime.tryParse(rec.purchasedAt) ?? DateTime.now();
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: kAccent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.shopping_basket_outlined,
                              color: kAccent, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(rec.inventory?.name ?? 'Raw MaterialRefill',
                                  style: kBody.copyWith(
                                      fontWeight: FontWeight.bold)),
                              Text(
                                '${rec.quantity} units • ${rec.supplier ?? "Unknown Supplier"}',
                                style: kCaption,
                              ),
                              Text(DateFormatter.timeElapsedSince(date),
                                  style: kCaption.copyWith(fontSize: 10)),
                            ],
                          ),
                        ),
                        Text(
                          CurrencyFormatter.format(rec.cost),
                          style: kBody.copyWith(
                              fontWeight: FontWeight.bold, color: kSuccess),
                        ),
                      ],
                    );
                  },
                );
              },
              loading: () => Center(child: LoadingShimmer.list(count: 5)),
              error: (err, __) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }

  void _showPurchaseRecordsBottomSheet(
      BuildContext context, AsyncValue<List<PurchaseRecord>> purchaseAsync) {
    showModalBottomSheet(
      context: context,
      backgroundColor: kSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(kRadiusSheet)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Purchase Records Log',
                          style: kHeadline.copyWith(fontSize: 20)),
                      IconButton(
                        style: IconButton.styleFrom(
                            backgroundColor: kBg, foregroundColor: kAccent),
                        icon: const Icon(Icons.add, size: 20),
                        onPressed: () {
                          Navigator.pop(context);
                          _showLogPurchaseDialog();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: purchaseAsync.when(
                      data: (records) {
                        if (records.isEmpty) {
                          return const EmptyStateWidget(
                            title: 'No Purchases Logged',
                            subtitle:
                                'Refills logged here update inventory stock.',
                            fallbackIcon: Icons.receipt_long,
                          );
                        }
                        return ListView.separated(
                          itemCount: records.length,
                          separatorBuilder: (_, __) =>
                              const Divider(color: kDivider, height: 16),
                          itemBuilder: (context, idx) {
                            final rec = records[idx];
                            final date = DateTime.tryParse(rec.purchasedAt) ??
                                DateTime.now();
                            return Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          rec.inventory?.name ??
                                              'Raw Material Refill',
                                          style: kBody.copyWith(
                                              fontWeight: FontWeight.bold)),
                                      Text(
                                          '${rec.quantity} units • ${rec.supplier ?? "General"}',
                                          style: kCaption),
                                      Text(DateFormatter.dateWithTime(date),
                                          style:
                                              kCaption.copyWith(fontSize: 10)),
                                    ],
                                  ),
                                ),
                                Text(CurrencyFormatter.format(rec.cost),
                                    style: kBody.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: kSuccess)),
                              ],
                            );
                          },
                        );
                      },
                      loading: () =>
                          Center(child: LoadingShimmer.list(count: 4)),
                      error: (err, __) => Center(child: Text('Error: $err')),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showAddItemDialog() {
    final nameController = TextEditingController();
    final unitController = TextEditingController(text: 'kg');
    final currentController = TextEditingController(text: '0.0');
    final minController = TextEditingController(text: '10.0');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: kSurface,
          title: Text('Add Inventory Item',
              style: kHeadline.copyWith(fontSize: 20)),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    style: kBody,
                    decoration: InputDecoration(
                        labelText: 'Item Name (e.g., Tomatoes)',
                        labelStyle: kCaption),
                    validator: (val) =>
                        val == null || val.trim().isEmpty ? 'Enter name' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: unitController,
                    style: kBody,
                    decoration: InputDecoration(
                        labelText: 'Unit (e.g., kg, L, pcs)',
                        labelStyle: kCaption),
                    validator: (val) =>
                        val == null || val.trim().isEmpty ? 'Enter unit' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: currentController,
                    style: kBody,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                        labelText: 'Current Stock Level', labelStyle: kCaption),
                    validator: (val) => double.tryParse(val ?? '') == null
                        ? 'Enter number'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: minController,
                    style: kBody,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                        labelText: 'Minimum/Safety stock limit',
                        labelStyle: kCaption),
                    validator: (val) => double.tryParse(val ?? '') == null
                        ? 'Enter number'
                        : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child:
                  const Text('Cancel', style: TextStyle(color: kTextSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: kAccent, foregroundColor: Colors.black),
              onPressed: () async {
                if (formKey.currentState?.validate() ?? false) {
                  final name = nameController.text.trim();
                  final unit = unitController.text.trim();
                  final current = double.parse(currentController.text);
                  final min = double.parse(minController.text);

                  await ref
                      .read(inventoryNotifierProvider.notifier)
                      .addItem(name, unit, current, min);
                  if (mounted) Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showUpdateStockDialog(InventoryItem item) {
    final currentController =
        TextEditingController(text: item.currentStock.toString());
    final minController =
        TextEditingController(text: item.minimumStock.toString());
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: kSurface,
          title: Text('Update ${item.name}',
              style: kHeadline.copyWith(fontSize: 20)),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: currentController,
                  style: kBody,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                      labelText: 'Current Stock', labelStyle: kCaption),
                  validator: (val) => double.tryParse(val ?? '') == null
                      ? 'Enter number'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: minController,
                  style: kBody,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                      labelText: 'Minimum Safety Stock', labelStyle: kCaption),
                  validator: (val) => double.tryParse(val ?? '') == null
                      ? 'Enter number'
                      : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child:
                  const Text('Cancel', style: TextStyle(color: kTextSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: kAccent, foregroundColor: Colors.black),
              onPressed: () async {
                if (formKey.currentState?.validate() ?? false) {
                  final current = double.parse(currentController.text);
                  final min = double.parse(minController.text);

                  await ref
                      .read(inventoryNotifierProvider.notifier)
                      .updateStock(item.id, current, min);
                  if (mounted) Navigator.pop(context);
                }
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  void _showLogPurchaseDialog() {
    final inventoryItems = ref.read(inventoryNotifierProvider).value ?? [];
    if (inventoryItems.isEmpty) return;

    String selectedInventoryId = inventoryItems.first.id;
    final qtyController = TextEditingController();
    final costController = TextEditingController();
    final supplierController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: kSurface,
              title: Text('Log Purchase Refill',
                  style: kHeadline.copyWith(fontSize: 20)),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<String>(
                        dropdownColor: kSurface,
                        value: selectedInventoryId,
                        style: kBody,
                        decoration: InputDecoration(
                            labelText: 'Inventory Item', labelStyle: kCaption),
                        items: inventoryItems.map((item) {
                          return DropdownMenuItem<String>(
                            value: item.id,
                            child: Text(item.name),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => selectedInventoryId = val);
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: qtyController,
                        style: kBody,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: InputDecoration(
                            labelText: 'Refill Quantity', labelStyle: kCaption),
                        validator: (val) => double.tryParse(val ?? '') == null
                            ? 'Enter quantity'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: costController,
                        style: kBody,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: InputDecoration(
                            labelText: 'Cost (INR)', labelStyle: kCaption),
                        validator: (val) => double.tryParse(val ?? '') == null
                            ? 'Enter cost'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: supplierController,
                        style: kBody,
                        decoration: InputDecoration(
                            labelText: 'Supplier (e.g. Metro Wholesale)',
                            labelStyle: kCaption),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel',
                      style: TextStyle(color: kTextSecondary)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: kAccent, foregroundColor: Colors.black),
                  onPressed: () async {
                    if (formKey.currentState?.validate() ?? false) {
                      final qty = double.parse(qtyController.text);
                      final cost = double.parse(costController.text);
                      final supplier = supplierController.text.trim();

                      await ref
                          .read(purchaseRecordsNotifierProvider.notifier)
                          .addRecord(
                            selectedInventoryId,
                            qty,
                            cost,
                            supplier.isEmpty ? null : supplier,
                          );
                      if (mounted) Navigator.pop(context);
                    }
                  },
                  child: const Text('Log'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
