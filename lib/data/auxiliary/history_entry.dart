import 'package:aurum/data/objects/record.dart';
import 'package:aurum/util/comparator.dart';
import 'package:aurum/util/extensions.dart';

class HistoryEntry {
  final Record? _record;
  final int? _recordIndex;
  final List<Record>? _records;

  static final _recordComparator = Comparator<Record>((a, b) => a.time.compareTo(b.time))
      .then((a, b) => (a.id ?? double.maxFinite).compareTo(b.id ?? double.maxFinite));

  HistoryEntry.record(Record record, int recordIndex)
      : _record = record,
        _recordIndex = recordIndex,
        _records = null;

  HistoryEntry.transaction(List<Record> transaction)
      : _record = null,
        _recordIndex = null,
        _records = transaction.sorted(_recordComparator.compare).toList();

  bool get isRecord => _record != null;

  bool get isTransaction => _records != null;

  (Record, int) get record => (_record!, _recordIndex!);

  List<Record> get records => _records!;

  DateTime get time => isRecord ? _record!.time : _records!.min((r) => r.time).time;
}
