import 'package:flutter/widgets.dart';

class Category {
  // id is nullable because it's not known when a new category is created and is only assigned by the database when inserted
  final int? id, parentId;
  final String name;
  final IconData icon;
  final Color color;
  final bool analyzed;

  const Category(this.id, this.parentId, this.name, this.icon, this.color, this.analyzed);

  Category.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        parentId = map['parent_id'],
        name = map['name'],
        icon = IconData(map['icon'], fontFamily: 'MaterialIcons'),
        color = Color(map['color']),
        analyzed = map['analyzed'] == 1;

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'parent_id': parentId,
        'name': name,
        'icon': icon.codePoint,
        'color': color.value,
        'analyzed': analyzed ? 1 : 0,
      };

  bool get isInfraCategory => parentId == null;
}
