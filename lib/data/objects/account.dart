import 'package:flutter/material.dart';

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

  Map<String, dynamic> toMap() =>
      {
        'name': name,
        'icon': icon.codePoint,
        'color': color.value,
        'initial_balance': initialBalance,
        'asset': asset ? 1 : 0,
      };

  Account clone() => Account(name, icon, color, initialBalance, asset);

  static const List<IconData> supportedIcons = [
    Icons.account_balance_wallet_outlined,
    Icons.payments_outlined,
    Icons.account_balance_outlined,
    Icons.payment_outlined,
    Icons.savings_outlined,
    Icons.paid_outlined,
    Icons.health_and_safety_outlined,
    Icons.hub_outlined,
    Icons.handshake_outlined,
    Icons.real_estate_agent_outlined,
    Icons.currency_exchange_outlined,
    Icons.category_outlined,
  ];
}
