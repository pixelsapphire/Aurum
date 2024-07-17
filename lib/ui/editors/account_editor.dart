import 'package:aurum/data/objects/account.dart';
import 'package:aurum/data/database.dart';
import 'package:aurum/ui/theme.dart';
import 'package:aurum/ui/editors/editor_base.dart';
import 'package:aurum/ui/widgets/database_builders.dart';
import 'package:aurum/ui/widgets/dialogs/basic_dialogs.dart';
import 'package:aurum/ui/widgets/dialogs/modal_icon_input.dart';
import 'package:aurum/ui/widgets/dialogs/modal_money_input.dart';
import 'package:aurum/ui/widgets/dialogs/modal_text_input.dart';
import 'package:aurum/ui/widgets/icons.dart';
import 'package:aurum/ui/widgets/list_item.dart';
import 'package:aurum/util/extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AccountEditor extends StatefulWidget {
  final Account? account;

  const AccountEditor({super.key, this.account});

  @override
  State<AccountEditor> createState() => _AccountEditorState();
}

class _AccountEditorState extends State<AccountEditor> {
  bool _changed = false;
  String _name = '';
  double _initialBalance = 0;
  IconData? _icon;
  Color? _color;
  bool _asset = true;

  @override
  void initState() {
    super.initState();
    if (widget.account != null) {
      _name = widget.account!.name;
      _initialBalance = widget.account!.initialBalance;
      _icon = widget.account!.icon;
      _color = widget.account!.color;
      _asset = widget.account!.asset;
    }
  }

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _changed = true;
  }

  Widget _nameTile(BuildContext context) => CupertinoListItem.basic(
        label: 'Name',
        value: _name,
        onTap: () => showCupertinoModalPopup(
          context: context,
          barrierDismissible: false,
          builder: (context) => ModalTextInput(
            title: const Text('Account name'),
            initialValue: _name,
            onSubmit: (value) => setState(() => _name = value),
          ),
        ),
      );

  Widget _iconTile(BuildContext context) => CupertinoListItem.custom(
        label: 'Icon',
        trailing: SquareIcon(background: _color, child: Icon(_icon)),
        chevron: true,
        onTap: () => showCupertinoModalPopup(
          context: context,
          barrierDismissible: false,
          builder: (context) => ModalIconInput(
            title: const Text('Account icon'),
            icons: const [
              Icons.account_balance_wallet_outlined,
              Icons.payments_outlined,
              Icons.account_balance_outlined,
              Icons.payment_outlined,
              Icons.savings_outlined,
              Icons.paid_outlined,
              Icons.health_and_safety_outlined,
              Icons.hub_outlined,
              Icons.handshake_outlined,
              Icons.real_estate_agent_outlined,
              Icons.currency_exchange_outlined,
              Icons.category_outlined,
            ],
            initialIcon: _icon,
            initialColor: _color,
            onSubmit: (icon, color) => setState(() {
              _icon = icon;
              _color = color;
            }),
          ),
        ),
      );

  Widget _balanceTile(BuildContext context) => CupertinoListItem.basic(
        label: 'Initial balance',
        value: '${_initialBalance.toStringAsFixed(2)} PLN',
        onTap: () => showCupertinoModalPopup(
          context: context,
          barrierDismissible: false,
          builder: (context) => ModalMoneyInput(
            title: const Text('Account initial balance'),
            initialValue: _initialBalance,
            onSubmit: (value) => setState(() => _initialBalance = value),
          ),
        ),
      );

  Widget _assetTile(BuildContext context) => CupertinoListItem.custom(
        label: 'Asset',
        trailing: CupertinoSwitch(
          activeColor: CupertinoColors.systemGreen,
          value: _asset,
          onChanged: (value) => setState(() => _asset = value),
        ),
      );

  List<Widget> _editActions(BuildContext context) => [
        AurumDerivedValueBuilder(
          value: AurumDatabase.accountBalance(widget.account!),
          builder: (context, currentBalance) => currentBalance == null
              ? const CupertinoListItem.basic(label: 'Set current balance')
              : CupertinoListItem.icon(
                  label: 'Set current balance',
                  icon: CupertinoIcons.pencil,
                  onTap: () => showCupertinoModalPopup(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => ModalMoneyInput(
                      title: const Text('Account current balance'),
                      subtitle: Text(
                        'Enter the current balance of this account. Initial balance will be recalculated accordingly.',
                        style: TextStyle(color: AurumColors.foregroundSecondary(context)),
                      ),
                      initialValue: currentBalance,
                      onSubmit: (value) => setState(() => _initialBalance += value - currentBalance),
                    ),
                  ),
                ),
        ),
        CupertinoListItem.icon(
          label: 'Delete account',
          icon: CupertinoIcons.delete,
          isDestructiveAction: true,
          onTap: () => Navigator.of(context).push(
            CupertinoModalPopupRoute(
              builder: (context) => CupertinoActionSheet(
                title: Text('Delete ${widget.account!.name}?'),
                message: const Text(
                    'Are you sure you want to permanently delete this account? You will not be able to undo this action.'),
                actions: [
                  CupertinoActionSheetAction(
                    isDestructiveAction: true,
                    onPressed: () => AurumDatabase.accounts
                        .delete(widget.account!)
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
      showErrorMessage(context, 'Account name cannot be empty.');
    } else if (_icon == null) {
      showErrorMessage(context, 'An icon must be created.');
    } else if (_color == null) {
      showErrorMessage(context, 'The icon color has not been selected.');
    } else {
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) => NewItemSheet(
        confirmOnExit: _changed,
        title: Text(widget.account == null ? 'New account' : 'Edit account'),
        child: Column(
          children: [
            CupertinoListSection.insetGrouped(
              hasLeading: false,
              children: [
                _nameTile(context),
                _iconTile(context),
                _balanceTile(context),
                _assetTile(context),
              ],
            ),
            if (widget.account != null) CupertinoListSection.insetGrouped(hasLeading: true, children: _editActions(context)),
          ],
        ),
        onSave: () {
          if (_errorMessage()) return;
          final newAccount = Account(_name, _icon!, _color!, _initialBalance, _asset);
          (widget.account == null
                  ? AurumDatabase.accounts.insert(newAccount)
                  : AurumDatabase.accounts.update(widget.account!, newAccount))
              .then((_) => Navigator.of(context).pop(),
                  onError: (error) =>
                      showDatabaseError(context, error, duplicateMessage: 'An account with the same name already exists.'));
        },
      );
}
