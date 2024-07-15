import 'package:aurum/data/database.dart';
import 'package:aurum/data/objects/category.dart';
import 'package:aurum/util/exception.dart';

class CategoriesCollection extends AurumCollection<Category> {
  CategoriesCollection({required super.database}) : super(tables: ['categories'], creator: (db) => db.execute('''
CREATE TABLE categories (
  id        INTEGER          PRIMARY KEY AUTOINCREMENT,
  parent_id INTEGER,
  name      TEXT    NOT NULL,
  icon      INTEGER NOT NULL,
  color     INTEGER NOT NULL,
  analyzed  BOOLEAN           DEFAULT TRUE
);
'''));

  @override
  Future<List<Category>> getter() =>
      database.then((db) => db.query('categories')).then((rows) => rows.map((map) => Category.fromMap(map)).toList());

  @override
  Future<void> inserter(Category item) => database.then((db) => db.insert('categories', item.toMap()));

  @override
  Future<void> updater(Category oldItem, Category newItem) =>
      database.then((db) => db.update('categories', newItem.toMap(), where: 'id=?', whereArgs: [oldItem.id]));

  @override
  Future<void> deleter(Category item) => database.then((db) async {
        if ((await _getChildren(item)).isNotEmpty) throw AurumException('Cannot delete a category with subcategories.');
        db.delete('categories', where: 'id=?', whereArgs: [item.id]);
      });

  Future<List<Category>> _getChildren(Category category) => database
      .then((db) => db.query('categories', where: 'parent_id=?', whereArgs: [category.id]))
      .then((rows) => rows.map((map) => Category.fromMap(map)).toList());

  Future<Category> getById(int id) => database
      .then((db) => db.query('categories', where: 'id=?', whereArgs: [id]))
      .then((rows) => Category.fromMap(rows.single));
}
