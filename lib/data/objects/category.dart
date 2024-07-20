import 'package:flutter/material.dart';

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

  static const List<IconData> supportedIcons = [
    Icons.bakery_dining_outlined,
    Icons.ramen_dining_outlined,
    Icons.cookie_outlined,
    Icons.coffee_outlined,
    Icons.emoji_food_beverage_outlined,
    Icons.shopping_bag_outlined,
    Icons.shopping_cart_outlined,
    Icons.shopping_cart_checkout_outlined,
    Icons.cottage_outlined,
    Icons.electric_bolt_outlined,
    Icons.devices_outlined,
    Icons.chair_outlined,
    Icons.propane_tank_outlined,
    Icons.handyman_outlined,
    Icons.emoji_transportation_outlined,
    Icons.directions_bus_outlined,
    Icons.local_taxi_outlined,
    Icons.electric_scooter_outlined,
    Icons.spa_outlined,
    Icons.medical_services_outlined,
    Icons.card_giftcard_outlined,
    Icons.attractions_outlined,
    Icons.school_outlined,
    Icons.attach_money_outlined,
    Icons.currency_exchange_outlined,
    Icons.assured_workload_outlined,
    Icons.percent_outlined,
    Icons.compare_arrows_outlined,
    Icons.language_outlined,
    Icons.cable_outlined,
    Icons.more_horiz_outlined,
  ];
}
