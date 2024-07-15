class Comparator<E> {
  int Function(E, E) _compare;

  Comparator(int Function(E, E) compare) : _compare = compare;

  Comparator<E> then(int Function(E, E) compare) {
    final parent = _compare;
    _compare = (a, b) {
      final int result = parent(a, b);
      return result == 0 ? compare(a, b) : result;
    };
    return this;
  }

  int call(E a, E b) => _compare(a, b);

  int compare(E a, E b) => _compare(a, b);
}
