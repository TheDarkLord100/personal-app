# Personal Trainer

Personal Flutter app (Android, phone-only storage) for planning, logging and exporting progress toward year-end fitness goals.

## Goals (seeded in the database)

Every exercise has two numbers: **total** and **best continuous**.

- Running: 5 km total, 2 km continuous
- Squats: 1000 total, 200 continuous
- Push-ups: 200 total, 50 continuous
- Body weight: 85 kg (daily check-in; currently a constant in `core/constants.dart`)
- Deadline: 31/12/2026

## How I want to work

- I want to stay involved and make the decisions. Before editing, explain the plan and what will change. Keep changes small and reviewable, one step at a time.
- Show exact changes. Don't make sweeping edits or refactors I didn't ask for.
- Explain the reasoning behind non-obvious choices, briefly.
- After changes: run `flutter analyze` and `flutter test`, and fix anything they report.

## Commands

```bash
dart run build_runner build --delete-conflicting-outputs   # after changing tables
flutter analyze
flutter test
flutter run
```

## Stack

- drift (SQLite) via drift_flutter
- flutter_riverpod 3.x — use Notifier/AsyncNotifier style, not legacy StateProvider/StateNotifier
- Planned: fl_chart (charts), csv + share_plus (export)

## Structure

One folder per concern in `lib/`; each pairs logic with a `*_state.dart` holding its Riverpod providers.

```
lib/
  app.dart, main.dart
  core/       dates.dart, format.dart, constants.dart, today_state.dart
  database/   tables.dart, app_database.dart (+ .g.dart), database_state.dart
  exercises/  exercise_repository.dart, exercises_state.dart
  schedule/   schedule_engine.dart (pure), schedule_rule_repository.dart, schedule_state.dart
  sessions/   session_repository.dart, session_status.dart (pure), target_suggestion.dart (pure), sessions_state.dart
  weight/     weight_repository.dart, weight_state.dart
  progress/   progress_calculator.dart (pure), progress_state.dart
  export/     csv_exporter.dart, backup_service.dart     (not built yet)
  ui/         today_screen.dart, plan_screen.dart, progress_screen.dart, settings_screen.dart
  ui/widgets/ session_tile.dart, log_session_sheet.dart, weight_checkin_sheet.dart,
              schedule_rule_editor.dart, set_targets_sheet.dart, goal_progress_card.dart, sheet_body.dart
test/         mirrors lib/ (schedule, sessions, weight, exercises, progress)
```

## Architecture rules

- Dependency direction: ui → *_state → repositories + pure logic → database.
- Screens never touch drift directly.
- Pure logic files (schedule_engine, session_status, target_suggestion, progress_calculator) have no Flutter or database calls and are unit-tested.
- Reactivity comes from drift `watch()` streams wrapped in StreamProviders. Writes go through action classes (`SessionActions`, `ScheduleActions`); streams update the UI automatically.
- Future providers: do all `ref.watch` calls before the first `await`.
- UI uses `asyncValue.when(...)` (not `switch` on AsyncData) to avoid flicker on refresh.
- Repositories are tested against `AppDatabase(NativeDatabase.memory())`; actions via `ProviderContainer` with `appDatabaseProvider.overrideWithValue(db)`.

## Conventions

- Dates are **stored** as `yyyy-MM-dd` text (sorts correctly) and **shown** as `dd/MM/yyyy`. Use helpers in `core/dates.dart`: `dayKey`, `parseDay`, `formatDate`, `formatDayKey`, `formatLongDate`, `formatShortDate`, `addDays` (never `add(Duration)`), `daysBetween`.
- Numbers display via `core/format.dart` (`formatNumber`, `formatAmount`, `formatKg`).
- Enums stored with `intEnum` (`ScheduleType`, `SessionStatus`): only append values, never reorder.
- All bottom sheets wrap content in `SheetBody` (keeps clear of the system nav bar and keyboard).
- Statuses always show icon + label, not color alone.

## Behaviour decisions (already agreed)

- **Schedule** is computed from rules (every N days from a start date, or weekday mask); a session row exists only once a target is set or something is logged. Missed days don't shift the schedule. Alternating days = two every-2-days rules with start dates one day apart.
- **Editing a rule** = end the old rule the day before the "applies from" date and add a new one, in a transaction (`replaceWith...`). Past days keep their old schedule. No past dates in pickers.
- **Status**: override wins; nothing logged → missed if past, null (upcoming) if today/future; all zeros → missed; only set targets are compared; any short → partial; all met and at least one exceeded → overachieved; all met → done.
- **Target suggestions** pre-fill (editable) only when a day has no targets: per metric, met/beat → step up from actual along a linear ramp to the goal by the deadline (min one increment: 0.1 km / 1 rep; hold at goal); fell short → repeat target. Continuous never exceeds total.
- **"Set targets for next N sessions"** skips days already logged.
- **Squats/push-ups** can be logged as sets ("40, 30, 25") → total = sum, continuous = max.
- **Weight**: one reading per day (re-log replaces); trend uses a 7-calendar-day moving average; pace compares kg/week needed vs recent kg/week.

## Done

Data layer, all repositories, pure logic, state layer (all with tests). UI: app shell with bottom nav and lifecycle refresh, Today screen, log sheet, weight check-in, Settings (schedule editor, goal editor), SheetBody used by every form sheet. Plan screen: Mon–Sun weeks, navigable into the past and future; rows show target, "Did" when logged, and status; week status count; tapping a row reuses `LogSessionSheet`; "Set targets" FAB opens `set_targets_sheet.dart` (next N sessions from today, replaces existing targets on those days).

## Next

1. **Progress screen**: per-goal cards (best, % of goal, on track vs expected line) and weight chart with 7-day average and needed vs recent pace (`goal_progress_card.dart`, fl_chart). Its app bar title currently says "Plan" by mistake.
2. **Export & backup** (Settings → Data): CSV with one row per session, dates as dd/mm/yyyy (date, exercise, target total/continuous, actual total/continuous, sets, status, note) plus weight CSV; JSON backup + restore. Share via share_plus.
3. Later/optional: editable weight goal (small settings table), archived exercises, daily reminder notification, a targets-only mode of `LogSessionSheet` for future days.