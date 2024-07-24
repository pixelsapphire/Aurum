import 'package:aurum/data/auxiliary/history_entry.dart';
import 'package:aurum/data/database.dart';
import 'package:aurum/data/objects/record.dart';
import 'package:aurum/ui/pages/history/record_view.dart';
import 'package:aurum/ui/pages/history/transaction_view.dart';
import 'package:aurum/ui/pages/page_base.dart';
import 'package:aurum/ui/widgets/database_builders.dart';
import 'package:aurum/ui/widgets/dialogs/modal_message.dart';
import 'package:aurum/ui/widgets/placeholder.dart';
import 'package:aurum/util/extensions.dart';
import 'package:flutter/cupertino.dart';

class History extends StatefulWidget {
  const History({super.key});

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  bool _linkMode = false;
  final Map<int, bool> _selectedRecordsIndexes = {};

  CupertinoNavigationBar _buildNavigationBar(BuildContext context, List<Record> records) => CupertinoNavigationBar(
        middle: const Text('History'),
        trailing: CupertinoButton(
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
        ),
      );

  Widget _buildList(BuildContext context, List<Record> records) {
    final Map<int, List<Record>> groupedByTransaction = {};
    final List<HistoryEntry> entries = [];
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
    entries.sort((a, b) => b.time.compareTo(a.time));
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
        onEmpty: const EmptyListPlaceholder.withCreateIcon(
          icon: CupertinoIcons.clock,
          title: 'No records',
          messageBeforeIcon: 'You can add records by tapping the ',
          createIcon: CupertinoIcons.add_circled,
          messageAfterIcon: ' button.',
        ),
        builder: (context, records) => PageBase(
          navigationBar: _buildNavigationBar(context, records),
          builtInScrollView: false,
          child: _buildList(context, records),
        ),
      );
}
