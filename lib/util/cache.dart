import 'dart:collection';
import 'package:aurum/util/extensions.dart';

class _CacheKey {
  final List<dynamic> key;

  _CacheKey(this.key);

  @override
  bool operator ==(Object other) {
    if (other is _CacheKey) return key.equalsDeep(other.key);
    return false;
  }

  @override
  int get hashCode => key.hashCodeDeep();
}

class GlobalCache {
  static final Map<_CacheKey, dynamic> _cache = HashMap();

  GlobalCache._();

  static T getOrPut<T>(List<dynamic> key, T Function() ifAbsent) => _cache[_CacheKey(key)] ??= ifAbsent();

  // {
  //   print('getOrPut: ${_CacheKey(key).key}');
  //   return _cache[_CacheKey(key)] ??= () {
  //     print('Cache miss, creating entry...');
  //     return ifAbsent();
  //   }();
  // }

  static void invalidate(List<dynamic> key) => _cache.remove(_CacheKey(key));
}
