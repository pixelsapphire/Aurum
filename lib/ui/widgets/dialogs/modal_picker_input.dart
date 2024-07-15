import 'package:aurum/ui/widgets/dialogs/modal_dialog_base.dart';
import 'package:flutter/cupertino.dart';

class ModalPickerInput extends StatefulWidget {
  final Widget title;
  final List<String> values;
  final String? initialValue;
  final int itemsVisible;
  final void Function(String) onSubmit;
  final void Function()? onCancel;

  const ModalPickerInput({
    super.key,
    required this.title,
    required this.values,
    this.initialValue,
    this.itemsVisible = 1,
    required this.onSubmit,
    this.onCancel,
  });

  @override
  State<ModalPickerInput> createState() => _ModalPickerInputState();
}

class _ModalPickerInputState extends State<ModalPickerInput> {
  late String _value;

  @override
  void initState() {
    super.initState();
    assert(widget.values.isNotEmpty, 'values must not be empty');
    _value = widget.initialValue ?? widget.values.first;
  }

  @override
  Widget build(BuildContext context) => ModalDialogBase(
        title: widget.title,
        content: SizedBox(
          height: widget.itemsVisible * 32 / 1.25,
          child: CupertinoPicker(
            itemExtent: 32,
            squeeze: 1.25,
            looping: true,
            magnification: 1.2,
            onSelectedItemChanged: (index) => setState(() => _value = widget.values[index]),
            scrollController: FixedExtentScrollController(initialItem: widget.values.indexOf(_value)),
            children: widget.values.map((value) => Center(child: Text(value))).toList(),
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
              widget.onSubmit(_value);
              Navigator.of(context).pop();
            },
          ),
        ],
      );
}
