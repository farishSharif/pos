import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/widgets/badge_widget.dart';
import '../models/restaurant_table.dart';

class TableCard extends StatelessWidget {
  final RestaurantTable table;
  final VoidCallback onTap;
  final bool isSelected;

  const TableCard({
    super.key,
    required this.table,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    // Map status to border colors
    final Color statusColor = switch (table.status.toLowerCase()) {
      'available' => kSuccess,
      'ordered' => kWarning,
      'preparing' => const Color(0xFFFF6B35),
      'ready' => kInfo,
      'occupied' || 'billed' => kError,
      _ => kTextSecondary,
    };

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: isSelected ? kSurface2 : kSurface,
        borderRadius: BorderRadius.circular(kRadiusCard),
        border: Border.all(
          color: isSelected ? kAccent : statusColor.withOpacity(0.5),
          width: isSelected ? 2.5 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(kRadiusCard),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'T${table.tableNumber}',
                      style: kDisplayLarge.copyWith(
                        fontSize: 24,
                        color: isSelected ? kAccent : kTextPrimary,
                      ),
                    ),
                    Icon(
                      Icons.table_bar,
                      color: statusColor,
                      size: 22,
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.people_outline, color: kTextSecondary, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          'Cap: ${table.capacity}',
                          style: kCaption,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    BadgeWidget.tableStatus(table.status),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
