Map<String, dynamic> convertLinkedMapToMap(Map<Object?, Object?> input) {
  final Map<String, dynamic> output = {};

  input.forEach((key, value) {
    if (key == null) return; // Skip null keys
    final keyString = key.toString();

    if (value is Map<Object?, Object?>) {
      output[keyString] = convertLinkedMapToMap(value);
    } else if (value is List) {
      output[keyString] = value.map((e) {
        if (e is Map<Object?, Object?>) {
          return convertLinkedMapToMap(e);
        }
        return e;
      }).toList();
    } else {
      output[keyString] = value;
    }
  });

  return output;
}
