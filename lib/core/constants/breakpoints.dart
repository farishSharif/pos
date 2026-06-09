import 'package:flutter/widgets.dart';

class Breakpoints {
  static const double phone = 0;
  static const double tablet = 768;
  static const double desktop = 1200;

  static bool isPhone(BuildContext ctx) => MediaQuery.of(ctx).size.width < 768;
  static bool isTablet(BuildContext ctx) =>
      MediaQuery.of(ctx).size.width >= 768 &&
      MediaQuery.of(ctx).size.width < 1200;
  static bool isDesktop(BuildContext ctx) =>
      MediaQuery.of(ctx).size.width >= 1200;

  // Handy helpers that include tablet and desktop
  static bool isLargeScreen(BuildContext ctx) => MediaQuery.of(ctx).size.width >= 768;
}
