import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/tax_calculator.dart';
import '../../../core/widgets/custom_snackbar.dart';
import '../../auth/providers/auth_provider.dart';
import '../../tables/providers/tables_provider.dart';
import '../../settings/providers/settings_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/orders_provider.dart';

class CartPanel extends ConsumerStatefulWidget {
  final int? initialTableId;
  final VoidCallback? onCompleted;

  const CartPanel({
    super.key,
    this.initialTableId,
    this.onCompleted,
  });

  @override
  ConsumerState<CartPanel> createState() => _CartPanelState();
}

class _CartPanelState extends ConsumerState<CartPanel> {
  final _customerNameController = TextEditingController();
  final _couponController = TextEditingController();
  final _notesController = TextEditingController();
  
  String _orderType = 'dine_in'; // 'dine_in' or 'takeaway'
  int? _selectedTableId;
  Map<String, dynamic>? _appliedCoupon;
  bool _isValidatingCoupon = false;

  @override
  void initState() {
    super.initState();
    _selectedTableId = widget.initialTableId;
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _couponController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _validateCoupon() async {
    final code = _couponController.text.trim();
    if (code.isEmpty) return;

    setState(() => _isValidatingCoupon = true);
    try {
      final coupon = await ref.read(validateCouponProvider(code).future);
      if (mounted) {
        if (coupon != null) {
          final subtotal = ref.read(cartNotifierProvider.notifier).subtotal;
          final minVal = (coupon['min_order_value'] as num? ?? 0).toDouble();
          
          if (subtotal >= minVal) {
            setState(() {
              _appliedCoupon = coupon;
            });
            CustomSnackBar.showSuccess(context, 'Coupon applied successfully!');
          } else {
            CustomSnackBar.showError(
              context,
              'Minimum order value for this coupon is ${CurrencyFormatter.format(minVal)}',
            );
          }
        } else {
          CustomSnackBar.showError(context, 'Invalid or expired coupon code.');
        }
      }
    } catch (e) {
      if (mounted) CustomSnackBar.showError(context, 'Error validating coupon: $e');
    } finally {
      if (mounted) setState(() => _isValidatingCoupon = false);
    }
  }

  Future<void> _submitOrder(String status) async {
    final cart = ref.read(cartNotifierProvider);
    if (cart.isEmpty) {
      CustomSnackBar.showError(context, 'Your cart is empty!');
      return;
    }

    if (_orderType == 'dine_in' && _selectedTableId == null) {
      CustomSnackBar.showError(context, 'Please select a dining table.');
      return;
    }

    final subtotal = ref.read(cartNotifierProvider.notifier).subtotal;
    
    // Fetch rates from settings (or defaults)
    final settingsAsync = ref.read(settingsNotifierProvider);
    final settings = settingsAsync.value;
    final cgstRate = settings?.cgstRate ?? 2.5;
    final sgstRate = settings?.sgstRate ?? 2.5;
    final serviceChargeRate = settings?.serviceChargeRate ?? 5.0;
    final serviceChargeEnabled = settings?.serviceChargeEnabled ?? true;

    // Calculate discount
    double discount = 0.0;
    if (_appliedCoupon != null) {
      final val = (_appliedCoupon!['discount_value'] as num).toDouble();
      final type = _appliedCoupon!['discount_type'] as String;
      discount = TaxCalculator.calculateDiscount(subtotal, val, type == 'percent');
    }

    final summary = TaxCalculator.calculate(
      subtotal: subtotal,
      discount: discount,
      cgstRate: cgstRate,
      sgstRate: sgstRate,
      serviceChargeRate: serviceChargeRate,
      serviceChargeEnabled: serviceChargeEnabled,
    );

    final List<Map<String, dynamic>> itemsList = cart.values.map((item) {
      return {
        'menu_item_id': item.menuItem.id,
        'name': item.menuItem.name,
        'price': item.menuItem.price,
        'quantity': item.quantity,
        'notes': item.notes ?? '',
        'status': 'pending',
      };
    }).toList();

    try {
      await ref.read(ordersNotifierProvider.notifier).checkout(
            tableId: _orderType == 'dine_in' ? _selectedTableId : null,
            customerName: _customerNameController.text.trim().isEmpty ? 'Guest' : _customerNameController.text.trim(),
            orderType: _orderType,
            status: status,
            subtotal: subtotal,
            cgst: summary['cgst']!,
            sgst: summary['sgst']!,
            serviceCharge: summary['serviceCharge']!,
            discount: discount,
            total: summary['total']!,
            couponCode: _appliedCoupon?['code'] as String?,
            notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
            items: itemsList,
          );

      // Clear Cart
      ref.read(cartNotifierProvider.notifier).clear();
      
      if (mounted) {
        CustomSnackBar.showSuccess(context, 'Order submitted successfully!');
        if (widget.onCompleted != null) widget.onCompleted!();

        if (status == 'pending') {
          final role = ref.read(authNotifierProvider).role;
          if (role == 'kitchen' || role == 'admin') {
            context.go('/kitchen');
          } else {
            context.go('/tables');
          }
        }
      }
    } catch (e) {
      if (mounted) CustomSnackBar.showError(context, 'Checkout failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartNotifierProvider);
    final tablesAsync = ref.watch(tablesStreamProvider);
    final settingsAsync = ref.watch(settingsNotifierProvider);

    final subtotal = ref.read(cartNotifierProvider.notifier).subtotal;

    // Fetch tax rates for preview
    final cgstRate = settingsAsync.value?.cgstRate ?? 2.5;
    final sgstRate = settingsAsync.value?.sgstRate ?? 2.5;
    final serviceChargeRate = settingsAsync.value?.serviceChargeRate ?? 5.0;
    final serviceChargeEnabled = settingsAsync.value?.serviceChargeEnabled ?? true;

    double discount = 0.0;
    if (_appliedCoupon != null) {
      final val = (_appliedCoupon!['discount_value'] as num).toDouble();
      final type = _appliedCoupon!['discount_type'] as String;
      discount = TaxCalculator.calculateDiscount(subtotal, val, type == 'percent');
    }

    final totals = TaxCalculator.calculate(
      subtotal: subtotal,
      discount: discount,
      cgstRate: cgstRate,
      sgstRate: sgstRate,
      serviceChargeRate: serviceChargeRate,
      serviceChargeEnabled: serviceChargeEnabled,
    );

    return Container(
      decoration: const BoxDecoration(
        color: kSurface,
        border: Border(left: BorderSide(color: kDivider, width: 1)),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Current Order', style: kTitle.copyWith(fontSize: 20)),
                IconButton(
                  icon: const Icon(Icons.delete_sweep_outlined, color: kError),
                  onPressed: () {
                    if (cart.isNotEmpty) {
                      ref.read(cartNotifierProvider.notifier).clear();
                    }
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: kDivider),

          // Cart List
          Expanded(
            child: cart.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_basket_outlined, size: 48, color: kTextSecondary.withValues(alpha: 0.5)),
                        const SizedBox(height: 12),
                        Text('Your Cart is Empty', style: kCaption),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: cart.length,
                    itemBuilder: (context, index) {
                      final item = cart.values.elementAt(index);
                      return _buildCartItemTile(item);
                    },
                  ),
          ),
          const Divider(height: 1, color: kDivider),

          // Forms & Options
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Order Type Selector
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'dine_in', label: Text('Dine In'), icon: Icon(Icons.flatware, size: 16)),
                    ButtonSegment(value: 'takeaway', label: Text('Takeaway'), icon: Icon(Icons.takeout_dining, size: 16)),
                  ],
                  selected: {_orderType},
                  onSelectionChanged: (val) {
                    setState(() {
                      _orderType = val.first;
                    });
                  },
                  style: SegmentedButton.styleFrom(
                    selectedBackgroundColor: kAccent,
                    selectedForegroundColor: Colors.black,
                  ),
                ),
                const SizedBox(height: 12),

                // Table Selector Dropdown (only for dine-in)
                if (_orderType == 'dine_in') ...[
                  tablesAsync.when(
                    data: (tablesList) {
                      // Filter available or currently selected table
                      final dropTables = tablesList.where((t) => t.status == 'available' || t.id == _selectedTableId).toList();
                      return DropdownButtonFormField<int>(
                        value: _selectedTableId,
                        dropdownColor: kSurface2,
                        decoration: const InputDecoration(
                          labelText: 'Select Table',
                          prefixIcon: Icon(Icons.table_bar_outlined, color: kTextSecondary),
                        ),
                        items: dropTables.map((t) {
                          return DropdownMenuItem(
                            value: t.id,
                            child: Text('Table ${t.tableNumber} (Cap: ${t.capacity})', style: kBody),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedTableId = val;
                          });
                        },
                      );
                    },
                    loading: () => const LinearProgressIndicator(),
                    error: (_, __) => Text('Error loading tables', style: kCaption),
                  ),
                  const SizedBox(height: 12),
                ],

                // Customer Name
                TextFormField(
                  controller: _customerNameController,
                  decoration: const InputDecoration(
                    labelText: 'Customer Name',
                    prefixIcon: Icon(Icons.person_outline, color: kTextSecondary),
                    hintText: 'e.g. John Doe',
                  ),
                  style: kBody,
                ),
                const SizedBox(height: 12),

                // Coupon Code field
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _couponController,
                        textCapitalization: TextCapitalization.characters,
                        decoration: InputDecoration(
                          labelText: 'Coupon Code',
                          prefixIcon: const Icon(Icons.card_giftcard, color: kTextSecondary),
                          hintText: 'e.g. SAVOR10',
                          suffixIcon: _appliedCoupon != null
                              ? IconButton(
                                  icon: const Icon(Icons.clear, color: kError),
                                  onPressed: () {
                                    setState(() {
                                      _appliedCoupon = null;
                                      _couponController.clear();
                                    });
                                  },
                                )
                              : null,
                        ),
                        style: kBody,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _isValidatingCoupon ? null : _validateCoupon,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                      child: _isValidatingCoupon
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('Apply'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Subtotal / Tax Summary
                Column(
                  children: [
                    _buildSummaryRow('Subtotal', CurrencyFormatter.format(subtotal)),
                    if (discount > 0)
                      _buildSummaryRow(
                        'Discount (${_appliedCoupon?['code']})',
                        '-${CurrencyFormatter.format(discount)}',
                        color: kSuccess,
                      ),
                    _buildSummaryRow('CGST ($cgstRate%)', CurrencyFormatter.format(totals['cgst']!)),
                    _buildSummaryRow('SGST ($sgstRate%)', CurrencyFormatter.format(totals['sgst']!)),
                    if (serviceChargeEnabled)
                      _buildSummaryRow('Service Charge ($serviceChargeRate%)', CurrencyFormatter.format(totals['serviceCharge']!)),
                    const Divider(color: kDivider, height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total Amount', style: kTitle.copyWith(fontSize: 16)),
                        Text(
                          CurrencyFormatter.format(totals['total']!),
                          style: kPrice.copyWith(fontSize: 20),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: cart.isEmpty ? null : () => _submitOrder('draft'),
                        child: const Text('Save Draft'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: cart.isEmpty ? null : () => _submitOrder('pending'),
                        child: const Text('Send to Kitchen'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItemTile(var item) {
    final noteController = TextEditingController(text: item.notes ?? '');
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: kSurface2,
        borderRadius: BorderRadius.circular(kRadiusCard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListTile(
            title: Text(item.menuItem.name, style: kBody.copyWith(fontWeight: FontWeight.bold)),
            subtitle: Text(CurrencyFormatter.format(item.menuItem.price), style: kCaption),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline, size: 20, color: kTextSecondary),
                  onPressed: () {
                    ref.read(cartNotifierProvider.notifier).updateQty(item.menuItem.id, item.quantity - 1);
                  },
                ),
                Text('${item.quantity}', style: kTitle.copyWith(fontSize: 14)),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, size: 20, color: kAccent),
                  onPressed: () {
                    ref.read(cartNotifierProvider.notifier).updateQty(item.menuItem.id, item.quantity + 1);
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 12.0),
            child: TextFormField(
              controller: noteController,
              onFieldSubmitted: (val) {
                ref.read(cartNotifierProvider.notifier).updateNotes(item.menuItem.id, val.trim());
              },
              decoration: const InputDecoration(
                hintText: 'Add preparation notes (e.g. no onions, extra spicy)...',
                prefixIcon: Icon(Icons.notes, size: 14, color: kTextSecondary),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              style: kCaption,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: kCaption),
          Text(value, style: kCaption.copyWith(color: color ?? kTextPrimary, fontWeight: color != null ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}
