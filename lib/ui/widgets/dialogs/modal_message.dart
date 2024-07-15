import 'package:aurum/ui/widgets/dialogs/modal_dialog_base.dart';
import 'package:flutter/cupertino.dart';

class ModalMessage extends StatefulWidget {
  final Widget? title;
  final Widget message;
  final void Function()? onConfirm, onCancel;
  final bool showCancel;

  const ModalMessage({
    super.key,
    this.title,
    required this.message,
    this.onConfirm,
    this.onCancel,
    this.showCancel = true,
  });

  @override
  State<ModalMessage> createState() => _ModalMessageState();
}

class _ModalMessageState extends State<ModalMessage> {
  @override
  Widget build(BuildContext context) => ModalDialogBase(
        title: widget.title,
        content: widget.message,
        actions: [
          if (widget.showCancel)
            CupertinoDialogAction(
              child: const Text('Cancel'),
              onPressed: () => (widget.onCancel ?? Navigator.of(context).pop).call(),
            ),
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () {
              widget.onConfirm?.call();
              Navigator.of(context).pop();
            },
          ),
        ],
      );
}
