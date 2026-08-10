import 'dart:math';
import 'dart:ui';

import 'package:invoice/core/constant/app_colors/app_colors.dart';
import 'package:invoice/core/constant/text_styles/app_text_style.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class EnkiSignatureLoadingOverlay extends StatefulWidget {
  const EnkiSignatureLoadingOverlay({
    super.key,
    this.message = 'loading',
    this.logoAsset = 'assets/icons/logo.svg',
  });

  final String message;
  final String logoAsset;

  static Future<Future<Object?>> show(
    BuildContext context, {
    String message = 'loading',
    String logoAsset = 'assets/icons/logo.svg',
  }) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'enki_loading',
      // ✅ lighter in dark (was too heavy)
      barrierColor: Colors.black.withValues(alpha: isDark ? 0.22 : 0.06),
      transitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (_, __, ___) {
        return EnkiSignatureLoadingOverlay(
          message: message,
          logoAsset: logoAsset,
        );
      },
      transitionBuilder: (_, anim, __, child) {
        final c = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
        return FadeTransition(
          opacity: c,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.99, end: 1.0).animate(c),
            child: child,
          ),
        );
      },
    );
  }

  static void hide(BuildContext context) {
    if (Navigator.of(context).canPop()) Navigator.of(context).pop();
  }

  @override
  State<EnkiSignatureLoadingOverlay> createState() =>
      _EnkiSignatureLoadingOverlayState();
}

class _EnkiSignatureLoadingOverlayState
    extends State<EnkiSignatureLoadingOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5200),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const corporateGlow = Color(0xFF9FB3FF);

    final isDark = Theme.of(context).brightness == Brightness.dark;


    // for painters
    final ink = isDark ? Colors.white : const Color(0xFF0D1721);

    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          // ===== Background (theme-aware, uses your palette) =====
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (context, _) {
                final t = _ctrl.value * 2 * pi;

                // ✅ Use your bg/card palette in dark (no more "extra-black" background)
                final c1 = isDark
                    ? Color.lerp(
                           AppColors.getBackground(context),
                        AppColors.getCard(context),
                        0.22 + 0.06 * sin(t),
                      )!
                    : Color.lerp(
                        const Color(0xFFF7F8FA),
                        const Color(0xFFF0F2F6),
                        0.18 + 0.10 * sin(t),
                      )!;

                final c2 = isDark
                    ? Color.lerp(AppColors.getBackground(context), Colors.black, 0.10 + 0.06 * cos(t))!
                    : const Color(0xFFF2F4F7);

                final c3 = isDark
                    ? Color.lerp(
                        AppColors.getCard(context),
                        Colors.black,
                        0.14 + 0.06 * cos(t),
                      )!
                    : Color.lerp(
                        const Color(0xFFEEF1F6),
                        const Color(0xFFE8ECF3),
                        0.18 + 0.10 * cos(t),
                      )!;

                final c4 = isDark ? AppColors.getBackground(context) : const Color(0xFFF8FAFC);

                // subtle accent wash (dark only)
                final accentWash = isDark
                    ? Color.lerp(
                        AppColors.getBackground(context),
                        AppColors.getAccent(context),
                        0.08,
                      )!.withValues(alpha: 0.20)
                    : Colors.transparent;

                return Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isDark
                              ? [c1, accentWash, c2, c3, c4]
                              : [c1, c2, c3, c4],
                          stops: isDark
                              ? const [0.0, 0.18, 0.42, 0.75, 1.0]
                              : const [0.0, 0.35, 0.72, 1.0],
                        ),
                      ),
                    ),

                    // grid overlay
                    IgnorePointer(
                      child: CustomPaint(
                        painter: _GridPainter(progress: _ctrl.value, ink: ink),
                        child: const SizedBox.expand(),
                      ),
                    ),

                    // orbs
                    const Positioned(
                      top: -170,
                      right: -170,
                      child: _SoftOrb(
                        size: 440,
                        glowColor: corporateGlow,
                        alpha: 0.08,
                      ),
                    ),
                    Positioned(
                      bottom: -170,
                      left: -170,
                      child: _SoftOrb(
                        size: 440,
                        glowColor: isDark
                            ? const Color(0xFF24324A)
                            : const Color(0xFFC9D2E3),
                        alpha: isDark ? 0.10 : 0.14,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // ===== Blur overlay (lighter in dark) =====
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                color: (isDark ? Colors.black : Colors.white).withValues(
                  alpha: isDark ? 0.06 : 0.03,
                ),
              ),
            ),
          ),

          // ===== Center Signature Loader (NO CARD) =====
          Center(
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (context, _) {
                final p = _ctrl.value; // 0..1
                final breath = 0.5 + 0.5 * sin(p * 2 * pi); // 0..1
                final glow = 0.10 + 0.08 * breath;

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 290,
                      height: 290,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // outer halo (soft)
                          Container(
                            width: 260,
                            height: 260,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: corporateGlow.withValues(alpha: glow),
                                  blurRadius: 90,
                                  spreadRadius: 8,
                                ),
                              ],
                            ),
                          ),

                          // orbit rings (signature)
                          CustomPaint(
                            size: const Size(290, 290),
                            painter: _OrbitPainter(progress: p, ink: ink),
                          ),

                          // HERO LOGO BADGE
                          Hero(
                            tag: 'enkiLogoHero',
                            flightShuttleBuilder:
                                (
                                  context,
                                  animation,
                                  direction,
                                  fromContext,
                                  toContext,
                                ) {
                                  final c = CurvedAnimation(
                                    parent: animation,
                                    curve: Curves.easeOutCubic,
                                  );

                                  return FadeTransition(
                                    opacity: c,
                                    child: ScaleTransition(
                                      scale: Tween<double>(
                                        begin: 0.985,
                                        end: 1.0,
                                      ).animate(c),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: toContext.widget,
                                      ),
                                    ),
                                  );
                                },
                            child: _LogoBadge(
                              size: 176,
                              padding: 40,
                              glowAlpha: glow,
                              logoAsset: widget.logoAsset,
                              isDark: isDark,
                              card: AppColors.getCard(context),
                              border: AppColors.getBorder(context),
                              shadow: AppColors.getShadow(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      "JASIM",
                      style: AppTextStyle.getBoldStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: AppColors.getPrimary(context).withValues(alpha: 0.92),
                       ),
                    ),
                    const SizedBox(height: 10),

                    // mini loader line
                    _ScanLine(
                      progress: p,
                      trackColor: (isDark ? Colors.white : Colors.black)
                          .withValues(alpha: 0.10),
                    ),

                    const SizedBox(height: 12),
                    Text(
                      widget.message == 'loading'
                          ? context.tr('loading')
                          : widget.message,
                      textAlign: TextAlign.center,
                      style: AppTextStyle.getRegularStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.getPrimary(context).withValues(alpha: 0.65),
                       ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/* =======================
   Signature Pieces
======================= */

class _LogoBadge extends StatelessWidget {
  const _LogoBadge({
    required this.size,
    required this.padding,
    required this.glowAlpha,
    required this.logoAsset,
    required this.isDark,
    required this.card,
    required this.border,
    required this.shadow,
  });

  final double size;
  final double padding;
  final double glowAlpha;
  final String logoAsset;

  final bool isDark;
  final Color card;
  final Color border;
  final Color shadow;

  @override
  Widget build(BuildContext context) {
    const corporateGlow = Color(0xFF9FB3FF);

    final g1 = isDark
        ? Color.lerp(card, Colors.white, 0.08)!.withValues(alpha: 0.98)
        : Colors.white.withValues(alpha: 0.98);

    final g2 = isDark
        ? Color.lerp(card, Colors.black, 0.10)!.withValues(alpha: 0.98)
        : const Color(0xFFF1F3F6).withValues(alpha: 0.98);

    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [g1, g2], stops: const [0.0, 1.0]),
        border: Border.all(color: border, width: 1.2),
        boxShadow: [
          BoxShadow(color: shadow, blurRadius: 26, offset: const Offset(0, 14)),
          BoxShadow(
            color: corporateGlow.withValues(alpha: glowAlpha),
            blurRadius: 75,
            offset: const Offset(0, 30),
          ),
        ],
      ),
      // ✅ tint logo in dark to white/gray so it pops
      child: SvgPicture.asset(
        logoAsset,
        fit: BoxFit.contain,
        colorFilter: isDark
            ? ColorFilter.mode(
                Colors.white.withValues(alpha: 0.92),
                BlendMode.srcIn,
              )
            : null,
      ),
    );
  }
}

/// Orbit painter: rings + ticks + sweep highlight
class _OrbitPainter extends CustomPainter {
  _OrbitPainter({required this.progress, required this.ink});
  final double progress;
  final Color ink;

  @override
  void paint(Canvas canvas, Size size) {
    const corporateGlow = Color(0xFF9FB3FF);

    final center = Offset(size.width / 2, size.height / 2);

    final outerR = size.width * 0.46;
    final innerR = size.width * 0.37;

    final t = progress * 2 * pi;

    // ring base
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // subtle outer ring
    ringPaint
      ..strokeWidth = 2.0
      ..color = ink.withValues(alpha: 0.08);
    canvas.drawCircle(center, outerR, ringPaint);

    // inner ring
    ringPaint
      ..strokeWidth = 1.8
      ..color = ink.withValues(alpha: 0.06);
    canvas.drawCircle(center, innerR, ringPaint);

    // sweep highlight arc (outer)
    final sweepRect = Rect.fromCircle(center: center, radius: outerR);
    final sweep = SweepGradient(
      startAngle: 0,
      endAngle: 2 * pi,
      transform: GradientRotation(t),
      colors: [
        Colors.transparent,
        corporateGlow.withValues(alpha: 0.22),
        Colors.transparent,
      ],
      stops: const [0.0, 0.12, 0.22],
    );

    final sweepPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..shader = sweep.createShader(sweepRect)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.2);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: outerR),
      0,
      2 * pi,
      false,
      sweepPaint,
    );

    // ticks
    final tickPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = corporateGlow.withValues(alpha: 0.18);

    final tickCount = 44;
    for (int i = 0; i < tickCount; i++) {
      final a = (i / tickCount) * 2 * pi + (t * 0.45);
      final len = (i % 4 == 0) ? 10.0 : 6.0;

      final p1 = Offset(
        center.dx + (innerR + 18) * cos(a),
        center.dy + (innerR + 18) * sin(a),
      );
      final p2 = Offset(
        center.dx + (innerR + 18 + len) * cos(a),
        center.dy + (innerR + 18 + len) * sin(a),
      );
      canvas.drawLine(p1, p2, tickPaint);
    }

    // orbiting dots
    final dotPaint = Paint()..style = PaintingStyle.fill;

    final d1 = Offset(
      center.dx + outerR * cos(t * 0.8),
      center.dy + outerR * sin(t * 0.8),
    );
    dotPaint.color = corporateGlow.withValues(alpha: 0.55);
    canvas.drawCircle(d1, 3.4, dotPaint);

    final d2 = Offset(
      center.dx + innerR * cos(-t * 1.05 + 1.4),
      center.dy + innerR * sin(-t * 1.05 + 1.4),
    );
    dotPaint.color = ink.withValues(alpha: 0.22);
    canvas.drawCircle(d2, 2.7, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _OrbitPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.ink != ink;
}

/// Unique mini loader line (not dots)
class _ScanLine extends StatelessWidget {
  const _ScanLine({required this.progress, required this.trackColor});

  final double progress;
  final Color trackColor;

  @override
  Widget build(BuildContext context) {
    const corporateGlow = Color(0xFF9FB3FF);

    final p = progress;
    final x = (p * 140) - 70; // -70..70

    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 180,
        height: 10,
        decoration: BoxDecoration(
          color: trackColor,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: 0.9,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Transform.translate(
                    offset: Offset(x, 0),
                    child: Container(
                      width: 70,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            corporateGlow.withValues(alpha: 0.35),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* =======================
   Background Helpers
======================= */

class _SoftOrb extends StatelessWidget {
  const _SoftOrb({
    required this.size,
    required this.glowColor,
    required this.alpha,
  });

  final double size;
  final Color glowColor;
  final double alpha;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            glowColor.withValues(alpha: alpha),
            glowColor.withValues(alpha: 0.01),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: glowColor.withValues(alpha: alpha * 0.45),
            blurRadius: 110,
            spreadRadius: 30,
          ),
        ],
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  _GridPainter({required this.progress, required this.ink});
  final double progress;
  final Color ink;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final a = 0.035 + 0.02 * sin(progress * 2 * pi);
    paint.color = ink.withValues(alpha: a);

    const gap = 42.0;
    final dx = (progress * gap);

    for (double x = -gap; x < size.width + gap; x += gap) {
      final xx = x + dx;
      canvas.drawLine(Offset(xx, 0), Offset(xx, size.height), paint);
    }

    for (double y = -gap; y < size.height + gap; y += gap) {
      final yy = y + dx * 0.6;
      canvas.drawLine(Offset(0, yy), Offset(size.width, yy), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.ink != ink;
}
