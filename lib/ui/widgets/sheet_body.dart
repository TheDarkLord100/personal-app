import 'package:flutter/material.dart';

/// Standard layout for bottom sheet content: side padding, stays above the
/// system navigation bar, moves up with the keyboard, and scrolls if needed.
class SheetBody extends StatelessWidget {
  const SheetBody({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: child,
        ),
      ),
    );
  }
}