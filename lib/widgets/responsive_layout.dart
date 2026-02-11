// lib/widgets/responsive_layout.dart

import 'package:flutter/material.dart';

/// Breakpoints for responsive design
class AppBreakpoints {
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;
}

/// Wraps content with max width constraint — the #1 improvement
class ResponsiveCenter extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsets padding;

  const ResponsiveCenter({
    super.key,
    required this.child,
    this.maxWidth = 700,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}

/// Returns true if screen is wider than mobile breakpoint
bool isWideScreen(BuildContext context) {
  return MediaQuery.of(context).size.width >= AppBreakpoints.mobile;
}

/// Returns true if screen is desktop-width
bool isDesktop(BuildContext context) {
  return MediaQuery.of(context).size.width >= AppBreakpoints.tablet;
}

/// Responsive grid column count based on screen width
int responsiveGridCount(double width) {
  if (width >= AppBreakpoints.desktop) return 3;
  if (width >= AppBreakpoints.tablet) return 2;
  return 1;
}
