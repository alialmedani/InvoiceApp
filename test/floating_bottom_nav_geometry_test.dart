import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:invoice/features/shell/data/nav_destination.dart';
import 'package:invoice/features/shell/widgets/floating_bottom_nav.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Regression test for "the active-indicator circle escapes the nav bar" /
/// "the circle isn't over the right item": asserts, for every destination
/// at several bar widths (narrow, typical, wide) and in both LTR and RTL —
///
/// 1. the circle's rendered box stays fully inside the bar's own rendered
///    box (never above/below/past either edge), and
/// 2. the circle is actually centered on the selected item's own rendered
///    slot, not just "somewhere inside the bar".
///
/// (2) is what catches a hand-rolled RTL-mirroring formula drifting out of
/// sync with how `Row` really lays out under RTL — the bug this test was
/// added for after the first size/clamp-only fix still passed (1) while
/// visibly misaligning the circle.
///
/// Kept as a single test because easy_localization can only be
/// instantiated once per test process (same constraint documented in
/// screens_smoke_test.dart).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets('active circle stays fully inside the bar in every state', (
    tester,
  ) async {
    Future<void> pumpNavAt({
      required double width,
      required TextDirection direction,
      required int index,
    }) async {
      await tester.pumpWidget(
        EasyLocalization(
          supportedLocales: const [Locale('en')],
          path: 'assets/translations',
          fallbackLocale: const Locale('en'),
          startLocale: const Locale('en'),
          child: Builder(
            builder: (context) => MaterialApp(
              localizationsDelegates: context.localizationDelegates,
              supportedLocales: context.supportedLocales,
              locale: context.locale,
              home: Directionality(
                textDirection: direction,
                child: Scaffold(
                  body: Align(
                    alignment: Alignment.topLeft,
                    child: SizedBox(
                      width: width,
                      child: FloatingBottomNav(
                        currentIndex: index,
                        onTap: (_) {},
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      // No animation needed to reach steady state: the first build for a
      // given (index, width, direction) snaps the circle in synchronously.
      await tester.pumpAndSettle();
    }

    Rect activeCircleRect() {
      final circleFinder = find.byWidgetPredicate(
        (w) =>
            w is Container &&
            w.decoration is BoxDecoration &&
            (w.decoration! as BoxDecoration).shape == BoxShape.circle,
      );
      expect(
        circleFinder,
        findsOneWidget,
        reason: 'expected exactly one active-indicator circle in the tree',
      );
      return tester.getRect(circleFinder);
    }

    for (final direction in [TextDirection.ltr, TextDirection.rtl]) {
      for (final width in [280.0, 335.0, 600.0]) {
        for (var index = 0; index < navDestinations.length; index++) {
          await pumpNavAt(width: width, direction: direction, index: index);

          final barRect = tester.getRect(find.byType(FloatingBottomNav));
          final circleRect = activeCircleRect();
          final where = '${direction.name}, width=$width, index=$index';

          expect(
            circleRect.left,
            greaterThanOrEqualTo(barRect.left - 0.5),
            reason: 'circle crossed the bar\'s left edge — $where',
          );
          expect(
            circleRect.right,
            lessThanOrEqualTo(barRect.right + 0.5),
            reason: 'circle crossed the bar\'s right edge — $where',
          );
          expect(
            circleRect.top,
            greaterThanOrEqualTo(barRect.top - 0.5),
            reason: 'circle poked above the bar — $where',
          );
          expect(
            circleRect.bottom,
            lessThanOrEqualTo(barRect.bottom + 0.5),
            reason: 'circle poked below the bar — $where',
          );

          // Also never larger than the space one nav item actually has.
          final slotWidth = barRect.width / navDestinations.length;
          expect(
            circleRect.width,
            lessThanOrEqualTo(slotWidth + 0.5),
            reason: 'circle is wider than a single nav slot — $where',
          );

          // The circle must be centered on the SELECTED item's own
          // rendered slot — not merely "inside the bar somewhere". This is
          // the check that catches misalignment (e.g. a hand-rolled RTL
          // formula disagreeing with Row's real child order).
          final slotRect = tester.getRect(
            find.byKey(navDestinations[index].key),
          );
          expect(
            circleRect.center.dx,
            closeTo(slotRect.center.dx, 1.0),
            reason:
                'circle is not centered on the selected item\'s slot — $where',
          );
        }
      }
    }
  });
}
