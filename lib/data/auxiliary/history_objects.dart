import 'package:aurum/data/database.dart';
import 'package:aurum/data/objects/account.dart';
import 'package:aurum/data/objects/category.dart';
import 'package:aurum/data/objects/counterparty.dart';
import 'package:aurum/data/objects/record.dart';
import 'package:aurum/data/services/categories_service.dart';
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

  bool hasAccount(Account account) {
    if (isRecord) return _record!.fromAccountName == account.name || _record.toAccountName == account.name;
    return _records!.any((r) => HistoryEntry.record(r, -1).hasAccount(account));
  }

  bool hasCategory(Category category) {
    if (isRecord) {
      final List<Category>? categories = AurumDatabase.categories.value?.data;
      if (categories == null) return true;
      return _record!.fragments.any((f) =>
          f.categoryId == category.id ||
          (CategoriesService.isChildOf(categories.firstWhere((c) => f.categoryId == c.id), category, categories)));
    }
    return _records!.any((r) => HistoryEntry.record(r, -1).hasCategory(category));
  }

  bool hasCounterparty(Counterparty counterparty) {
    if (isRecord) return _record!.fromCounterpartyId == counterparty.id || _record.toCounterpartyId == counterparty.id;
    return _records!.any((r) => HistoryEntry.record(r, -1).hasCounterparty(counterparty));
  }
}

class HistoryFilterState {
  Account? _account;
  Category? _category;
  Counterparty? _counterparty;
  bool separateRelevantRecords;

  HistoryFilterState._({Account? account, Category? category, Counterparty? counterparty, this.separateRelevantRecords = false})
      : _counterparty = counterparty,
        _category = category,
        _account = account;

  HistoryFilterState.none()
      : _account = null,
        _category = null,
        _counterparty = null,
        separateRelevantRecords = false;

  HistoryFilterState copyWith({
    Account? account,
    Category? category,
    Counterparty? counterparty,
    bool? separateRelevantRecords,
  }) =>
      HistoryFilterState._(
        account: account ?? _account,
        category: category ?? _category,
        counterparty: counterparty ?? _counterparty,
        separateRelevantRecords: separateRelevantRecords ?? this.separateRelevantRecords,
      );

  bool get hasAccount => _account != null;

  Account get account => _account!;

  set account(Account account) => _account = account;

  bool get hasCategory => _category != null;

  Category get category => _category!;

  set category(Category category) => _category = category;

  bool get hasCounterparty => _counterparty != null;

  Counterparty get counterparty => _counterparty!;

  set counterparty(Counterparty counterparty) => _counterparty = counterparty;

  void toggleSeparateRelevantRecords() => separateRelevantRecords = !separateRelevantRecords;

  void clear() {
    _account = null;
    _category = null;
    _counterparty = null;
    separateRelevantRecords = false;
  }

  bool get isEmpty => !hasAccount && !hasCategory && !hasCounterparty;

  bool matches(HistoryEntry entry) =>
      (!hasAccount || entry.hasAccount(account)) &&
      (!hasCategory || entry.hasCategory(category)) &&
      (!hasCounterparty || entry.hasCounterparty(counterparty));
}
