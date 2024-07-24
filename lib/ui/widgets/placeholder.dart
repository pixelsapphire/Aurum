import 'package:aurum/ui/theme.dart';
import 'package:flutter/cupertino.dart';

class EmptyListPlaceholder extends StatelessWidget {
  final IconData icon;
  final IconData? createIcon;
  final String title;
  final Widget? message;
  final String? messageBeforeIcon, messageAfterIcon;
  final bool showCreateIcon;

  const EmptyListPlaceholder({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
  })  : messageBeforeIcon = null,
        messageAfterIcon = null,
        createIcon = null,
        showCreateIcon = false;

  const EmptyListPlaceholder.withCreateIcon({
    super.key,
    required this.icon,
    required this.title,
    required this.messageBeforeIcon,
    this.createIcon = CupertinoIcons.create,
    required this.messageAfterIcon,
  })  : message = null,
        showCreateIcon = true;

  @override
  Widget build(BuildContext context) {
    final labelStyle = TextStyle(fontSize: 16, color: AurumColors.foregroundSecondary(context));
    return Center(
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
              if (showCreateIcon) ...[
                Text(messageBeforeIcon!, style: labelStyle),
                Icon(createIcon, size: 16, color: AurumColors.foregroundSecondary(context)),
                if (messageAfterIcon != null) Text(messageAfterIcon!, style: labelStyle),
              ],
              if (!showCreateIcon) DefaultTextStyle.merge(style: labelStyle, child: message!),
            ],
          ),
        ],
      ),
    );
  }
}
