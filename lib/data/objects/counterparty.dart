import 'package:flutter/material.dart';

enum CounterpartyType {
  private(Icons.person_outlined),
  company(Icons.business_outlined),
  franchise(Icons.store_outlined),
  other(Icons.grid_view_outlined);

  final IconData icon;

  const CounterpartyType(this.icon);

  static CounterpartyType valueOf(String name) => values.firstWhere((type) => type.name == name);
}

class Counterparty {
  // id is nullable because it's not known when a new counterparty is created and is only assigned by the database when inserted
  final int? id;
  final CounterpartyType type;
  final String name;
  final String? alias, identification;

  Counterparty(this.id, this.type, this.name, this.alias, this.identification);

  String get aliasOrName => alias ?? name;

  Counterparty.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        type = CounterpartyType.valueOf(map['type']),
        name = map['name'],
        alias = map['alias'],
        identification = map['identification'];

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'type': type.name,
        'name': name,
        'alias': alias,
        'identification': identification,
      };
}
