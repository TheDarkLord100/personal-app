import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'dates.dart';

/// The current calendar day. Rolls over at midnight while the app is open;
/// call refresh() when the app comes back to the foreground, since timers
/// don't run while Android has the app suspended.
class TodayNotifier extends Notifier<DateTime> {
  Timer? _timer;

  @override
  DateTime build() {
    ref.onDispose(() => _timer?.cancel());
    _scheduleRollover();
    return today();
  }

  void refresh() => state = today();

  void _scheduleRollover() {
    _timer?.cancel();
    final untilMidnight = addDays(today(), 1).difference(DateTime.now());
    _timer = Timer(untilMidnight + const Duration(seconds: 1), () {
      state = today();
      _scheduleRollover();
    });
  }
}

final todayProvider =
NotifierProvider<TodayNotifier, DateTime>(TodayNotifier.new);