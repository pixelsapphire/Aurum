import 'dart:async';
import 'package:flutter/foundation.dart';
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
  final Completer<void> _initialized;

  @protected
  Future<List<T>> getter();

  @protected
  Future<void> inserter(T item);

  @protected
  Future<void> deleter(T item);

  @protected
  Future<void> updater(T oldItem, T newItem);

  void notifyInitialized() => _initialized.complete();

  AurumCollection({
    required this.database,
    required this.tables,
    required this.creator,
  })  : _initialized = Completer<void>(),
        super(null) {
    refresh();
  }

  void refresh() => _initialized.future.then((_) => getter().then(
        (values) => value = QueryResult.withData(values),
        onError: (error) => value = QueryResult.withError(error),
      ));

  Future<void> insert(T value) => _initialized.future.then((_) => inserter(value).then((_) => refresh()));

  Future<void> update(T old, T updated) => _initialized.future.then((_) => updater(old, updated).then((_) => refresh()));

  Future<void> delete(T value) => _initialized.future.then((_) => deleter(value).then((_) => refresh()));
}
