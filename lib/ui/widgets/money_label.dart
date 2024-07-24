import 'package:aurum/ui/theme.dart';
import 'package:aurum/util/extensions.dart';
import 'package:flutter/cupertino.dart';

class MoneyLabel extends StatelessWidget {
  final double amount;
  final TextStyle? style;
  final String? prefix, suffix;

  const MoneyLabel(this.amount, {super.key, this.style, this.prefix, this.suffix});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (prefix != null) Text(prefix!, style: TextStyle(color: AurumColors.foregroundPrimary(context)).appendedTo(style)),
          Text(
            (amount.roundToPlaces(2) != 0 ? amount : 0).toStringAsFixed(2), // to avoid negative zero
            style: TextStyle(fontWeight: FontWeight.bold, color: AurumColors.foregroundPrimary(context)).appendedTo(style),
          ),
          if (suffix != null) Text(suffix!, style: TextStyle(color: AurumColors.foregroundPrimary(context)).appendedTo(style)),
        ],
      );
}
