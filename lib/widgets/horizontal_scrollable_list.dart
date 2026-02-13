// lib/widgets/horizontal_scrollable_list.dart

import 'package:flutter/material.dart';

/// A horizontal scrollable list with navigation arrows and scrollbar
/// Works consistently across touch devices (swipe) and desktop (click arrows / drag)
class HorizontalScrollableList extends StatefulWidget {
  final List<Widget> children;
  final double height;
  final EdgeInsets padding;
  final double spacing;
  final bool showNavigationArrows;
  final bool alwaysShowArrows;

  const HorizontalScrollableList({
    super.key,
    required this.children,
    this.height = 70,
    this.padding = const EdgeInsets.symmetric(horizontal: 0),
    this.spacing = 8,
    this.showNavigationArrows = true,
    this.alwaysShowArrows = true,
  });

  @override
  State<HorizontalScrollableList> createState() =>
      _HorizontalScrollableListState();
}

class _HorizontalScrollableListState extends State<HorizontalScrollableList> {
  final ScrollController _scrollController = ScrollController();
  bool _canScrollLeft = false;
  bool _canScrollRight = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateScrollButtons);
    // Check initial state after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateScrollButtons();
    });
  }

  @override
  void didUpdateWidget(covariant HorizontalScrollableList oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Recalculate scroll buttons when children change
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateScrollButtons();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _updateScrollButtons() {
    if (!mounted) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    setState(() {
      _canScrollLeft = currentScroll > 0;
      _canScrollRight = currentScroll < maxScroll && maxScroll > 0;
    });
  }

  void _scrollLeft() {
    _scrollController.animateTo(
      (_scrollController.position.pixels - 100).clamp(
        0,
        _scrollController.position.maxScrollExtent,
      ),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _scrollRight() {
    _scrollController.animateTo(
      (_scrollController.position.pixels + 100).clamp(
        0,
        _scrollController.position.maxScrollExtent,
      ),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: Stack(
        children: [
          // Scrollable content with padding for arrows
          Padding(
            padding: widget.showNavigationArrows
                ? widget.padding.add(const EdgeInsets.symmetric(horizontal: 40))
                : widget.padding,
            child: Scrollbar(
              thumbVisibility: true,
              controller: _scrollController,
              child: ListView.separated(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: widget.children.length,
                separatorBuilder: (context, index) =>
                    SizedBox(width: widget.spacing),
                itemBuilder: (context, index) => widget.children[index],
              ),
            ),
          ),

          // Left navigation arrow
          if (widget.showNavigationArrows &&
              (widget.alwaysShowArrows || _canScrollLeft))
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Center(
                child: AnimatedOpacity(
                  opacity:
                      widget.alwaysShowArrows || _canScrollLeft ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: _NavigationArrow(
                    icon: Icons.chevron_left_rounded,
                    onTap: _canScrollLeft ? _scrollLeft : null,
                    enabled: _canScrollLeft,
                  ),
                ),
              ),
            ),

          // Right navigation arrow
          if (widget.showNavigationArrows &&
              (widget.alwaysShowArrows || _canScrollRight))
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: Center(
                child: AnimatedOpacity(
                  opacity:
                      widget.alwaysShowArrows || _canScrollRight ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: _NavigationArrow(
                    icon: Icons.chevron_right_rounded,
                    onTap: _canScrollRight ? _scrollRight : null,
                    enabled: _canScrollRight,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Navigation arrow button for horizontal scrolling
class _NavigationArrow extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool enabled;

  const _NavigationArrow({
    required this.icon,
    this.onTap,
    this.enabled = true,
  });

  @override
  State<_NavigationArrow> createState() => _NavigationArrowState();
}

class _NavigationArrowState extends State<_NavigationArrow> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor:
          widget.enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: widget.enabled
                ? (_hovering
                    ? Colors.black.withOpacity(0.7)
                    : Colors.black.withOpacity(0.5))
                : Colors.black.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            widget.icon,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }
}

/// Helper widget for building image items in the horizontal list
class HorizontalImageItem extends StatelessWidget {
  final double width;
  final Widget image;
  final VoidCallback? onDelete;
  final BorderRadius borderRadius;

  const HorizontalImageItem({
    super.key,
    this.width = 70,
    required this.image,
    this.onDelete,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: borderRadius,
            child: image,
          ),
          if (onDelete != null)
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: onDelete,
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red,
                  ),
                  padding: const EdgeInsets.all(3),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 12,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Helper widget for "Add Image" button in the horizontal list
class AddImageButton extends StatelessWidget {
  final double width;
  final double height;
  final VoidCallback onTap;
  final String? label;
  final BorderRadius borderRadius;

  const AddImageButton({
    super.key,
    this.width = 120,
    this.height = 120,
    required this.onTap,
    this.label,
    this.borderRadius = const BorderRadius.all(Radius.circular(14)),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.04),
          borderRadius: borderRadius,
          border: Border.all(
            color: theme.colorScheme.primary.withOpacity(0.15),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate_outlined,
              size: 32,
              color: theme.colorScheme.primary.withOpacity(0.4),
            ),
            if (label != null) ...[
              const SizedBox(height: 6),
              Text(
                label!,
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.primary.withOpacity(0.5),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
