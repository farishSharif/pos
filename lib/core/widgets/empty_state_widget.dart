import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';

class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? lottieAsset;
  final IconData? fallbackIcon;
  final String? actionLabel;
  final VoidCallback? onActionPressed;

  const EmptyStateWidget({
    super.key,
    required this.title,
    required this.subtitle,
    this.lottieAsset,
    this.fallbackIcon = Icons.inbox_outlined,
    this.actionLabel,
    this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (lottieAsset != null)
              SizedBox(
                height: 180,
                child: Lottie.asset(
                  lottieAsset!,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildFallbackIcon();
                  },
                ),
              )
            else
              _buildFallbackIcon(),
            const SizedBox(height: 20),
            Text(
              title,
              style: kTitle.copyWith(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: kCaption,
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onActionPressed != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onActionPressed,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackIcon() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: kSurface2,
        shape: BoxShape.circle,
      ),
      child: Icon(
        fallbackIcon,
        size: 64,
        color: kAccent.withOpacity(0.8),
      ),
    );
  }
}
