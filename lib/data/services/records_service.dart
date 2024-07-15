import 'package:aurum/data/objects/category.dart';
import 'package:aurum/data/objects/record.dart';
import 'package:aurum/util/extensions.dart';

class RecordsService {
  RecordsService._();

  static double totalAmount(Record record, {Iterable<Category>? excluded}) {
    if (record.fragments.isEmpty) return 0;
    return (excluded != null
            ? record.fragments.where((fragment) => excluded.none((category) => category.id == fragment.categoryId))
            : record.fragments)
        .map((fragment) => fragment.amount)
        .fold<double>(0, (a, b) => a + b)
        .roundToPlaces(2);
  }

  static Record clone(Record record) {
    final Record clone = Record(null, record.fromAccountName, record.fromCounterpartyId, record.toAccountName,
        record.toCounterpartyId, record.time, record.transactionId, record.note, []);
    clone.fragments.addAll(record.fragments.map((fragment) => RecordFragment(null, -1, fragment.categoryId, fragment.amount)));
    return clone;
  }

  static String humanReadable(Record record) {
    final from = record.fromAccountName ?? record.fromCounterpartyId;
    final to = record.toAccountName ?? record.toCounterpartyId;
    return '${record.time.toDateString()} $from -> $to: ${totalAmount(record)}';
  }
}
