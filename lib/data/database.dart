import 'dart:collection';
import 'package:aurum/data/auxiliary/metrics.dart';
import 'package:aurum/data/collections/accounts_collection.dart';
import 'package:aurum/data/collections/categories_collection.dart';
import 'package:aurum/data/collections/counterparties_collection.dart';
import 'package:aurum/data/collections/records_collection.dart';
import 'package:aurum/data/objects/account.dart';
import 'package:aurum/data/objects/category.dart';
import 'package:aurum/data/objects/record.dart';
import 'package:aurum/data/services/accounts_service.dart';
import 'package:aurum/data/services/categories_service.dart';
import 'package:aurum/data/services/records_service.dart';
import 'package:aurum/ui/widgets/dialogs/basic_dialogs.dart';
import 'package:aurum/util/cache.dart';
import 'package:aurum/util/time_period.dart';
import 'package:aurum/util/extensions.dart';
import 'package:aurum/util/utility.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class QueryResult<T> {
  final T? data;
  final dynamic error;

  QueryResult.withData(this.data) : error = null;

  QueryResult.withError(this.error) : data = null;

  bool get hasData => data != null;

  bool get hasError => error != null;
}

abstract class AurumCollection<T> extends ValueNotifier<QueryResult<List<T>>?> {
  @protected
  final Future<Database> database;
  final List<String> tables;
  final void Function(Database) creator;

  @protected
  Future<List<T>> getter();

  @protected
  Future<void> inserter(T item);

  @protected
  Future<void> deleter(T item);

  @protected
  Future<void> updater(T oldItem, T newItem);

  AurumCollection({
    required this.database,
    required this.tables,
    required this.creator,
  }) : super(null) {
    refresh();
  }

  void refresh() => getter().then(
        (values) => value = QueryResult.withData(values),
        onError: (error) => value = QueryResult.withError(error),
      );

  Future<void> insert(T value) => inserter(value).then((_) => refresh());

  Future<void> update(T old, T updated) => updater(old, updated).then((_) => refresh());

  Future<void> delete(T value) => deleter(value).then((_) => refresh());
}

class AurumDerivedValue<T> extends ValueNotifier<T?> {
  final List<ValueNotifier> _dependencies;
  final T Function() _getter;

  AurumDerivedValue({
    required List<ValueNotifier> dependencies,
    required T Function() getter,
  })  : _dependencies = dependencies,
        _getter = getter,
        super(null) {
    for (var dependency in dependencies) {
      dependency.addListener(_refresh);
    }
    _refresh();
  }

  @override
  void dispose() {
    for (var dependency in _dependencies) {
      dependency.removeListener(_refresh);
    }
    super.dispose();
  }

  void _refresh() => value = _getter();
}

void showDatabaseError(BuildContext context, dynamic error, {String? duplicateMessage}) {
  if (error is DatabaseException) {
    if (error.getResultCode() == 1555 && duplicateMessage != null) {
      showErrorMessage(context, duplicateMessage);
      return;
    }
  }
  showErrorMessage(context, error.toString());
}

class AurumDatabase {
  static final Future<Database> _db = getDatabasesPath().then((path) => openDatabase(
        join(path, 'aurum.db'),
        onOpen: (db) {
          _verifyStructuralIntegrity(db);
        },
        version: 9,
      ));
  static final List<AurumCollection> _collections = [accounts, categories, counterparties, records];

  static Future<void> _verifyStructuralIntegrity(Database db) async {
    for (AurumCollection collection in _collections) {
      if (await db
          .query('sqlite_master',
              columns: ['name'],
              where: 'type=? AND name IN (${List.filled(collection.tables.length, '?').join(',')})',
              whereArgs: ['table', ...collection.tables])
          .then((rows) => rows.isEmpty, onError: (error) => true)) collection.creator(db);
    }
    for (String tableName in (await db
        .query('sqlite_master', columns: ['name'], where: 'type=?', whereArgs: ['table'])
        .then((rows) => rows.map((row) => row['name'] as String).toList()))) {
      if (!(tableName == 'sqlite_sequence' || _collections.any((collection) => collection.tables.contains(tableName)))) {
        db.execute('DROP TABLE $tableName');
      }
    }
  }

  static void refreshAll() {
    for (var collection in _collections) {
      collection.refresh();
    }
  }

  static Future<String> executeRaw(String sql) => _db.then((db) => db.rawQuery(sql)).then(
        (rows) => (sql.trim().toLowerCase())
                .op((sql) => ['insert', 'update', 'delete', 'create', 'alter', 'drop'].any((dml) => sql.startsWith(dml)))
            ? 'Operation completed successfully.'
            : rows.toString(),
      );

  static final AccountsCollection accounts = AccountsCollection(database: _db);
  static final CategoriesCollection categories = CategoriesCollection(database: _db);
  static final CounterpartiesCollection counterparties = CounterpartiesCollection(database: _db);
  static final RecordsCollection records = RecordsCollection(database: _db);

  static AurumDerivedValue<double> accountBalance(Account account) => GlobalCache.getOrPut(
        [accountBalance, account.name],
        () => AurumDerivedValue(
          dependencies: [accounts, records],
          getter: () {
            final account_ = accounts.value?.data?.where((a) => a.name == account.name).single;
            final records_ = records.value?.data;
            return account_ != null && records_ != null ? AccountsService.accountBalance(account_, records_) : 0;
          },
        ),
      );

  static double? _balance([bool Function(Account)? accountFilter]) => accounts.value?.data
      ?.opIf(accountFilter != null, (accounts) => accounts.where((account) => account.asset).toList())
      .map((account) => records.value?.data?.op((records) => AccountsService.accountBalance(account, records)) ?? 0)
      .fold<double>(0, (totalBalance, accountBalance) => totalBalance + accountBalance)
      .roundToPlaces(2);

  static final AurumDerivedValue<double> assetsBalance = AurumDerivedValue(
    dependencies: [accounts, records],
    getter: () => _balance((account) => account.asset) ?? 0,
  );

  static final AurumDerivedValue<double> totalBalance = AurumDerivedValue(
    dependencies: [accounts, records],
    getter: () => _balance() ?? 0,
  );

  static final AurumDerivedValue<LinkedHashMap<DateTime, double>> balanceOverTimeGrouped = AurumDerivedValue(
    dependencies: [accounts, records],
    getter: () {
      final records_ = records.value?.data;
      final accounts_ = accounts.value?.data;
      final Map<DateTime, double> changeDaily = {};
      final LinkedHashMap<DateTime, double> balanceOverTime = LinkedHashMap();
      if (records_ != null && accounts_ != null) {
        for (final record in records_) {
          if (record.type != RecordType.ownTransfer) {
            changeDaily[record.time.date] = (changeDaily[record.time.date] ?? 0) + RecordsService.totalAmount(record);
          }
        }
        final DateTime firstDay = records_.min((r) => r.time).time.date;
        balanceOverTime[firstDay.previousDay] = accounts_.fold(0, (total, account) => total + account.initialBalance);
        for (final DateTime day in TimePeriod.untilToday(fromTime: firstDay).days()) {
          balanceOverTime[day] = (balanceOverTime[day.previousDay]! + (changeDaily[day] ?? 0)).roundToPlaces(2);
        }
      }
      return balanceOverTime;
    },
  );

  static final AurumDerivedValue<LinkedHashMap<DateTime, double>> balanceOverTime = AurumDerivedValue(
    dependencies: [accounts, records],
    getter: () {
      final records_ = records.value?.data?.reversed;
      final accounts_ = accounts.value?.data;
      final LinkedHashMap<DateTime, double> balanceOverTime = LinkedHashMap();
      if (records_ != null && accounts_ != null) {
        double balance = accounts_.fold(0, (total, account) => total + account.initialBalance);
        if (records_.isNotEmpty) balanceOverTime[records_.first.time.date.previousDay] = balance;
        for (final record in records_) {
          if (record.type != RecordType.ownTransfer) {
            balance = (balance + RecordsService.totalAmount(record)).roundToPlaces(2);
            balanceOverTime[record.time] = balance;
          }
        }
        balanceOverTime[DateTime.now().date] = balance.roundToPlaces(2);
        for (int i = 1; i < balanceOverTime.length; ++i) {
          if (balanceOverTime.values.elementAt(i) == balanceOverTime.values.elementAt(i - 1)) balanceOverTime.removeAt(i--);
        }
      }
      return balanceOverTime;
    },
  );

  static AurumDerivedValue<AverageMetrics> averageDailyExpenses(TimePeriod period) => GlobalCache.getOrPut(
        [averageDailyExpenses, period],
        () => AurumDerivedValue(
          dependencies: [records, categories],
          getter: () {
            final records_ = records.value?.data?.where((record) => record.isExpense && period.contains(record.time));
            final excluded_ = categories.value?.data?.whereNot((c) => CategoriesService.isAnalyzed(c, categories.value!.data!));
            if (records_ == null || records_.isEmpty || excluded_ == null) return const AverageMetrics(mean: 0, median: 0);
            final expenses = (records_.map((r) => MapEntry(r.time.date, RecordsService.totalAmount(r, excluded: excluded_))))
                .fold(period.copyWith(start: records_.min((r) => r.time).time.date).days().toMap((day) => 0.0),
                    (expensesDaily, record) => expensesDaily..[record.key] = expensesDaily[record.key]! + record.value);
            return expenses.values.op((expenses) => AverageMetrics(mean: mean(expenses), median: median(expenses)));
          },
        ),
      );

  static AurumDerivedValue<LinkedHashMap<Category, double>> _recordSumsByCategory(
          RecordType type, TimeConstraint constraint, Category? root, bool includeNonAnalyzed) =>
      GlobalCache.getOrPut(
        [_recordSumsByCategory, type, constraint, root, includeNonAnalyzed],
        () => AurumDerivedValue(
          dependencies: [categories, records],
          getter: () {
            final List<Category>? categories_ = categories.value?.data;
            final List<Record>? records_ = records.value?.data;
            final Map<Category, double> sumsByCategory = {};
            if (categories_ != null && records_ != null) {
              for (final record in records_) {
                if (record.type == type && constraint.contains(record.time)) {
                  for (final fragment in record.fragments) {
                    final category = categories_.singleWhere((c) => c.id == fragment.categoryId);
                    if (!CategoriesService.isAnalyzed(category, categories_) && !includeNonAnalyzed) continue;
                    final infraCategory = CategoriesService.getInfraCategory(category, categories_);
                    sumsByCategory[infraCategory] = (sumsByCategory[infraCategory] ?? 0) + fragment.amount;
                  }
                }
              }
            }
            return LinkedHashMap.fromEntries(
                sumsByCategory.entries.where((e) => e.value != 0).sorted((a, b) => a.value.abs().compareTo(b.value.abs())));
          },
        ),
      );

  static AurumDerivedValue<LinkedHashMap<Category, double>> expensesByCategory(TimeConstraint constraint,
          [bool includeNonAnalyzed = false]) =>
      _recordSumsByCategory(RecordType.expense, constraint, null, includeNonAnalyzed);

  static AurumDerivedValue<LinkedHashMap<Category, double>> incomesByCategory(TimeConstraint constraint) =>
      _recordSumsByCategory(RecordType.income, constraint, null, false);
}
