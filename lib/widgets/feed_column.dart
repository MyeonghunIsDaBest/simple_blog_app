// lib/widgets/feed_column.dart

import 'package:flutter/material.dart';
import 'responsive_layout.dart';

class FeedColumn extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const FeedColumn({
    super.key,
    required this.child,
    this.maxWidth = AppBreakpoints.feedMaxWidth,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasSidebar = showSidebar(context);
    final dividerColor =
        theme.dividerTheme.color ?? Colors.grey.withOpacity(0.2);

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Container(
          decoration: hasSidebar
              ? BoxDecoration(
                  border: Border.symmetric(
                    vertical: BorderSide(color: dividerColor, width: 1),
                  ),
                )
              : null,
          child: child,
        ),
      ),
    );
  }
}
