import 'package:flutter/widgets.dart';

class Account {
  final String name;
  final IconData icon;
  final Color color;
  final double initialBalance;
  final bool asset;

  const Account(this.name, this.icon, this.color, this.initialBalance, this.asset);

  Account.fromMap(Map<String, dynamic> map)
      : name = map['name'],
        icon = IconData(map['icon'], fontFamily: 'MaterialIcons'),
        color = Color(map['color']),
        initialBalance = map['initial_balance'],
        asset = map['asset'] > 0;

  Map<String, dynamic> toMap() => {
        'name': name,
        'icon': icon.codePoint,
        'color': color.value,
        'initial_balance': initialBalance,
        'asset': asset ? 1 : 0,
      };

  Account clone() => Account(name, icon, color, initialBalance, asset);
}
