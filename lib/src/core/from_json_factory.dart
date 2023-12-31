import 'package:tapdevelops_core/src/model/idatabase_entity.dart';

/// JsonFactoryFunc
///
/// This is a function that takes a json map and returns an object.
typedef JsonFactoryFunc<T extends IDatabaseEntity> = T Function(
  Map<String, dynamic> json,
);

final Map<Type, JsonFactoryFunc> _fromJsonFactory = {};
final Map<Type, String> _collectionName = {};

/// Adds a factory to the map
void addFromJsonFactory<T extends IDatabaseEntity>(
  String collectionName,
  T Function(Map<String, Object?>) factoryFunction,
) {
  _fromJsonFactory[T] = factoryFunction;
  _collectionName[T] = collectionName;
}

/// Gets a collection name from the map
String getCollectionName<T extends IDatabaseEntity>() {
  final collectionName = _collectionName[T];
  if (collectionName != null) {
    return collectionName;
  }
  throw Exception(
    'The type $T is not registered inside the _collectionName',
  );
}

/// Gets a factory from the map
T getFromJsonFactory<T extends IDatabaseEntity?>(
  Map<String, Object?> json,
) {
  final factoryFunction = _fromJsonFactory[T];
  if (factoryFunction != null) {
    return factoryFunction(json) as T;
  }
  throw Exception(
    'The type $T is not registered inside the _fromJsonFactory',
  );
}
