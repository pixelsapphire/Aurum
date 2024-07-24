import 'package:aurum/data/collections/collection.dart';
import 'package:aurum/data/objects/account.dart';

class AccountsCollection extends AurumCollection<Account> {
  AccountsCollection({required super.database}) : super(tables: ['accounts'], creator: (db) => db.execute('''
CREATE TABLE accounts (
  name            TEXT             PRIMARY KEY,
  icon            INTEGER NOT NULL,
  color           INTEGER NOT NULL,
  initial_balance REAL    NOT NULL,
  asset           BOOLEAN NOT NULL
);
'''));

  @override
  Future<List<Account>> getter() =>
      database.then((db) => db.query('accounts')).then((rows) => rows.map((map) => Account.fromMap(map)).toList());

  @override
  Future<void> inserter(Account item) => database.then((db) => db.insert('accounts', item.toMap()));

  @override
  Future<void> updater(Account oldItem, Account newItem) =>
      database.then((db) => db.update('accounts', newItem.toMap(), where: 'name=?', whereArgs: [oldItem.name]));

  @override
  Future<void> deleter(Account item) => database.then((db) => db.delete('accounts', where: 'name=?', whereArgs: [item.name]));

  Future<Account> getByName(String name) => database
      .then((db) => db.query('accounts', where: 'name=?', whereArgs: [name]))
      .then((rows) => Account.fromMap(rows.single));
}
