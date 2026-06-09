import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../menu/models/menu_item.dart';

class MenuItemCard extends StatefulWidget {
  final MenuItem item;
  final VoidCallback onAdd;

  const MenuItemCard({
    super.key,
    required this.item,
    required this.onAdd,
  });

  @override
  State<MenuItemCard> createState() => _MenuItemCardState();
}

class _MenuItemCardState extends State<MenuItemCard> with SingleTickerProviderStateMixin {
  double _scale = 1.0;

  void _handleTap() {
    if (!widget.item.isAvailable) return;
    
    HapticFeedback.mediumImpact();
    setState(() => _scale = 0.95);
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => _scale = 1.0);
    });
    widget.onAdd();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _scale,
      duration: const Duration(milliseconds: 100),
      child: Card(
        color: widget.item.isAvailable ? kSurface : kSurface.withOpacity(0.5),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kRadiusCard),
          border: Border.all(
            color: widget.item.isAvailable ? kDivider : Colors.transparent,
            width: 1,
          ),
        ),
        child: InkWell(
          onTap: _handleTap,
          borderRadius: BorderRadius.circular(kRadiusCard),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image/Thumbnail or Fallback Placeholder with Hero
              Expanded(
                flex: 4,
                child: Hero(
                  tag: 'menuItem_${widget.item.id}',
                  child: Container(
                    decoration: BoxDecoration(
                      color: kSurface2,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(kRadiusCard),
                        topRight: Radius.circular(kRadiusCard),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: widget.item.imageUrl != null
                        ? Image.network(
                            widget.item.imageUrl!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.fastfood_outlined,
                              color: kTextSecondary,
                              size: 36,
                            ),
                          )
                        : const Icon(
                            Icons.fastfood_outlined,
                            color: kTextSecondary,
                            size: 36,
                          ),
                  ),
                ),
              ),
              // Body
              Expanded(
                flex: 5,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.item.name,
                            style: kTitle.copyWith(fontSize: 14, fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          if (widget.item.description != null && widget.item.description!.isNotEmpty)
                            Text(
                              widget.item.description!,
                              style: kCaption,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            CurrencyFormatter.format(widget.item.price),
                            style: kPrice.copyWith(fontSize: 14),
                          ),
                          if (widget.item.isAvailable)
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: kSuccess.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.add, color: kSuccess, size: 16),
                            )
                          else
                            Text(
                              'OUT',
                              style: kCaption.copyWith(color: kError, fontWeight: FontWeight.bold),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
