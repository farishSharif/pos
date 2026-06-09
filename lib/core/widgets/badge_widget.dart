import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';

class BadgeWidget extends StatelessWidget {
  final String label;
  final Color color;
  final Color? textColor;
  final IconData? icon;

  const BadgeWidget({
    super.key,
    required this.label,
    required this.color,
    this.textColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(kRadiusChip),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label.toUpperCase(),
            style: kCaption.copyWith(
              color: textColor ?? color,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  factory BadgeWidget.role(String role) {
    final Map<String, dynamic> data = switch (role.toLowerCase()) {
      'admin' => {'color': Colors.purple, 'icon': Icons.admin_panel_settings},
      'cashier' => {'color': kInfo, 'icon': Icons.point_of_sale},
      'waiter' => {'color': kAccent, 'icon': Icons.flatware},
      'kitchen' => {'color': kSuccess, 'icon': Icons.soup_kitchen},
      _ => {'color': kTextSecondary, 'icon': Icons.person},
    };

    return BadgeWidget(
      label: role,
      color: data['color'] as Color,
      icon: data['icon'] as IconData,
    );
  }

  factory BadgeWidget.tableStatus(String status) {
    final Map<String, dynamic> data = switch (status.toLowerCase()) {
      'available' => {'color': kSuccess, 'icon': Icons.check_circle_outline},
      'ordered' => {'color': kWarning, 'icon': Icons.hourglass_empty},
      'preparing' => {'color': const Color(0xFFFF6B35), 'icon': Icons.local_fire_department},
      'ready' => {'color': kInfo, 'icon': Icons.restaurant},
      'occupied' || 'billed' => {'color': kError, 'icon': Icons.people},
      _ => {'color': kTextSecondary, 'icon': Icons.help_outline},
    };

    return BadgeWidget(
      label: status,
      color: data['color'] as Color,
      icon: data['icon'] as IconData,
    );
  }

  factory BadgeWidget.orderStatus(String status) {
    final Map<String, dynamic> data = switch (status.toLowerCase()) {
      'draft' => {'color': kTextSecondary, 'icon': Icons.edit_note},
      'pending' => {'color': kWarning, 'icon': Icons.schedule},
      'preparing' => {'color': const Color(0xFFFF6B35), 'icon': Icons.kitchen},
      'ready' => {'color': kInfo, 'icon': Icons.check_circle_outline},
      'served' => {'color': kSuccess, 'icon': Icons.room_service},
      'billed' => {'color': kSuccess, 'icon': Icons.receipt_long},
      'cancelled' => {'color': kError, 'icon': Icons.cancel},
      _ => {'color': kTextSecondary, 'icon': Icons.help_outline},
    };

    return BadgeWidget(
      label: status,
      color: data['color'] as Color,
      icon: data['icon'] as IconData,
    );
  }
}
