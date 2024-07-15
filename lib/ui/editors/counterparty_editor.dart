import 'package:aurum/data/database.dart';
import 'package:aurum/data/objects/counterparty.dart';
import 'package:aurum/ui/theme.dart';
import 'package:aurum/ui/editors/editor_base.dart';
import 'package:aurum/ui/widgets/dialogs/basic_dialogs.dart';
import 'package:aurum/ui/widgets/dialogs/modal_picker_input.dart';
import 'package:aurum/ui/widgets/dialogs/modal_text_input.dart';
import 'package:aurum/util/extensions.dart';
import 'package:flutter/cupertino.dart';

class CounterpartyEditor extends StatefulWidget {
  final Counterparty? counterparty;

  const CounterpartyEditor({super.key, this.counterparty});

  @override
  State<CounterpartyEditor> createState() => _CounterpartyEditorState();
}

class _CounterpartyEditorState extends State<CounterpartyEditor> {
  bool _changed = false;
  CounterpartyType _type = CounterpartyType.company;
  String _name = '', _alias = '', _identification = '';

  @override
  void initState() {
    super.initState();
    if (widget.counterparty != null) {
      _type = widget.counterparty!.type;
      _name = widget.counterparty!.name;
      _alias = widget.counterparty!.alias ?? '';
      _identification = widget.counterparty!.identification ?? '';
    }
  }

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _changed = true;
  }

  Widget _typeTile(BuildContext context) => CupertinoListTile(
        title: const Text('Type'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Text(_type.name.capitalize(), style: TextStyle(color: AurumColors.foregroundSecondary(context))),
            ),
            const CupertinoListTileChevron(),
          ],
        ),
        onTap: () => showCupertinoModalPopup(
          context: context,
          barrierDismissible: false,
          builder: (context) => ModalPickerInput(
            title: const Text('Counterparty type'),
            values: CounterpartyType.values.map((type) => type.name.capitalize()).toList(),
            initialValue: _type.name.capitalize(),
            itemsVisible: 3,
            onSubmit: (value) => setState(() {
              _type = CounterpartyType.valueOf(value.toLowerCase());
              if (_type == CounterpartyType.private) _identification = '';
            }),
          ),
        ),
      );

  Widget _fullNameTile(BuildContext context) => CupertinoListTile(
        title: const Text('Full name'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Text(_name, style: TextStyle(color: AurumColors.foregroundSecondary(context))),
            ),
            const CupertinoListTileChevron(),
          ],
        ),
        onTap: () => showCupertinoModalPopup(
          context: context,
          barrierDismissible: false,
          builder: (context) => ModalTextInput(
            title: const Text('Counterparty full name'),
            initialValue: _name,
            onSubmit: (value) => setState(() => _name = value),
          ),
        ),
      );

  Widget _aliasTile(BuildContext context) => CupertinoListTile(
        title: const Text('Alias'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Text(_alias, style: TextStyle(color: AurumColors.foregroundSecondary(context))),
            ),
            const CupertinoListTileChevron(),
          ],
        ),
        onTap: () => showCupertinoModalPopup(
          context: context,
          barrierDismissible: false,
          builder: (context) => ModalTextInput(
            title: const Text('Counterparty alias'),
            initialValue: _alias,
            onSubmit: (value) => setState(() => _alias = value),
          ),
        ),
      );

  Widget _identificationNumberTile(BuildContext context) => CupertinoListTile(
        title: const Text('Identification number'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Text(_identification, style: TextStyle(color: AurumColors.foregroundSecondary(context))),
            ),
            const CupertinoListTileChevron(),
          ],
        ),
        onTap: () => showCupertinoModalPopup(
          context: context,
          barrierDismissible: false,
          builder: (context) => ModalTextInput(
            title: const Text('Counterparty identification number'),
            initialValue: _identification,
            onSubmit: (value) => setState(() => _identification = value),
          ),
        ),
      );

  List<Widget> _editActions(BuildContext context) => [
        CupertinoListTile(
          title: const Text('Delete counterparty', style: TextStyle(color: CupertinoColors.systemRed)),
          trailing: const Icon(CupertinoIcons.delete, color: CupertinoColors.systemRed),
          onTap: () => Navigator.of(context).push(
            CupertinoModalPopupRoute(
              builder: (context) => CupertinoActionSheet(
                title: Text('Delete ${widget.counterparty!.alias ?? widget.counterparty!.name}?'),
                message: const Text(
                    'Are you sure you want to permanently delete this counterparty? You will not be able to undo this action.'),
                actions: [
                  CupertinoActionSheetAction(
                    isDestructiveAction: true,
                    onPressed: () => AurumDatabase.counterparties
                        .delete(widget.counterparty!)
                        .then((_) => Navigator.of(context).popMany(2), onError: (error) => showDatabaseError(context, error)),
                    child: const Text('Delete account'),
                  ),
                ],
                cancelButton: CupertinoActionSheetAction(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ),
        ),
      ];

  bool _errorMessage() {
    if (_name.isEmpty) {
      showErrorMessage(context, 'Counterparty name cannot be empty.');
    } else if (_type == CounterpartyType.company && _identification.isEmpty) {
      showErrorMessage(context, 'Company identification number cannot be empty.');
    } else {
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) => NewItemSheet(
        confirmOnExit: _changed,
        title: Text(widget.counterparty == null ? 'New counterparty' : 'Edit counterparty'),
        child: Column(
          children: [
            CupertinoListSection.insetGrouped(
              hasLeading: false,
              children: [
                _typeTile(context),
                _fullNameTile(context),
                _aliasTile(context),
                if (_type != CounterpartyType.private) _identificationNumberTile(context),
              ],
            ),
            if (widget.counterparty != null)
              CupertinoListSection.insetGrouped(hasLeading: false, children: _editActions(context)),
          ],
        ),
        onSave: () {
          if (_errorMessage()) return;
          final newCounterparty = Counterparty(null, _type, _name, _alias.nullIfEmpty(), _identification.nullIfEmpty());
          (widget.counterparty == null
                  ? AurumDatabase.counterparties.insert(newCounterparty)
                  : AurumDatabase.counterparties.update(widget.counterparty!, newCounterparty))
              .then((_) => Navigator.of(context).pop(),
                  onError: (error) => showDatabaseError(context, error,
                      duplicateMessage: 'Counterparty with this identification number already exists.'));
        },
      );
}
