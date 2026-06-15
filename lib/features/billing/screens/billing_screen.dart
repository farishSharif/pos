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
import '../../../core/widgets/custom_snackbar.dart';
import '../../orders/models/order.dart';
import '../../orders/providers/orders_provider.dart';
import '../providers/billing_provider.dart';

class BillingScreen extends ConsumerStatefulWidget {
  const BillingScreen({super.key});

  @override
  ConsumerState<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends ConsumerState<BillingScreen> {
  Order? _selectedOrder;
  String _selectedPaymentMethod = 'Cash';
  final _amountPaidController = TextEditingController();
  double _changeDue = 0.0;

  @override
  void dispose() {
    _amountPaidController.dispose();
    super.dispose();
  }

  void _calculateChange(double total) {
    final paid = double.tryParse(_amountPaidController.text) ?? 0.0;
    if (paid >= total) {
      setState(() => _changeDue = paid - total);
    } else {
      setState(() => _changeDue = 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = Breakpoints.isLargeScreen(context);
    final ordersAsync = ref.watch(ordersListProvider);

    return Scaffold(
      appBar: isTablet ? null : const AppBarWidget(title: 'Register & Billing'),
      drawer: isTablet ? null : const AppDrawer(),
      bottomNavigationBar: isTablet ? null : const BottomNav(),
      body: Row(
        children: [
          if (isTablet) const SidebarNavigation(),
          Expanded(
            child: SafeArea(
              child: ordersAsync.when(
                data: (allOrders) {
                  final unpaidOrders = allOrders
                      .where((o) =>
                          o.paymentMethod == null &&
                          o.status != 'billed' &&
                          o.status != 'cancelled')
                      .toList();

                  // Auto select first order if none selected
                  if (_selectedOrder == null && unpaidOrders.isNotEmpty) {
                    _selectedOrder = unpaidOrders.first;
                    _amountPaidController.text =
                        _selectedOrder!.total.toStringAsFixed(2);
                    _changeDue = 0.0;
                  }

                  // If selected order is paid in latest state, reset selected order
                  if (_selectedOrder != null) {
                    final exists =
                        unpaidOrders.any((o) => o.id == _selectedOrder!.id);
                    if (!exists) {
                      _selectedOrder =
                          unpaidOrders.isNotEmpty ? unpaidOrders.first : null;
                      if (_selectedOrder != null) {
                        _amountPaidController.text =
                            _selectedOrder!.total.toStringAsFixed(2);
                        _changeDue = 0.0;
                      }
                    }
                  }

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      if (isTablet) {
                        return Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Unpaid orders list
                              Expanded(
                                flex: 4,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Active Invoices',
                                        style:
                                            kHeadline.copyWith(fontSize: 28)),
                                    const SizedBox(height: 4),
                                    Text(
                                        'Select an active table or order to settle the bill.',
                                        style: kCaption),
                                    const SizedBox(height: 20),
                                    Expanded(
                                      child:
                                          _buildUnpaidOrdersList(unpaidOrders),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 24),
                              // Billing Details Panel
                              Expanded(
                                flex: 5,
                                child: _buildBillingDetailsPanel(context),
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
                              Text('Active Invoices',
                                  style: kHeadline.copyWith(fontSize: 20)),
                              const SizedBox(height: 12),
                              Expanded(
                                child: _buildUnpaidOrdersList(unpaidOrders),
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
                  child: Center(child: LoadingShimmer.list(count: 6)),
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

  Widget _buildUnpaidOrdersList(List<Order> unpaid) {
    if (unpaid.isEmpty) {
      return const EmptyStateWidget(
        title: 'All Bills Cleared',
        subtitle: 'No pending orders require checkout.',
        fallbackIcon: Icons.check_circle_outline,
      );
    }

    final isTablet = Breakpoints.isLargeScreen(context);

    return ListView.separated(
      itemCount: unpaid.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, idx) {
        final order = unpaid[idx];
        final isSel = _selectedOrder?.id == order.id;
        final count = order.orderItems.length;

        return InkWell(
          onTap: () {
            setState(() {
              _selectedOrder = order;
              _amountPaidController.text = order.total.toStringAsFixed(2);
              _changeDue = 0.0;
            });
            if (!isTablet) {
              _showMobileBillingSheet(context);
            }
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSel && isTablet
                  ? kAccent.withValues(alpha: 0.12)
                  : kSurface,
              borderRadius: BorderRadius.circular(kRadiusCard),
              border: Border.all(
                  color: isSel && isTablet ? kAccent : kDivider, width: 1.5),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: kBg,
                  child: Icon(
                    order.orderType == 'dine_in'
                        ? Icons.table_restaurant
                        : Icons.takeout_dining,
                    color: kAccent,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.customerName != null &&
                                order.customerName!.isNotEmpty
                            ? order.customerName!
                            : 'Table ${order.tableId ?? "Takeaway"}',
                        style: kBody.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                          '$count items • Status: ${order.status.toUpperCase()}',
                          style: kCaption),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(CurrencyFormatter.format(order.total),
                        style: kHeadline.copyWith(fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(
                      DateFormatter.timeElapsedSince(
                          DateTime.tryParse(order.createdAt) ?? DateTime.now()),
                      style: kCaption.copyWith(fontSize: 10),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBillingDetailsPanel(BuildContext context) {
    if (_selectedOrder == null) {
      return Container(
        decoration: BoxDecoration(
          color: kSurface,
          borderRadius: BorderRadius.circular(kRadiusCard),
        ),
        child: Center(
          child: Text('Select an order to view checkout details.',
              style: kCaption),
        ),
      );
    }

    final order = _selectedOrder!;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(kRadiusCard),
        border: Border.all(color: kDivider, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Bill Details', style: kHeadline.copyWith(fontSize: 20)),
                  Text(
                    order.customerName != null && order.customerName!.isNotEmpty
                        ? 'Customer: ${order.customerName}'
                        : 'Dine-In Table ${order.tableId ?? "N/A"}',
                    style: kCaption,
                  ),
                ],
              ),
              _buildTypeBadge(order.orderType),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: order.orderItems.length,
              separatorBuilder: (_, __) =>
                  const Divider(color: kDivider, height: 12),
              itemBuilder: (context, idx) {
                final item = order.orderItems[idx];
                return Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.name,
                              style:
                                  kBody.copyWith(fontWeight: FontWeight.bold)),
                          Text('Quantity: ${item.quantity}', style: kCaption),
                        ],
                      ),
                    ),
                    Text(
                      CurrencyFormatter.format(item.price * item.quantity),
                      style: kBody,
                    ),
                  ],
                );
              },
            ),
          ),
          const Divider(color: kDivider, height: 24),
          _buildSummarySection(order),
          const Divider(color: kDivider, height: 24),
          _buildPaymentSection(order),
        ],
      ),
    );
  }

  Widget _buildSummarySection(Order order) {
    return Column(
      children: [
        _buildSummaryRow('Subtotal', CurrencyFormatter.format(order.subtotal)),
        const SizedBox(height: 6),
        _buildSummaryRow('CGST', CurrencyFormatter.format(order.cgst)),
        const SizedBox(height: 6),
        _buildSummaryRow('SGST', CurrencyFormatter.format(order.sgst)),
        if (order.serviceCharge > 0) ...[
          const SizedBox(height: 6),
          _buildSummaryRow(
              'Service Charge', CurrencyFormatter.format(order.serviceCharge)),
        ],
        if (order.discount > 0) ...[
          const SizedBox(height: 6),
          _buildSummaryRow(
              'Coupon Discount', '-${CurrencyFormatter.format(order.discount)}',
              valColor: kWarning),
        ],
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Grand Total',
                style: kHeadline.copyWith(fontSize: 18, color: kAccent)),
            Text(CurrencyFormatter.format(order.total),
                style: kHeadline.copyWith(
                    fontSize: 20,
                    color: kAccent,
                    fontFamily: 'JetBrains Mono')),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String val,
      {Color valColor = kTextPrimary}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: kCaption),
        Text(val,
            style:
                kBody.copyWith(color: valColor, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildPaymentSection(Order order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Payment Method',
            style: kBody.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Row(
          children: ['Cash', 'Card', 'UPI'].map((method) {
            final isSel = _selectedPaymentMethod == method;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: ChoiceChip(
                  label: Center(child: Text(method)),
                  selected: isSel,
                  selectedColor: kAccent,
                  backgroundColor: kBg,
                  labelStyle: kCaption.copyWith(
                    color: isSel ? Colors.black : kTextSecondary,
                    fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                  ),
                  onSelected: (val) {
                    if (val) {
                      setState(() {
                        _selectedPaymentMethod = method;
                        if (method != 'Cash') {
                          _amountPaidController.text =
                              order.total.toStringAsFixed(2);
                          _changeDue = 0.0;
                        }
                      });
                    }
                  },
                ),
              ),
            );
          }).toList(),
        ),
        if (_selectedPaymentMethod == 'Cash') ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextField(
                  controller: _amountPaidController,
                  style: kBody,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Amount Received (INR)',
                    labelStyle: kCaption,
                    prefixText: '₹ ',
                  ),
                  onChanged: (_) => _calculateChange(order.total),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Change Due', style: kCaption),
                    Text(
                      CurrencyFormatter.format(_changeDue),
                      style: kHeadline.copyWith(
                          fontSize: 18,
                          color: kSuccess,
                          fontFamily: 'JetBrains Mono'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: kTextSecondary,
                  side: const BorderSide(color: kDivider),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () => _printShareReceipt(order),
                icon: const Icon(Icons.share, size: 16),
                label: const Text('Share Receipt'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kSuccess,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(kRadiusButton)),
                ),
                onPressed: () async {
                  final paidAmt = double.tryParse(_amountPaidController.text) ??
                      order.total;
                  if (paidAmt < order.total) {
                    CustomSnackBar.showError(
                        context, 'Paid amount is less than Grand Total!');
                    return;
                  }
                  await ref
                      .read(billingNotifierProvider.notifier)
                      .settlePayment(
                        orderId: order.id,
                        paymentMethod: _selectedPaymentMethod,
                        paymentAmount: paidAmt,
                        changeAmount: _changeDue,
                      );
                  if (mounted) {
                    CustomSnackBar.showSuccess(
                        context, 'Order payment settled successfully!');
                  }
                },
                child: Text('Complete Settlement',
                    style: kButtonLabel.copyWith(color: Colors.black)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showMobileBillingSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: kSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(kRadiusSheet)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final order = _selectedOrder!;
            return Padding(
              padding: EdgeInsets.only(
                top: 20.0,
                left: 20.0,
                right: 20.0,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20.0,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Settle Bill',
                            style: kHeadline.copyWith(fontSize: 20)),
                        Text('Total: ${CurrencyFormatter.format(order.total)}',
                            style: kHeadline.copyWith(
                                fontSize: 18, color: kAccent)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Item summaries
                    ...order.orderItems.map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 6.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${item.quantity}x ${item.name}',
                                  style: kCaption),
                              Text(
                                  CurrencyFormatter.format(
                                      item.price * item.quantity),
                                  style: kBody),
                            ],
                          ),
                        )),
                    const Divider(color: kDivider, height: 24),
                    _buildSummarySection(order),
                    const Divider(color: kDivider, height: 24),
                    Text('Payment Method',
                        style: kBody.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Row(
                      children: ['Cash', 'Card', 'UPI'].map((method) {
                        final isSel = _selectedPaymentMethod == method;
                        return Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 4.0),
                            child: ChoiceChip(
                              label: Center(child: Text(method)),
                              selected: isSel,
                              selectedColor: kAccent,
                              backgroundColor: kBg,
                              labelStyle: kCaption.copyWith(
                                color: isSel ? Colors.black : kTextSecondary,
                                fontWeight:
                                    isSel ? FontWeight.bold : FontWeight.normal,
                              ),
                              onSelected: (val) {
                                if (val) {
                                  setModalState(() {
                                    _selectedPaymentMethod = method;
                                    if (method != 'Cash') {
                                      _amountPaidController.text =
                                          order.total.toStringAsFixed(2);
                                      _changeDue = 0.0;
                                    }
                                  });
                                }
                              },
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    if (_selectedPaymentMethod == 'Cash') ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: TextField(
                              controller: _amountPaidController,
                              style: kBody,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              decoration: InputDecoration(
                                labelText: 'Amount Received (INR)',
                                labelStyle: kCaption,
                                prefixText: '₹ ',
                              ),
                              onChanged: (_) {
                                final paid = double.tryParse(
                                        _amountPaidController.text) ??
                                    0.0;
                                setModalState(() {
                                  if (paid >= order.total) {
                                    _changeDue = paid - order.total;
                                  } else {
                                    _changeDue = 0.0;
                                  }
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('Change Due', style: kCaption),
                                Text(
                                  CurrencyFormatter.format(_changeDue),
                                  style: kHeadline.copyWith(
                                      fontSize: 18,
                                      color: kSuccess,
                                      fontFamily: 'JetBrains Mono'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14)),
                            onPressed: () {
                              Navigator.pop(context);
                              _printShareReceipt(order);
                            },
                            child: const Text('Share PDF'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: kSuccess,
                                foregroundColor: Colors.black,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14)),
                            onPressed: () async {
                              final paidAmt =
                                  double.tryParse(_amountPaidController.text) ??
                                      order.total;
                              if (paidAmt < order.total) {
                                CustomSnackBar.showError(
                                    context, 'Amount paid is less than Total!');
                                return;
                              }
                              await ref
                                  .read(billingNotifierProvider.notifier)
                                  .settlePayment(
                                    orderId: order.id,
                                    paymentMethod: _selectedPaymentMethod,
                                    paymentAmount: paidAmt,
                                    changeAmount: _changeDue,
                                  );
                              if (mounted) {
                                Navigator.pop(context);
                                CustomSnackBar.showSuccess(
                                    context, 'Order Payment Settled!');
                              }
                            },
                            child: const Text('Complete payment'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _printShareReceipt(Order order) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: kSurface,
          title: const Row(
            children: [
              Icon(Icons.picture_as_pdf, color: kAccent),
              SizedBox(width: 8),
              Text('Receipt Action', style: TextStyle(color: Colors.white)),
            ],
          ),
          content: Text(
            'Would you like to print or share the PDF receipt for order ID ${order.id.substring(0, 8)}...?',
            style: kBody,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child:
                  const Text('Cancel', style: TextStyle(color: kTextSecondary)),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                  backgroundColor: kAccent, foregroundColor: Colors.black),
              onPressed: () {
                Navigator.pop(context);
                CustomSnackBar.showSuccess(
                    context, 'PDF generated and shared successfully!');
              },
              icon: const Icon(Icons.share, size: 16),
              label: const Text('Share PDF'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTypeBadge(String type) {
    return BadgeWidget(
      label: type == 'dine_in' ? 'DINE-IN' : 'TAKEAWAY',
      color: type == 'dine_in' ? kAccent : kInfo,
    );
  }
}
