import 'package:aurum/data/collections/collection.dart';
import 'package:aurum/data/objects/counterparty.dart';

class CounterpartiesCollection extends AurumCollection<Counterparty> {
  CounterpartiesCollection({required super.database}) : super(tables: ['counterparties'], creator: (db) => db.execute('''
CREATE TABLE counterparties (
  id             INTEGER          PRIMARY KEY AUTOINCREMENT,
  type           TEXT    NOT NULL,
  name           TEXT    NOT NULL,
  alias          TEXT,
  identification TEXT,
  CONSTRAINT private_no_identification CHECK  (type <> 'private' OR (type = 'private') = (identification IS NULL)),
  CONSTRAINT company_identification    CHECK  (type <> 'company' OR (type = 'company') = (identification IS NOT NULL)),
  CONSTRAINT unique_identification     UNIQUE (identification)
);
'''));

  @override
  Future<List<Counterparty>> getter() =>
      database.then((db) => db.query('counterparties')).then((rows) => rows.map((map) => Counterparty.fromMap(map)).toList());

  @override
  Future<void> inserter(Counterparty item) => database.then((db) => db.insert('counterparties', item.toMap()));

  @override
  Future<void> updater(Counterparty oldItem, Counterparty newItem) =>
      database.then((db) => db.update('counterparties', newItem.toMap(), where: 'name=?', whereArgs: [oldItem.name]));

  @override
  Future<void> deleter(Counterparty item) =>
      database.then((db) => db.delete('counterparties', where: 'name=?', whereArgs: [item.name]));

  Future<Counterparty> getById(int id) => database
      .then((db) => db.query('counterparties', where: 'id=?', whereArgs: [id]))
      .then((rows) => Counterparty.fromMap(rows.single));
}
