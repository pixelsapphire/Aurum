import 'dart:collection';
import 'package:aurum/data/auxiliary/history_objects.dart';
import 'package:aurum/data/database.dart';
import 'package:aurum/data/objects/record.dart';
import 'package:aurum/data/services/records_service.dart';
import 'package:aurum/ui/pages/history/common.dart';
import 'package:aurum/ui/pages/history/record_view.dart';
import 'package:aurum/ui/theme.dart';
import 'package:aurum/ui/widgets/separator.dart';
import 'package:aurum/util/extensions.dart';
import 'package:flutter/cupertino.dart';

enum _CounterpartyRole { payee, payer, both }

class TransactionView extends StatefulWidget {
  final HistoryEntry transaction;
  final bool separator;

  const TransactionView({super.key, required this.transaction, this.separator = false});

  @override
  State<TransactionView> createState() => _TransactionViewState();
}

class _TransactionViewState extends State<TransactionView> {
  bool _expanded = false;

  _CounterpartyRole _role(int counterpartyId) {
    final bool isPayer = widget.transaction.records.any((r) => r.fromCounterpartyId == counterpartyId);
    final bool isPayee = widget.transaction.records.any((r) => r.toCounterpartyId == counterpartyId);
    return isPayer && isPayee ? _CounterpartyRole.both : (isPayer ? _CounterpartyRole.payer : _CounterpartyRole.payee);
  }

  Widget _buildMoneyLabel(BuildContext context, double amount) => Text(
        '${amount.isPositive ? '+' : ''}${amount.toStringAsFixed(2)} PLN',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: {
            -1: CupertinoColors.systemRed,
            1: CupertinoColors.systemGreen,
            0: AurumColors.foregroundPrimary(context),
          }[amount.sign.toInt()]!,
        ),
      );

  Widget _buildParties(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widget.transaction.records
            .where((r) => r.counterpartyId != null)
            .map((r) => r.counterpartyId!)
            .fold(LinkedHashSet(), (entryCounterparties, recordCounterparty) => entryCounterparties..add(recordCounterparty))
            .map((counterpartyId) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FutureBuilder(
                        future: AurumDatabase.counterparties.getById(counterpartyId),
                        builder: (context, snapshot) => Text(
                          snapshot.hasData ? snapshot.data!.aliasOrName : ' ',
                          style: TextStyle(fontWeight: FontWeight.bold, color: AurumColors.foregroundPrimary(context)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Icon(
                          {
                            _CounterpartyRole.payee: CupertinoIcons.arrow_left,
                            _CounterpartyRole.payer: CupertinoIcons.arrow_right,
                            _CounterpartyRole.both: CupertinoIcons.arrow_right_arrow_left,
                          }[_role(counterpartyId)]!,
                          size: 16,
                          color: AurumColors.foregroundPrimary(context),
                        ),
                      ),
                    ],
                  ),
                ))
            .toList(),
      );

  Widget _buildAccounts(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widget.transaction.records
            .map((r) => r.accountNames)
            .fold(LinkedHashSet(), (entryAccounts, recordAccounts) => entryAccounts..addAll(recordAccounts))
            .map((accountName) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        accountName,
                        style: TextStyle(fontWeight: FontWeight.bold, color: AurumColors.foregroundPrimary(context)),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: _buildMoneyLabel(
                            context,
                            widget.transaction.records
                                .where((r) => r.accountNames.contains(accountName))
                                .map((r) =>
                                    (r.fromAccountName == accountName && r.type == RecordType.ownTransfer ? -1 : 1) *
                                    RecordsService.totalAmount(r))
                                .fold(0, (sum, amount) => sum + amount)),
                      ),
                    ],
                  ),
                ))
            .toList(),
      );

  Widget _buildRow(BuildContext context) => Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: CategoryIcons(
              categoryIds: widget.transaction.records
                  .map((r) => r.fragments.map((f) => f.categoryId))
                  .fold(<int>{}, (entryCategories, recordCategories) => entryCategories..addAll(recordCategories)),
            ),
          ),
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: widget.separator ? Border(bottom: BorderSide(color: AurumColors.separator(context), width: 0.5)) : null,
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
                            widget.transaction.time.toDateString(),
                            style: TextStyle(fontSize: 14, color: AurumColors.foregroundSecondary(context)),
                          ),
                          IntrinsicWidth(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildParties(context),
                                const Separator(direction: SeparatorDirection.horizontal, margin: 1),
                                _buildAccounts(context),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: _buildMoneyLabel(
                        context,
                        widget.transaction.records
                            .where((r) => !r.isOwnTransfer)
                            .map((r) => RecordsService.totalAmount(r))
                            .fold(0, (sum, amount) => sum + amount),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );

  Widget _buildExpandedView(BuildContext context) => IntrinsicHeight(
        child: Row(
          children: [
            GestureDetector(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Container(
                color: AurumColors.backgroundPrimary(context),
                child: const Padding(
                  padding: EdgeInsets.only(left: 16, right: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Separator(
                            direction: SeparatorDirection.vertical,
                            color: CupertinoColors.systemBlue,
                            margin: 0,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Icon(CupertinoIcons.chevron_up, color: CupertinoColors.systemBlue),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: Column(
                children: widget.transaction.records.reversed.map((r) => RecordView(record: r, separator: true)).toList(),
              ),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) => _expanded
      ? _buildExpandedView(context)
      : GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Container(color: AurumColors.backgroundPrimary(context), child: _buildRow(context)),
        );
}
