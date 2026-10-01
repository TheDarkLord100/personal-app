import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/today_state.dart';
import 'ui/plan_screen.dart';
import 'ui/progress_screen.dart';
import 'ui/settings_screen.dart';
import 'ui/today_screen.dart';

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  late final AppLifecycleListener _lifecycle;
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(
      onResume: () => ref.read(todayProvider.notifier).refresh(),
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Personal Trainer',
      debugShowCheckedModeBanner: false,
      // Dark only, whatever the phone's setting.
      theme: _theme(),
      home: Scaffold(
        body: IndexedStack(
          index: _tab,
          children: const [
            TodayScreen(),
            PlanScreen(),
            ProgressScreen(),
            SettingsScreen(),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _tab,
          onDestinationSelected: (i) => setState(() => _tab = i),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.today_outlined),
              selectedIcon: Icon(Icons.today),
              label: 'Today',
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined),
              selectedIcon: Icon(Icons.calendar_month),
              label: 'Plan',
            ),
            NavigationDestination(
              icon: Icon(Icons.insights_outlined),
              selectedIcon: Icon(Icons.insights),
              label: 'Progress',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}

// Dark navy with neon cyan. Colours are set exactly rather than from a seed,
// because seeded schemes tone neon colours down to pastels.
const _background = Color(0xFF0A0F1F);
const _surface = Color(0xFF121A2F); // cards, sheets
const _raised = Color(0xFF1A2440); // inputs, nav bar, dialogs
const _cyan = Color(0xFF22D3EE);
const _cyanDim = Color(0xFF0E3A48); // selected tab, segment, chip
const _violet = Color(0xFFA78BFA);
const _text = Color(0xFFE6EDF7);
const _textMuted = Color(0xFF8B9AB8);
const _line = Color(0xFF243049); // card borders, grid lines

ThemeData _theme() {
  const scheme = ColorScheme.dark(
    primary: _cyan,
    onPrimary: Color(0xFF04131A),
    primaryContainer: _cyanDim,
    onPrimaryContainer: Color(0xFFA5F3FC),
    secondary: _violet,
    onSecondary: Color(0xFF160B33),
    // Material uses secondaryContainer for the nav indicator, selected
    // segments and chips; keep those cyan.
    secondaryContainer: _cyanDim,
    onSecondaryContainer: Color(0xFFA5F3FC),
    error: Color(0xFFF43F5E),
    onError: Colors.white,
    surface: _background,
    onSurface: _text,
    onSurfaceVariant: _textMuted,
    surfaceContainerLowest: Color(0xFF070B17),
    surfaceContainerLow: _surface,
    surfaceContainer: _surface,
    surfaceContainerHigh: _raised,
    surfaceContainerHighest: Color(0xFF222E4F),
    outline: Color(0xFF4A5878),
    outlineVariant: _line,
    inverseSurface: _text,
    onInverseSurface: _background,
  );
  final rounded14 = BorderRadius.circular(14);

  return ThemeData(
    colorScheme: scheme,
    scaffoldBackgroundColor: _background,
    appBarTheme: const AppBarTheme(
      backgroundColor: _background,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      titleTextStyle: TextStyle(
          color: _text, fontSize: 22, fontWeight: FontWeight.w600),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: _surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: _line),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _raised,
      border: OutlineInputBorder(borderRadius: rounded14),
      enabledBorder: OutlineInputBorder(
        borderRadius: rounded14,
        borderSide: const BorderSide(color: _line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: rounded14,
        borderSide: const BorderSide(color: _cyan, width: 1.5),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: _cyan,
      foregroundColor: Color(0xFF04131A),
      shape: StadiumBorder(),
    ),
    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: _surface,
      surfaceTintColor: Colors.transparent,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: _surface,
      surfaceTintColor: Colors.transparent,
      dragHandleColor: _textMuted,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: _raised,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: _cyan,
      linearTrackColor: _raised,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: _raised,
      contentTextStyle: const TextStyle(color: _text),
      actionTextColor: _cyan,
      shape: RoundedRectangleBorder(borderRadius: rounded14),
    ),
    dividerTheme: const DividerThemeData(color: _line),
    listTileTheme: const ListTileThemeData(iconColor: _textMuted),
  );
}