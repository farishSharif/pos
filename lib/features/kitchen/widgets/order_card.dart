import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../orders/models/order.dart';

class OrderCard extends StatefulWidget {
  final Order order;
  final VoidCallback? onTap;

  const OrderCard({
    super.key,
    required this.order,
    this.onTap,
  });

  @override
  State<OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<OrderCard> with SingleTickerProviderStateMixin {
  late Timer _timer;
  late Duration _elapsed;
  late AnimationController _pulsingController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    final created = DateTime.tryParse(widget.order.createdAt) ?? DateTime.now();
    _elapsed = DateTime.now().difference(created);
    
    // Timer to update elapsed minutes
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        setState(() {
          _elapsed = DateTime.now().difference(created);
        });
      }
    });

    // Pulsing animation for high-urgency items
    _pulsingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.2, end: 0.9).animate(_pulsingController);
  }

  @override
  void dispose() {
    _timer.cancel();
    _pulsingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final minutes = _elapsed.inMinutes;

    // Resolve border color & pulsing flag
    Color borderColor = kSuccess;
    bool shouldPulse = false;

    if (minutes >= 5 && minutes < 10) {
      borderColor = kWarning;
    } else if (minutes >= 10) {
      borderColor = kError;
      shouldPulse = true;
    }

    Widget buildCardContent() {
      return Card(
        color: kSurface,
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kRadiusCard),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(kRadiusCard),
            border: Border.all(
              color: shouldPulse
                  ? borderColor.withOpacity(_pulseAnimation.value)
                  : borderColor.withOpacity(0.8),
              width: 2,
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '#${widget.order.id.substring(widget.order.id.length - 4).toUpperCase()}',
                    style: kOrderId.copyWith(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.timer_outlined, size: 14, color: kTextSecondary),
                      const SizedBox(width: 4),
                      Text(
                        '${minutes}m',
                        style: kOrderId.copyWith(
                          color: shouldPulse ? kError : kTextSecondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.order.orderType == 'dine_in'
                        ? 'Table ${widget.order.tableId ?? '??'}'
                        : 'Takeaway',
                    style: kTitle.copyWith(fontSize: 16),
                  ),
                  Text(
                    widget.order.customerName ?? 'Guest',
                    style: kCaption,
                  ),
                ],
              ),
              const Divider(color: kDivider, height: 16),
              
              // Items List
              ...widget.order.orderItems.map((item) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '${item.quantity}x ${item.name}',
                              style: kBody.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Text(
                            item.status.toUpperCase(),
                            style: kCaption.copyWith(
                              color: item.status == 'ready' ? kInfo : kTextSecondary,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      if (item.notes != null && item.notes!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 12.0, top: 2),
                          child: Text(
                            '* ${item.notes}',
                            style: kCaption.copyWith(color: kAccent, fontStyle: FontStyle.italic),
                          ),
                        ),
                    ],
                  ),
                );
              }),

              if (widget.order.notes != null && widget.order.notes!.isNotEmpty) ...[
                const Divider(color: kDivider, height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.warning_amber_rounded, size: 14, color: kWarning),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Order Note: ${widget.order.notes}',
                        style: kCaption.copyWith(color: kWarning),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (shouldPulse) {
      return AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) => buildCardContent(),
      );
    }
    return buildCardContent();
  }
}
