import 'package:aurum/ui/theme.dart';
import 'package:aurum/ui/widgets/dialogs/modal_dialog_base.dart';
import 'package:aurum/ui/widgets/static_grid_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class ModalIconInput extends StatefulWidget {
  final Widget title;
  final List<IconData> icons;
  final IconData? initialIcon;
  final Color? initialColor;
  final void Function(IconData?, Color?) onSubmit;
  final void Function()? onCancel;

  const ModalIconInput({
    super.key,
    required this.title,
    required this.icons,
    this.initialIcon,
    this.initialColor,
    required this.onSubmit,
    this.onCancel,
  });

  @override
  State<ModalIconInput> createState() => _ModalIconInputState();
}

class _ModalIconInputState extends State<ModalIconInput> {
  int selectedSection = 0;
  IconData? _icon;
  Color? _color;

  @override
  void initState() {
    super.initState();
    _icon = widget.initialIcon;
    _color = widget.initialColor;
  }

  @override
  Widget build(BuildContext context) => ModalDialogBase(
        title: widget.title,
        content: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: CupertinoSegmentedControl(
                children: const {
                  0: Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('Pictograph')),
                  1: Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('Color')),
                },
                groupValue: selectedSection,
                onValueChanged: (value) => setState(() => selectedSection = value),
              ),
            ),
            if (selectedSection == 0)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  StaticGridView(
                    crossAxisCount: 4,
                    children: widget.icons
                        .map((icon) => GestureDetector(
                              onTap: () => setState(() => _icon = icon),
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: _icon == icon ? AurumColors.backgroundSecondary(context) : null,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Icon(
                                    icon,
                                    size: 36,
                                    color: AurumColors.foregroundSecondary(context),
                                  ),
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ],
              ),
            if (selectedSection == 1)
              DecoratedBox(
                decoration: BoxDecoration(
                  color: AurumColors.backgroundSecondary(context),
                  borderRadius: const BorderRadius.all(Radius.circular(16)),
                ),
                child: Theme(
                  data: ThemeData.dark(),
                  child: SlidePicker(
                    colorModel: ColorModel.hsl,
                    pickerColor: _color ?? CupertinoColors.systemGrey,
                    enableAlpha: false,
                    displayThumbColor: false,
                    showSliderText: false,
                    showParams: true,
                    showIndicator: true,
                    indicatorBorderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    indicatorSize: const Size(256, 30),
                    sliderSize: const Size(256, 30),
                    onColorChanged: (c) => _color = c,
                  ),
                ),
              ),
          ],
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => (widget.onCancel ?? Navigator.of(context).pop).call(),
          ),
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () {
              widget.onSubmit(_icon, _color);
              Navigator.of(context).pop();
            },
          ),
        ],
      );
}
