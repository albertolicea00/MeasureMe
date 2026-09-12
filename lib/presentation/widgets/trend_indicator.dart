import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/trend_calculator.dart';

/// Shows a direction arrow + color, always paired with text so meaning
/// never depends on color alone (§30). Deliberately neutral — an "up"
/// arrow is not colored green or red, because whether a change is
/// desirable depends on the metric and the user's own goal (§8).
class TrendIndicator extends StatelessWidget {
  const TrendIndicator(this.direction, {super.key, this.size = 16});

  final TrendDirection direction;
  final double size;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (direction) {
      TrendDirection.up => (Icons.arrow_upward_rounded, AppColors.trendUp),
      TrendDirection.down => (Icons.arrow_downward_rounded, AppColors.trendDown),
      TrendDirection.stable => (Icons.remove_rounded, AppColors.trendStable),
    };
    return Icon(icon, size: size, color: color, semanticLabel: switch (direction) {
      TrendDirection.up => 'Increasing',
      TrendDirection.down => 'Decreasing',
      TrendDirection.stable => 'Stable',
    });
  }
}
