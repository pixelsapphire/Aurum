import 'package:aurum/data/collections/collection.dart';
import 'package:aurum/data/objects/record.dart';

class RecordsCollection extends AurumCollection<Record> {
  RecordsCollection({required super.database})
      : super(
            tables: ['records', 'fragments'],
            creator: (db) {
              db.execute('''
CREATE TABLE records (
  id                    INTEGER          PRIMARY KEY AUTOINCREMENT,
  time                  TEXT    NOT NULL,
  payer_account_name    TEXT             REFERENCES accounts(name)     ON DELETE RESTRICT, 
  payer_counterparty_id INTEGER          REFERENCES counterparties(id) ON DELETE RESTRICT,
  payee_account_name    TEXT             REFERENCES accounts(name)     ON DELETE RESTRICT,
  payee_counterparty_id INTEGER          REFERENCES counterparties(id) ON DELETE RESTRICT,
  transaction_id        INTEGER,
  note                  TEXT,
  CONSTRAINT single_payer      CHECK ((payer_account_name IS NULL) <> (payer_counterparty_id IS NULL)),
  CONSTRAINT single_payee      CHECK ((payee_account_name IS NULL) <> (payee_counterparty_id IS NULL)),
  CONSTRAINT own_record        CHECK ((payer_account_name IS NOT NULL) OR (payee_account_name IS NOT NULL)),
  CONSTRAINT different_account CHECK (COALESCE(payer_account_name, '\uffff') <> COALESCE(payee_account_name, '\ufffe'))
);
''');
              db.execute('''
CREATE TABLE fragments (
  id           INTEGER          PRIMARY KEY AUTOINCREMENT,
  record_id    INTEGER NOT NULL REFERENCES records(id)    ON DELETE CASCADE,
  category_id  INTEGER NOT NULL REFERENCES categories(id) ON DELETE RESTRICT,
  amount       REAL    NOT NULL
);
''');
            });

  @override
  Future<List<Record>> getter() async {
    final List<RecordFragment> fragments = await database
        .then((db) => db.query('fragments', orderBy: 'amount DESC'))
        .then((rows) => rows.map((map) => RecordFragment.fromMap(map)).toList());
    return database.then((db) => db.query('records', orderBy: 'time DESC, id DESC')).then((rows) => rows.map((map) {
          final Record record = Record.fromMap(map);
          record.fragments.addAll(fragments.where((fragment) => fragment.recordId == record.id));
          return record;
        }).toList());
  }

  @override
  Future<void> inserter(Record item) async {
    final db = await database;
    await db.insert('records', item.toMap());
    final int id = (await db.rawQuery('SELECT last_insert_rowid() AS id')).first['id'] as int;
    for (var fragment in item.fragments) {
      await db.insert('fragments', fragment.copyWith(recordId: id).toMap());
    }
  }

  @override
  Future<void> updater(Record oldItem, Record newItem) async {
    final db = await database;
    await db.update('records', newItem.toMap(), where: 'id=?', whereArgs: [oldItem.id]);
    if (oldItem.fragments.length == newItem.fragments.length) {
      for (var i = 0; i < oldItem.fragments.length; ++i) {
        await db.update('fragments', newItem.fragments[i].toMap(), where: 'id=?', whereArgs: [oldItem.fragments[i].id]);
      }
    } else {
      await db.delete('fragments', where: 'record_id=?', whereArgs: [oldItem.id]);
      for (var fragment in newItem.fragments) {
        await db.insert('fragments', fragment.copyWith(recordId: oldItem.id).toMap());
      }
    }
  }

  @override
  Future<void> deleter(Record item) =>
      database.then((db) async => await db.delete('records', where: 'id=?', whereArgs: [item.id]));

  Future<void> createTransaction(List<Record> records) async {
    final int transactionId = await database
        .then((db) => db.rawQuery('SELECT MAX(transaction_id) AS id FROM records'))
        .then((rows) => (rows.first['id'] as int? ?? 0) + 1);
    for (var record in records) {
      updater(record, record.withTransactionId(transactionId));
    }
    refresh();
  }
}
