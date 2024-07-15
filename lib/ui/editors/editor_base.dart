import 'dart:async';
import 'package:aurum/util/extensions.dart';
import 'package:flutter/cupertino.dart';

class NewItemSheet extends StatelessWidget {
  final Widget? title;
  final Widget child;
  final FutureOr<void> Function()? onSave;
  final bool confirmOnExit;

  const NewItemSheet({super.key, this.title, required this.child, this.onSave, this.confirmOnExit = true});

  @override
  Widget build(BuildContext context) => CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: title,
          leading: CupertinoButton(
            padding: const EdgeInsets.all(4),
            onPressed: () {
              if (confirmOnExit) {
                Navigator.of(context).push(
                  CupertinoModalPopupRoute(
                    builder: (context) => SafeArea(
                      child: CupertinoActionSheet(
                          title: const Text('Discard changes?'),
                          message: const Text('Are you sure you want to discard the changes?'),
                          actions: [
                            CupertinoActionSheetAction(
                              onPressed: () => Navigator.of(context).popMany(2),
                              child: const Text(
                                'Discard changes',
                                style: TextStyle(color: CupertinoColors.systemRed, fontSize: 20),
                              ),
                            ),
                          ],
                          cancelButton: CupertinoActionSheetAction(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Keep editing', style: TextStyle(fontSize: 20)),
                          )),
                    ),
                  ),
                );
              } else {
                Navigator.of(context).pop();
              }
            },
            child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          trailing: CupertinoButton(
            padding: const EdgeInsets.all(4),
            onPressed: onSave ?? () => Navigator.of(context).pop(),
            child: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) => SizedBox(
              height: constraints.maxHeight,
              child: SingleChildScrollView(child: child),
            ),
          ),
        ),
      );
}
