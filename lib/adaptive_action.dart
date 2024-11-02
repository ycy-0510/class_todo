import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AdaptiveAction extends StatelessWidget {
  const AdaptiveAction(
      {super.key,
      required this.onPressed,
      required this.child,
      this.danger = false});
  final VoidCallback onPressed;
  final Widget child;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    switch (theme.platform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              onPressed();
            },
            style: TextButton.styleFrom(
                foregroundColor: danger ? Colors.red : null),
            child: child);
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return CupertinoDialogAction(
            onPressed: () {
              HapticFeedback.lightImpact();
              onPressed();
            },
            isDestructiveAction: danger,
            child: child);
    }
  }
}
