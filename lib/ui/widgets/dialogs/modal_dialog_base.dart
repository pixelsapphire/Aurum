import 'package:flutter/cupertino.dart';

class ModalDialogBase extends StatelessWidget {
  final Widget? title, subtitle;
  final Widget content;
  final List<CupertinoDialogAction> actions;

  const ModalDialogBase({super.key, this.title, this.subtitle, required this.content, required this.actions});

  @override
  Widget build(BuildContext context) => CupertinoAlertDialog(
        title: title,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (subtitle != null) subtitle!,
            Padding(padding: const EdgeInsets.only(top: 16), child: content),
          ],
        ),
        actions: actions,
      );
}
