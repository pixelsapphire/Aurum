class Pointer<T> {
  T? _value;

  Pointer(T this._value);

  Pointer.nullable(this._value);

  Pointer.nullptr() : _value = null;

  set value(T value) => this._value = value;

  T get value => _value!;

  dynamic valueOr<R>(R fallback) => _value ?? fallback;

  void clear() => _value = null;

  bool get isNull => _value == null;
}
