import 'package:aurum/ui/theme.dart';
import 'package:flutter/cupertino.dart';

class SquareIcon extends StatelessWidget {
  final Color? background;
  final Icon child;
  final double borderRadius, padding;

  const SquareIcon({super.key, this.background, required this.child, this.borderRadius = 8, this.padding = 4});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        color: background ?? AurumColors.foregroundSecondary(context),
      ),
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: CupertinoTheme(data: CupertinoTheme.of(context).copyWith(primaryColor: CupertinoColors.white), child: child),
      ),
    );
  }
}
