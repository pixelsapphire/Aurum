import 'package:aurum/ui/theme.dart';
import 'package:aurum/ui/widgets/separator.dart';
import 'package:flutter/cupertino.dart';

enum HorizontalAlignment {
  start,
  center,
  end;

  Alignment get alignment => {
        HorizontalAlignment.start: Alignment.centerLeft,
        HorizontalAlignment.center: Alignment.center,
        HorizontalAlignment.end: Alignment.centerRight,
      }[this]!;
}

class TitledCard extends StatelessWidget {
  final String title;
  final Widget child;
  final TextAlign titleAlignment;
  final HorizontalAlignment alignment;

  const TitledCard({
    super.key,
    required this.title,
    this.titleAlignment = TextAlign.start,
    this.alignment = HorizontalAlignment.center,
    required this.child,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(8),
        child: DecoratedBox(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: AurumColors.backgroundSecondary(context)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  title,
                  textAlign: titleAlignment,
                  style: TextStyle(
                    color: AurumColors.foregroundPrimary(context),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Separator(direction: SeparatorDirection.horizontal),
                Align(alignment: alignment.alignment, heightFactor: 1, child: child),
              ],
            ),
          ),
        ),
      );
}
