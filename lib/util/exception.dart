class AurumException implements Exception {
  final String message;

  AurumException(this.message);

  @override
  String toString() => message;
}
