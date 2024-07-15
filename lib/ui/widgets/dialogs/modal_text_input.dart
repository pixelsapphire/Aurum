import 'package:aurum/ui/theme.dart';
import 'package:aurum/ui/widgets/dialogs/modal_dialog_base.dart';
import 'package:flutter/cupertino.dart';

class ModalTextInput extends StatefulWidget {
  final Widget title;
  final Widget? subtitle;
  final Widget? prefix, suffix;
  final String? placeholder, initialValue;
  final TextAlign textAlign;
  final TextCapitalization textCapitalization;
  final TextInputType? inputType;
  final void Function(String) onSubmit;
  final void Function()? onCancel;

  const ModalTextInput({
    super.key,
    required this.title,
    this.subtitle,
    this.prefix,
    this.suffix,
    this.placeholder,
    this.initialValue,
    required this.onSubmit,
    this.onCancel,
    this.textAlign = TextAlign.start,
    this.textCapitalization = TextCapitalization.none,
    this.inputType,
  });

  @override
  State<ModalTextInput> createState() => _ModalTextInputState();
}

class _ModalTextInputState extends State<ModalTextInput> {
  String _text = '';
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _text = widget.initialValue ?? '';
    _textController = TextEditingController(text: _text);
  }

  @override
  Widget build(BuildContext context) => ModalDialogBase(
        title: widget.title,
        subtitle: widget.subtitle,
        content: CupertinoTextField(
          decoration: BoxDecoration(
            color: AurumColors.backgroundSecondary(context),
            borderRadius: BorderRadius.circular(8),
          ),
          prefix: widget.prefix,
          suffix: widget.suffix,
          textAlign: widget.textAlign,
          autofocus: true,
          placeholder: widget.placeholder,
          textCapitalization: widget.textCapitalization,
          keyboardType: widget.inputType,
          clearButtonMode: OverlayVisibilityMode.always,
          controller: _textController,
          onChanged: (value) => setState(() => _text = value),
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => (widget.onCancel ?? Navigator.of(context).pop).call(),
          ),
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () {
              widget.onSubmit(_text);
              Navigator.of(context).pop();
            },
          ),
        ],
      );
}
