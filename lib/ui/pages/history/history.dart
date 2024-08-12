import 'package:aurum/data/auxiliary/history_objects.dart';
import 'package:aurum/data/database.dart';
import 'package:aurum/data/objects/account.dart';
import 'package:aurum/data/objects/category.dart';
import 'package:aurum/data/objects/counterparty.dart';
import 'package:aurum/data/objects/record.dart';
import 'package:aurum/ui/pages/history/record_view.dart';
import 'package:aurum/ui/pages/history/transaction_view.dart';
import 'package:aurum/ui/pages/page_base.dart';
import 'package:aurum/ui/widgets/database_builders.dart';
import 'package:aurum/ui/widgets/dialogs/modal_message.dart';
import 'package:aurum/ui/widgets/placeholder.dart';
import 'package:aurum/util/extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pull_down_button/pull_down_button.dart';

class History extends StatefulWidget {
  const History({super.key});

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  bool _linkMode = false;
  final Map<int, bool> _selectedRecordsIndexes = {};
  final HistoryFilterState _filter = HistoryFilterState.none();

  Widget _buildFilterButton(BuildContext context) {
    final GlobalKey filterButtonKey = GlobalKey(),
        filterAccountKey = GlobalKey(),
        filterCategoryKey = GlobalKey(),
        filterCounterpartyKey = GlobalKey();
    return CupertinoButton(
      key: filterButtonKey,
      padding: EdgeInsets.zero,
      child: const Icon(Icons.filter_list_outlined),
      onPressed: () => showPullDownMenu(
        context: context,
        items: [
          const PullDownMenuTitle(title: Text('Filter records'), titleStyle: TextStyle(fontSize: 16)),
          PullDownMenuItem(
            key: filterAccountKey,
            title: 'by account',
            icon: CupertinoIcons.chevron_forward,
            onTap: () {
              final List<Account>? accounts = AurumDatabase.accounts.value?.data;
              if (accounts == null) return;
              showPullDownMenu(
                context: context,
                items: accounts
                    .map((a) => PullDownMenuItem(title: a.name, onTap: () => setState(() => _filter.account = a)))
                    .toList(),
                position: filterAccountKey.renderBox.topRight.translate(-2, -8),
              );
            },
          ),
          PullDownMenuItem(
            key: filterCategoryKey,
            title: 'by category',
            icon: CupertinoIcons.chevron_forward,
            onTap: () {
              final List<Category>? categories = AurumDatabase.categories.value?.data;
              if (categories == null) return;
              showPullDownMenu(
                context: context,
                items: categories
                    .map((c) => PullDownMenuItem(title: c.name, onTap: () => setState(() => _filter.category = c)))
                    .toList(),
                position: filterCategoryKey.renderBox.topRight.translate(-2, -8),
              );
            },
          ),
          PullDownMenuItem(
            key: filterCounterpartyKey,
            title: 'by counterparty',
            icon: CupertinoIcons.chevron_forward,
            onTap: () {
              final List<Counterparty>? counterparties = AurumDatabase.counterparties.value?.data;
              if (counterparties == null) return;
              showPullDownMenu(
                context: context,
                items: counterparties
                    .map((c) => PullDownMenuItem(title: c.name, onTap: () => setState(() => _filter.counterparty = c)))
                    .toList(),
                position: filterCounterpartyKey.renderBox.topRight.translate(-2, -8),
              );
            },
          ),
          const PullDownMenuDivider.large(),
          PullDownMenuItem(
            title: _filter.separateRelevantRecords ? 'Show atomic transactions' : 'Separate relevant records',
            icon: _filter.separateRelevantRecords ? Icons.link_outlined : Icons.link_off_outlined,
            onTap: () => setState(() => _filter.toggleSeparateRelevantRecords()),
          ),
          PullDownMenuItem(
            title: 'Clear filters',
            icon: CupertinoIcons.clear,
            onTap: () => setState(() => _filter.clear()),
          ),
        ],
        position: filterButtonKey.renderBox.bottomRight.translate(-2, 8),
      ),
    );
  }

  Widget _buildLinkButton(BuildContext context, List<Record> records) => CupertinoButton(
        padding: EdgeInsets.zero,
        child: _linkMode ? const Text('Done') : const Icon(CupertinoIcons.link),
        onPressed: () {
          final int selectedRecordsCount = _selectedRecordsIndexes.entries.where((e) => e.value).length;
          if (!_linkMode || selectedRecordsCount == 0) {
            setState(() => _linkMode = !_linkMode);
            _selectedRecordsIndexes.clear();
          } else if (selectedRecordsCount == 1) {
            showCupertinoDialog(
              context: context,
              builder: (_) => const ModalMessage(
                title: Text('Error'),
                message: Text('Select more than one record to create an atomic transaction.'),
                showCancel: false,
              ),
              barrierDismissible: true,
            );
          } else {
            showCupertinoDialog(
              context: context,
              builder: (_) => ModalMessage(
                title: const Text('Create atomic transaction?'),
                message: Text('An atomic transaction consisting of $selectedRecordsCount records will be created.'),
                onConfirm: () {
                  setState(() => _linkMode = false);
                  final selectedRecords = records.whereIndex((index) => _selectedRecordsIndexes[index] ?? false).toList();
                  _selectedRecordsIndexes.clear();
                  AurumDatabase.records.createTransaction(selectedRecords);
                },
              ),
              barrierDismissible: false,
            );
          }
        },
      );

  Widget _buildList(BuildContext context, List<Record> records) {
    final List<HistoryEntry> entries = [];
    if (!_filter.separateRelevantRecords) {
      final Map<int, List<Record>> groupedByTransaction = {};
      for (var i = 0; i < records.length; ++i) {
        if (records[i].transactionId != null) {
          groupedByTransaction.putIfAbsent(records[i].transactionId!, () => []).add(records[i]);
        } else {
          entries.add(HistoryEntry.record(records[i], i));
        }
      }
      for (var transactionRecords in groupedByTransaction.values) {
        entries.add(HistoryEntry.transaction(transactionRecords));
      }
    } else {
      for (var i = 0; i < records.length; ++i) {
        entries.add(HistoryEntry.record(records[i], i));
      }
    }
    (entries..retainWhere(_filter.matches)).sort((a, b) => b.time.compareTo(a.time));
    return ListView.builder(
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final bool isLastEntry = index < entries.length - 1;
        if (entries[index].isRecord) {
          final (record, recordIndex) = entries[index].record;
          return RecordView(
            record: record,
            separator: isLastEntry,
            checkbox: _linkMode && record.transactionId == null,
            selected: _selectedRecordsIndexes[recordIndex] ?? false,
            onCheckboxChanged: (selected) => setState(() => _selectedRecordsIndexes[recordIndex] = selected),
          );
        } else {
          return TransactionView(
            transaction: entries[index],
            separator: isLastEntry,
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) => AurumCollectionBuilder(
        collection: AurumDatabase.records,
        onEmpty: const PageBase(
          navigationBar: CupertinoNavigationBar(middle: Text('History')),
          builtInScrollView: false,
          child: EmptyListPlaceholder.withCreateIcon(
            icon: CupertinoIcons.clock,
            title: 'No records',
            messageBeforeIcon: 'You can add records by tapping the ',
            createIcon: CupertinoIcons.add_circled,
            messageAfterIcon: ' button.',
          ),
        ),
        builder: (context, records) => PageBase(
          navigationBar: CupertinoNavigationBar(
            middle: const Text('History'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!_linkMode) _buildFilterButton(context),
                _buildLinkButton(context, records),
              ],
            ),
          ),
          builtInScrollView: false,
          child: _buildList(context, records),
        ),
      );
}
