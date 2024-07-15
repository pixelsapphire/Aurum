import 'package:aurum/data/database.dart';
import 'package:aurum/data/objects/record.dart';
import 'package:aurum/data/services/records_service.dart';
import 'package:aurum/ui/editors/record_editor.dart';
import 'package:aurum/ui/pages/history/common.dart';
import 'package:aurum/ui/theme.dart';
import 'package:aurum/ui/widgets/database_builders.dart';
import 'package:aurum/util/extensions.dart';
import 'package:flutter/cupertino.dart';

class RecordView extends StatelessWidget {
  final Record record;
  final bool separator, checkbox, selected;
  final void Function(bool)? onCheckboxChanged;

  const RecordView({
    super.key,
    required this.record,
    this.separator = false,
    this.checkbox = false,
    this.onCheckboxChanged,
    this.selected = false,
  });

  Widget _buildParty({
    required RecordType ifType,
    required int? thenCounterparty,
    required String? elseAccount,
    required Color color,
  }) {
    if (ifType == record.type) {
      return AurumFutureBuilder(
        notifier: AurumDatabase.counterparties,
        future: () => AurumDatabase.counterparties.getById(thenCounterparty!),
        builder: (context, snapshot) => Text(
          snapshot.hasData ? snapshot.data!.aliasOrName : '',
          style: TextStyle(fontWeight: FontWeight.bold, color: color),
        ),
      );
    } else {
      return AurumFutureBuilder(
        notifier: AurumDatabase.accounts,
        future: () => AurumDatabase.accounts.getByName(elseAccount!),
        builder: (context, snapshot) => Text(
          snapshot.hasData ? snapshot.data!.name : '',
          style: TextStyle(fontWeight: FontWeight.bold, color: color),
        ),
      );
    }
  }

  Widget _buildParties(BuildContext context) => FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildParty(
              ifType: RecordType.income,
              thenCounterparty: record.fromCounterpartyId,
              elseAccount: record.fromAccountName,
              color: (record.type != RecordType.expense
                  ? AurumColors.foregroundPrimary
                  : AurumColors.foregroundSecondary)(context),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Icon(
                CupertinoIcons.arrow_right,
                size: 16,
                color: (record.type == RecordType.ownTransfer
                    ? AurumColors.foregroundPrimary
                    : AurumColors.foregroundSecondary)(context),
              ),
            ),
            _buildParty(
              ifType: RecordType.expense,
              thenCounterparty: record.toCounterpartyId,
              elseAccount: record.toAccountName,
              color: (record.type != RecordType.income //
                  ? AurumColors.foregroundPrimary
                  : AurumColors.foregroundSecondary)(context),
            ),
          ],
        ),
      );

  Widget _buildMoneyLabel(BuildContext context) => Text(
        '${record.type == RecordType.income ? '+' : ''}${RecordsService.totalAmount(record).toStringAsFixed(2)} PLN',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: {
            RecordType.expense: CupertinoColors.systemRed,
            RecordType.income: CupertinoColors.systemGreen,
            RecordType.ownTransfer: AurumColors.foregroundPrimary(context),
          }[record.type]!,
        ),
      );

  Widget _buildRow(BuildContext context) => Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: CategoryIcons(categoryIds: record.fragments.map((f) => f.categoryId).toSet()),
          ),
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: separator ? Border(bottom: BorderSide(color: AurumColors.separator(context), width: 0.5)) : null,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            record.time.toDateString(),
                            style: TextStyle(fontSize: 14, color: AurumColors.foregroundSecondary(context)),
                          ),
                          _buildParties(context),
                          Text(record.note ?? '', style: const TextStyle(fontSize: 14)),
                        ],
                      ),
                    ),
                    Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: _buildMoneyLabel(context)),
                  ],
                ),
              ),
            ),
          ),
        ],
      );

  @override
  Widget build(BuildContext context) => Row(
        children: [
          if (checkbox)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: CupertinoSwitch(value: selected, onChanged: onCheckboxChanged, activeColor: CupertinoColors.systemGreen),
            ),
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.of(context).push(
                CupertinoModalPopupRoute(
                  builder: (context) => SafeArea(
                    child: CupertinoPopupSurface(isSurfacePainted: false, child: RecordEditor(record: record)),
                  ),
                ),
              ),
              child: Container(color: AurumColors.backgroundPrimary(context), child: _buildRow(context)),
            ),
          ),
        ],
      );
}
