import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Unmounts the current widget tree and pumps once more.
///
/// Drift's `.watch()` streams (used throughout this app's `StreamProvider`s)
/// intentionally keep a short-lived internal `Timer` alive for a moment
/// after a subscription is cancelled, so that rapid resubscribes don't
/// re-run the same query (see drift's own comment in
/// `StreamQueryStore.markAsClosed`). `flutter_test` disposes the previous
/// test's widget tree lazily, on the *next* test's first pumped frame —
/// by then there's no further pump left to flush that timer, and the test
/// framework's "no pending timers" invariant fails.
///
/// Call this at the end of any widget test that pumps a screen watching a
/// Drift-backed stream provider, so the teardown (and Drift's timer) is
/// flushed inside the test's own body instead of leaking into the next one.
Future<void> disposeWidgetTreeCleanly(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  // A screen watching several Drift-backed stream providers at once (e.g.
  // one per dashboard card) schedules one such timer per subscription, and
  // they don't all resolve within a single pump. Loop a few times with a
  // real (non-zero) duration so fake_async actually advances far enough to
  // drain each of them.
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 1));
  }
}
