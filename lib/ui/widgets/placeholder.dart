import 'package:aurum/ui/theme.dart';
import 'package:flutter/cupertino.dart';

class EmptyListPlaceholder extends StatelessWidget {
  final IconData icon;
  final String title, messageBeforeIcon, messageAfterIcon;

  const EmptyListPlaceholder({
    super.key,
    required this.icon,
    required this.title,
    required this.messageBeforeIcon,
    required this.messageAfterIcon,
  });

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: AurumColors.foregroundSecondary(context)),
            Padding(
              padding: const EdgeInsets.all(4),
              child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(messageBeforeIcon, style: TextStyle(fontSize: 16, color: AurumColors.foregroundSecondary(context))),
                Icon(CupertinoIcons.create, size: 16, color: AurumColors.foregroundSecondary(context)),
                Text(messageAfterIcon, style: TextStyle(fontSize: 16, color: AurumColors.foregroundSecondary(context))),
              ],
            ),
          ],
        ),
      );
}
