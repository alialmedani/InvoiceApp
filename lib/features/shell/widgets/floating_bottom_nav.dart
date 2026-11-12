import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:invoice/core/constant/app_colors/app_colors.dart';
import 'package:invoice/core/constant/text_styles/app_text_style.dart';
import 'package:invoice/features/shell/data/nav_destination.dart';

/// Floating rounded bottom nav whose active indicator is a single circle
/// that physically glides between tabs via a [SpringSimulation].
///
/// The circle's target position is the *measured* center of the currently
/// selected [_NavSlot] — read directly from its rendered [RenderBox] via a
/// [GlobalKey], not predicted from an index formula. This is what makes it
/// correct regardless of text direction (LTR/RTL mirror the [Row]'s child
/// order automatically; measuring after that happens sidesteps having to
/// reimplement that mirroring by hand — the previous, formula-based
/// approach did that and drifted out of sync with Row's real layout).
///
/// The circle's size is derived from the bar's own measured height and each
/// slot's measured width, and its position is additionally hard-clamped to
/// the bar's interior — so it is geometrically incapable of rendering
/// outside the bar, above it, or past either edge, on any screen width.
///
/// Meant to be placed in a [Stack] (not `Scaffold.bottomNavigationBar`) so
/// the bar itself can float with rounded corners, margins and its own
/// shadow.
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
  static const double _barRadius = 28;

  // Minimum breathing room kept between the circle and the bar's top/bottom
  // edge, and between the circle and its slot's left/right edge. These two
  // margins are what bound the circle's diameter below — it is derived, not
  // fixed, so it can never be "larger than the available item area".
  static const double _verticalMargin = 8;
  static const double _horizontalMargin = 8;

  late final AnimationController _controller;
  final _stackKey = GlobalKey();
  late final List<GlobalKey> _slotKeys = List.generate(
    navDestinations.length,
    (_) => GlobalKey(),
  );

  double? _lastMeasuredWidth;
  bool _hasPosition = false;

  @override
  void initState() {
    super.initState();
    // `value` here is a pixel X-coordinate, not a 0..1 animation progress —
    // AnimationController defaults to lowerBound/upperBound of 0.0/1.0,
    // which would silently clamp every real position we assign into that
    // tiny range (this was the actual root cause of the circle always
    // landing near the left edge, independent of RTL/index/width). Give it
    // bounds wide enough for any realistic bar width instead.
    _controller = AnimationController(
      vsync: this,
      lowerBound: 0,
      upperBound: 10000,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _snapToActive());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant FloatingBottomNav oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _glideToActive();
    }
  }

  /// The measured horizontal center of [_slotKeys]\[index\], in the
  /// coordinate space of the [Stack] the circle is positioned in — i.e.
  /// exactly what [Positioned.left] needs. Returns null if a layout pass
  /// hasn't happened yet (first frame).
  double? _measureSlotCenter(int index) {
    final stackBox = _stackKey.currentContext?.findRenderObject() as RenderBox?;
    final slotBox =
        _slotKeys[index].currentContext?.findRenderObject() as RenderBox?;
    if (stackBox == null ||
        slotBox == null ||
        !stackBox.hasSize ||
        !slotBox.hasSize) {
      return null;
    }
    final origin = slotBox.localToGlobal(Offset.zero, ancestor: stackBox);
    return origin.dx + slotBox.size.width / 2;
  }

  /// First layout, or a layout that shifted every slot (e.g. rotation) —
  /// jump straight to the correct spot, no animation.
  void _snapToActive() {
    if (!mounted) return;
    final target = _measureSlotCenter(widget.currentIndex);
    if (target == null) {
      // Not laid out yet — try again next frame.
      WidgetsBinding.instance.addPostFrameCallback((_) => _snapToActive());
      return;
    }
    setState(() {
      _controller.value = target;
      _hasPosition = true;
    });
  }

  /// A tab was tapped — spring from wherever the circle currently is to the
  /// newly-selected slot's measured center.
  void _glideToActive() {
    final target = _measureSlotCenter(widget.currentIndex);
    if (target == null) return;
    final spring = SpringDescription.withDampingRatio(
      mass: 1,
      stiffness: 400,
      ratio: 0.8,
    );
    _controller.animateWith(
      SpringSimulation(spring, _controller.value, target, _controller.velocity),
    );
  }

  /// The circle's diameter for the bar's current width: the smaller of
  /// "fits inside the bar height" and "fits inside one slot's width", each
  /// with margin. This is what guarantees the circle stays inside the bar
  /// vertically and never bleeds into a neighbouring slot horizontally, on
  /// any screen size — it's computed from real layout constraints, not a
  /// constant that happens to work on one device.
  double _circleSize(double barWidth) {
    final maxByHeight = barHeight - _verticalMargin * 2;
    final maxByWidth = (barWidth / navDestinations.length) - _horizontalMargin * 2;
    final size = maxByHeight < maxByWidth ? maxByHeight : maxByWidth;
    return size < 24 ? 24 : size;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final barWidth = constraints.maxWidth;
        if (barWidth <= 0) return const SizedBox(height: barHeight);

        // A width change (rotation, different device) shifts every slot's
        // real position even though `currentIndex` didn't change — snap to
        // the freshly measured position after this frame lays out.
        if (_lastMeasuredWidth != barWidth) {
          _lastMeasuredWidth = barWidth;
          WidgetsBinding.instance.addPostFrameCallback((_) => _snapToActive());
        }

        final circleSize = _circleSize(barWidth);

        return Container(
          height: barHeight,
          // Belt-and-suspenders: the circle is laid out to always fit
          // inside these bounds already (see `_circleSize`/the clamp
          // below), this clip is a backstop, not the fix.
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.getCard(context),
            borderRadius: BorderRadius.circular(_barRadius),
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
            key: _stackKey,
            children: [
              Row(
                children: [
                  for (int i = 0; i < navDestinations.length; i++)
                    Expanded(
                      child: _NavSlot(
                        key: _slotKeys[i],
                        destination: navDestinations[i],
                        selected: widget.currentIndex == i,
                        onTap: () => widget.onTap(i),
                      ),
                    ),
                ],
              ),
              if (_hasPosition)
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) {
                    // Hard-clamped so the circle's center can never be
                    // closer to either edge than its own radius — i.e. the
                    // circle is geometrically incapable of crossing the
                    // bar's bounds, even for a transient/mid-flight value.
                    final center = _controller.value.clamp(
                      circleSize / 2,
                      barWidth - circleSize / 2,
                    );
                    return Positioned(
                      left: center - circleSize / 2,
                      top: (barHeight - circleSize) / 2,
                      // Decorative — taps must fall through to the Row's
                      // InkWells beneath it, regardless of z-order.
                      child: IgnorePointer(
                        child: _ActiveCircle(
                          destination: navDestinations[widget.currentIndex],
                          size: circleSize,
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
  const _ActiveCircle({required this.destination, required this.size});

  final NavDestination destination;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.getPrimary(context),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.getShadow(context),
            blurRadius: 10,
            offset: const Offset(0, 3),
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
            size: size * 0.44,
          ),
        ),
      ),
    );
  }
}

class _NavSlot extends StatelessWidget {
  const _NavSlot({
    required super.key,
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
      // Distinct from `key` above (a GlobalKey the parent uses to measure
      // this slot's rendered position) — this is the stable, per-destination
      // key tests/tooling target, e.g. find.byKey(const Key('nav_invoices')).
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
