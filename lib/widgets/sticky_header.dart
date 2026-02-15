// lib/widgets/sticky_header.dart

import 'dart:ui';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

class StickyHeader extends StatelessWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBack;

  const StickyHeader({
    super.key,
    required this.title,
    this.actions,
    this.showBackButton = false,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dividerColor =
        theme.dividerTheme.color ?? Colors.grey.withOpacity(0.2);

    // Use solid background on web (BackdropFilter is expensive),
    // blur on native platforms
    final bgColor = kIsWeb
        ? theme.scaffoldBackgroundColor.withOpacity(0.95)
        : theme.scaffoldBackgroundColor.withOpacity(0.85);

    Widget header = Container(
      height: 53,
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          bottom: BorderSide(color: dividerColor, width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          if (showBackButton) ...[
            _BackButton(onTap: onBack),
            const SizedBox(width: 8),
          ],
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          if (actions != null) ...actions!,
        ],
      ),
    );

    // Wrap with blur on native only
    if (!kIsWeb) {
      header = ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: header,
        ),
      );
    }

    return header;
  }
}

class _BackButton extends StatefulWidget {
  final VoidCallback? onTap;

  const _BackButton({this.onTap});

  @override
  State<_BackButton> createState() => _BackButtonState();
}

class _BackButtonState extends State<_BackButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _hovering
                ? theme.colorScheme.primary.withOpacity(0.08)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.arrow_back_rounded,
            size: 20,
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ),
    );
  }
}
