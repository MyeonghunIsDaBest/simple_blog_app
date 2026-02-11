// lib/widgets/hover_card.dart

import 'package:flutter/material.dart';

/// Card with hover elevation + scale effect for web
class HoverCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets margin;
  final BorderRadius borderRadius;

  const HoverCard({
    super.key,
    required this.child,
    this.onTap,
    this.margin = const EdgeInsets.symmetric(vertical: 6),
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
  });

  @override
  State<HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<HoverCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor:
          widget.onTap != null ? SystemMouseCursors.click : MouseCursor.defer,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          margin: widget.margin,
          transform: _hovering
              ? (Matrix4.identity()..scale(1.01))
              : Matrix4.identity(),
          transformAlignment: Alignment.center,
          child: Card(
            elevation: _hovering ? 6 : 1,
            shadowColor: _hovering
                ? Theme.of(context).colorScheme.primary.withOpacity(0.15)
                : Colors.black.withOpacity(0.05),
            shape: RoundedRectangleBorder(
              borderRadius: widget.borderRadius,
              side: BorderSide(
                color: _hovering
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                    : Colors.transparent,
              ),
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
