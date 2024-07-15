import 'package:aurum/ui/theme.dart';
import 'package:flutter/cupertino.dart';

enum SeparatorDirection {
  vertical,
  horizontal,
}

class Separator extends StatelessWidget {
  final SeparatorDirection direction;
  final double margin;
  final Color? color;

  const Separator({super.key, required this.direction, this.margin = 8, this.color});

  @override
  Widget build(BuildContext context) => Container(
        height: direction == SeparatorDirection.horizontal ? 1 : null,
        width: direction == SeparatorDirection.vertical ? 1 : null,
        color: color ?? AurumColors.separator(context),
        margin: EdgeInsets.symmetric(
          vertical: direction == SeparatorDirection.horizontal ? margin : 0,
          horizontal: direction == SeparatorDirection.vertical ? margin : 0,
        ),
      );
}
