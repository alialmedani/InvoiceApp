// `hide TextDirection`: easy_localization re-exports intl's TextDirection
// (RTL/LTR constants), which otherwise shadows dart:ui's TextDirection
// (rtl/ltr) needed for Directionality checks below.
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:invoice/core/constant/app_colors/app_colors.dart';
import 'package:invoice/core/constant/text_styles/app_text_style.dart';
import 'package:invoice/features/shell/data/nav_destination.dart';

/// Floating rounded bottom nav whose active indicator is a single circle
/// that physically glides between tabs via a [SpringSimulation]. Meant to be
/// placed in a [Stack] (not `Scaffold.bottomNavigationBar`) so it can float
/// with rounded corners, margins and its own shadow.
class FloatingBottomNav extends StatefulWidget {
  const FloatingBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  State<FloatingBottomNav> createState() => _FloatingBottomNavState();
}

class _FloatingBottomNavState extends State<FloatingBottomNav>
    with SingleTickerProviderStateMixin {
  static const double barHeight = 64;
  static const double circleSize = 72;

  late final AnimationController _controller;
  double? _lastBarWidth;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isRtl => Directionality.of(context) == TextDirection.rtl;

  int _resolvedIndex(int index) =>
      _isRtl ? (navDestinations.length - 1 - index) : index;

  double _centerX(int resolvedIndex, double barWidth) {
    final slotWidth = barWidth / navDestinations.length;
    return slotWidth * resolvedIndex + slotWidth / 2;
  }

  @override
  void didUpdateWidget(covariant FloatingBottomNav oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex && _lastBarWidth != null) {
      _animateTo(widget.currentIndex, _lastBarWidth!);
    }
  }

  void _animateTo(int index, double barWidth) {
    final target = _centerX(_resolvedIndex(index), barWidth);
    final spring = SpringDescription.withDampingRatio(
      mass: 1,
      stiffness: 400,
      ratio: 0.8,
    );
    final simulation = SpringSimulation(
      spring,
      _controller.value,
      target,
      _controller.velocity,
    );
    _controller.animateWith(simulation);
  }

  void _syncWidth(double barWidth) {
    if (_lastBarWidth == barWidth) return;
    final isFirstLayout = _lastBarWidth == null;
    _lastBarWidth = barWidth;
    if (isFirstLayout) {
      // No listeners are attached yet (the circle hasn't been built for the
      // first time), so it's safe to set the value synchronously here —
      // this is what makes the circle render in the right slot immediately
      // instead of flashing in from x=0 on the first frame.
      _controller.value = _centerX(_resolvedIndex(widget.currentIndex), barWidth);
    } else if (!_controller.isAnimating) {
      // A width change outside of a tap (e.g. device rotation) — snap after
      // this frame instead of mutating the animation mid-layout, the glide
      // is reserved for tab taps.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _controller.value = _centerX(_resolvedIndex(widget.currentIndex), _lastBarWidth!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _syncWidth(constraints.maxWidth);
        return Container(
          height: barHeight,
          decoration: BoxDecoration(
            color: AppColors.getCard(context),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppColors.getBorder(context)),
            boxShadow: [
              BoxShadow(
                color: AppColors.getShadow(context),
                blurRadius: 20,
                spreadRadius: 2,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Row(
                children: [
                  for (int i = 0; i < navDestinations.length; i++)
                    Expanded(
                      child: _NavSlot(
                        destination: navDestinations[i],
                        selected: widget.currentIndex == i,
                        onTap: () => widget.onTap(i),
                      ),
                    ),
                ],
              ),
              AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  return Positioned(
                    left: _controller.value - circleSize / 2,
                    top: (barHeight - circleSize) / 2,
                    // Decorative — taps must fall through to the Row's
                    // InkWells beneath it, regardless of z-order.
                    child: IgnorePointer(
                      child: _ActiveCircle(
                        destination: navDestinations[widget.currentIndex],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ActiveCircle extends StatelessWidget {
  const _ActiveCircle({required this.destination});

  final NavDestination destination;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _FloatingBottomNavState.circleSize,
      height: _FloatingBottomNavState.circleSize,
      decoration: BoxDecoration(
        color: AppColors.getPrimary(context),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.getShadow(context),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 130),
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: ScaleTransition(scale: animation, child: child),
          ),
          child: Icon(
            destination.icon,
            key: ValueKey(destination.key),
            color: AppColors.getCard(context),
            size: 24,
          ),
        ),
      ),
    );
  }
}

class _NavSlot extends StatelessWidget {
  const _NavSlot({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  final NavDestination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final muted = AppColors.getTextMuted(context);
    return Material(
      key: destination.key,
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: SizedBox(
          height: double.infinity,
          child: selected
              ? const SizedBox.shrink()
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(destination.icon, size: 22, color: muted),
                    const SizedBox(height: 3),
                    Text(
                      destination.labelKey.tr(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.getMediumStyle(
                        fontSize: 10.5,
                        color: muted,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
