import 'package:tapdevelops_core/src/model/idatabase_entiry.dart';

/// JsonFactoryFunc
///
/// This is a function that takes a json map and returns an object.
typedef JsonFactoryFunc<T extends IDatabaseEntity> = T Function(
  Map<String, dynamic> json,
);

final Map<Type, JsonFactoryFunc> _fromJsonFactory = {};

/// Adds a factory to the map
void addFromJsonFactory<T extends IDatabaseEntity>(
  Type type,
  T Function(Map<String, Object?>) factoryFunction,
) {
  _fromJsonFactory[type] = factoryFunction;
}

/// Gets a factory from the map
T getFromJsonFactory<T extends IDatabaseEntity?>(
  Type type,
  Map<String, Object?> json,
) {
  final factoryFunction = _fromJsonFactory[type];
  if (factoryFunction != null) {
    return factoryFunction(json) as T;
  }
  throw Exception(
    'The type $type is not registered inside the _fromJsonFactory',
  );
}
