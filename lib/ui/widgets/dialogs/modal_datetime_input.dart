import 'package:aurum/ui/widgets/dialogs/modal_dialog_base.dart';
import 'package:flutter/cupertino.dart';

class ModalDateTimeInput extends StatefulWidget {
  final Widget title;
  final DateTime? initialValue;
  final void Function(DateTime) onSubmit;
  final void Function()? onCancel;

  const ModalDateTimeInput({
    super.key,
    required this.title,
    this.initialValue,
    required this.onSubmit,
    this.onCancel,
  });

  @override
  State<ModalDateTimeInput> createState() => _ModalDateTimeInputState();
}

class _ModalDateTimeInputState extends State<ModalDateTimeInput> {
  DateTime _time = DateTime.now();

  @override
  void initState() {
    super.initState();
    _time = widget.initialValue ?? DateTime.now();
  }

  @override
  Widget build(BuildContext context) => ModalDialogBase(
        title: widget.title,
        content: FittedBox(
          fit: BoxFit.contain,
          child: SizedBox(
            height: 200,
            width: 300,
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.dateAndTime,
              initialDateTime: _time,
              onDateTimeChanged: (time) => setState(() => _time = time),
            ),
          ),
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => (widget.onCancel ?? Navigator.of(context).pop).call(),
          ),
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () {
              widget.onSubmit(_time);
              Navigator.of(context).pop();
            },
          ),
        ],
      );
}
