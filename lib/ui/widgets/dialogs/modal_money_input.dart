import 'package:aurum/ui/theme.dart';
import 'package:aurum/ui/widgets/dialogs/modal_text_input.dart';
import 'package:aurum/util/extensions.dart';
import 'package:flutter/cupertino.dart';

enum MoneyInputSign { positive, negative, both, none }

class ModalMoneyInput extends StatefulWidget {
  final Widget title;
  final Widget? subtitle;
  final double? initialValue;
  final MoneyInputSign sign;
  final void Function(double)? onSubmit;

  const ModalMoneyInput({
    super.key,
    required this.title,
    this.subtitle,
    this.initialValue,
    this.sign = MoneyInputSign.both,
    this.onSubmit,
  });

  @override
  State<ModalMoneyInput> createState() => _ModalMoneyInputState();
}

class _ModalMoneyInputState extends State<ModalMoneyInput> {
  late int sign;

  @override
  void initState() {
    super.initState();
    if (widget.sign == MoneyInputSign.both) {
      sign = widget.initialValue?.isNegative == true ? -1 : 1;
    } else {
      sign = widget.sign == MoneyInputSign.negative ? -1 : 1;
    }
  }

  @override
  Widget build(BuildContext context) => ModalTextInput(
        title: widget.title,
        subtitle: widget.subtitle,
        textAlign: TextAlign.end,
        prefix: widget.sign == MoneyInputSign.none
            ? null
            : SizedBox(
                height: 32,
                child: CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: widget.sign == MoneyInputSign.both ? () => setState(() => sign = -sign) : null,
                  child: Text(sign.isNegative ? '−' : '+', style: TextStyle(color: AurumColors.foregroundPrimary(context))),
                ),
              ),
        suffix: const Padding(padding: EdgeInsets.only(right: 8), child: Text('PLN')),
        inputType: const TextInputType.numberWithOptions(decimal: true),
        initialValue: widget.initialValue?.abs().toStringAsFixed(2),
        onSubmit: (value) => widget.onSubmit?.call(sign * (double.tryParse(value)?.roundToPlaces(2) ?? 0)),
      );
}
