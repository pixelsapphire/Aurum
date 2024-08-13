import 'dart:async';
import 'dart:collection';
import 'dart:math' as math;
import 'package:diacritic/diacritic.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

extension NavigatorExt on NavigatorState {
  void popMany(int times) {
    for (var i = 0; i < times; ++i) {
      pop();
    }
  }
}

extension RenderBoxExt on RenderBox {
  Rect get topRight => localToGlobal(Offset(0, -size.height)) & size;

  Rect get bottomRight => localToGlobal(Offset.zero) & size;
}

extension GlobalKeyExt on GlobalKey {
  RenderBox get renderBox => currentContext?.findRenderObject() as RenderBox;
}

extension ColorExt on Color {
  Color withValue(double value) => HSVColor.fromColor(this).withValue(value).toColor();

  double getValue() => HSVColor.fromColor(this).value;
}

extension IterableExt<E> on Iterable<E> {
  Iterable<E>? nullIfEmpty() => isEmpty ? null : this;

  Iterable<E> skipLast(int count) => take(length - count);

  Iterable<E> skipToLength(int length) => skip(math.max(0, this.length - length));

  Iterable<E> sorted([int Function(E, E)? compare]) => toList()..sort(compare);

  Iterable<E> whereIndex(bool Function(int) predicate) {
    var index = 0;
    return where((element) => predicate(index++));
  }

  E min([Comparable Function(E)? key]) =>
      reduce((a, b) => (key != null ? key(a).compareTo(key(b)) : (a as Comparable).compareTo(b)) < 0 ? a : b);

  E max([Comparable Function(E)? key]) =>
      reduce((a, b) => (key != null ? key(a).compareTo(key(b)) : (a as Comparable).compareTo(b)) > 0 ? a : b);

  bool none(bool Function(E) predicate) => !any(predicate);

  Iterable<E> whereNot(bool Function(E) predicate) => where((element) => !predicate(element));

  bool everyIndexed(bool Function(E, int) predicate) {
    var index = 0;
    for (var element in this) {
      if (!predicate(element, index++)) return false;
    }
    return true;
  }

  bool anyIndexed(bool Function(E, int) predicate) {
    var index = 0;
    for (var element in this) {
      if (predicate(element, index++)) return true;
    }
    return false;
  }

  Map<E, V> toMap<V>(V Function(E) mapper) => Map.fromEntries(map((key) => MapEntry(key, mapper(key))));

  String toMultilineString({String Function(E)? mapper}) =>
      '[\n${map((element) => '  ${mapper?.call(element) ?? element}').join('\n')}\n]';

  bool equalsDeep(Iterable<E> other) {
    if (identical(this, other)) return true;
    if (length != other.length) return false;
    return everyIndexed((element, index) => element == other.elementAt(index));
  }

  int hashCodeDeep() {
    return fold(0, (hash, element) => hash ^ element.hashCode);
  }
}

extension ListExt<E> on List<E> {
  void insertBetween(E Function() supplier) {
    for (var i = 1; i < length; i += 2) {
      insert(i, supplier());
    }
  }
}

extension MapExt<K, V> on Map<K, V> {
  Map<K, V> where(bool Function(K, V) predicate) => Map.fromEntries(entries.where((e) => predicate(e.key, e.value)));

  Map<K, V> whereKey(bool Function(K) predicate) => Map.fromEntries(entries.where((e) => predicate(e.key)));

  Map<K, V> whereValue(bool Function(V) predicate) => Map.fromEntries(entries.where((e) => predicate(e.value)));

  String toMultilineString({String Function(K)? keyMapper, String Function(V)? valueMapper}) =>
      '{\n${entries.map((entry) => '  ${keyMapper?.call(entry.key) ?? entry.key}: ${valueMapper?.call(entry.value) ?? entry.value}').join('\n')}\n}';
}

extension LinkedHashMapExt on LinkedHashMap {
  void removeAt(int index) => remove(keys.elementAt(index));
}

extension FutureOrExt<T> on FutureOr<T> {
  FutureOr<R> map<R>(R Function(T) f) => this is Future<T> ? (this as Future<T>).then(f) : f(this as T);
}

extension DateTimeExt on DateTime {
  String toFullString() => DateFormat('yyyy-MM-dd @ hh:mm a').format(this);

  String toDateString() => DateFormat('yyyy-MM-dd').format(this);

  DateTime get date => DateTime(year, month, day);

  DateTime get previousDay => subtract(const Duration(days: 1));

  DateTime get previousWeek => subtract(const Duration(days: 7));

  DateTime get previousMonth => DateTime(year, month - 1, day);

  DateTime get nextDay => add(const Duration(days: 1));

  bool operator >(DateTime other) => isAfter(other);

  bool operator <(DateTime other) => isBefore(other);

  bool operator <=(DateTime other) => !isAfter(other);

  bool operator >=(DateTime other) => !isBefore(other);
}

extension StringExt on String {
  String? nullIfEmpty() => isEmpty ? null : this;

  String capitalize() => isNotEmpty ? '${this[0].toUpperCase()}${substring(1)}' : '';

  String insertAtIndex(int index, String value) => substring(0, index) + value + substring(index);

  int compareLexicographically(String other) {
    for (int i = 0; i < math.min(length, other.length); ++i) {
      if (this[i] == other[i]) continue;
      String charA = this[i].toLowerCase(), charB = other[i].toLowerCase();
      String clearCharA = removeDiacritics(charA), clearCharB = removeDiacritics(charB);
      clearCharA = clearCharA.length == 1 ? clearCharA + charA : charA;
      clearCharB = clearCharB.length == 1 ? clearCharB + charB : charB;
      return clearCharA.compareTo(clearCharB);
    }
    return length.compareTo(other.length);
  }
}

extension NumberExt on num {
  double roundToPlaces(int decimalPlaces) => (this * math.pow(10, decimalPlaces)).roundToDouble() / math.pow(10, decimalPlaces);

  bool get isPositive => this > 0;

  String asPercent([int decimalPlaces = 0]) => '${(this * 100).roundToPlaces(decimalPlaces)}%';
}

extension ObjectExt<T> on T {
  R op<R>(R Function(T) f) => f(this);

  T opIf(bool condition, T Function(T) f) => condition ? f(this) : this;
}
