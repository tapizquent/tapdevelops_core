import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';

/// Dependency Injection Manager allows for registration and resolving of
/// dependencies at a global level.
///
/// You can, and should, simply call the manager to register or resolve types
/// by calling the `DependencyInjectionManager` static methods.
///
/// ```
/// DependencyInjectionManager.registerType<IMyInterface>(MyImplementedClass);
/// IMyInterface myObject = DependencyInjectionManager.Resolve();
/// ```
class DependencyInjectionManager {
  DependencyInjectionManager._();

  /// A map of all registered types.
  static Map<Type, dynamic> registeredTypes = {};

  /// Registers a type to be resolved later.
  static void init() {
    registerSingleton<FirebaseFirestore>(FirebaseFirestore.instance);
  }

  /// Registers a type to be resolved later.
  static void registerSingleton<T extends Object>(T instance) {
    GetIt.I.registerSingleton<T>(instance);
  }

  /// Registers a factory to be resolved later.
  static void registerFactory<T extends Object>(T Function() factoryFunc) {
    GetIt.I.registerFactory<T>(factoryFunc);
  }

  /// Resolves an object from the registered types.
  static T resolve<T extends Object>() {
    return GetIt.I.get<T>();
  }

  /// Checks if a type is registered.
  static bool isRegistered<T>() {
    return registeredTypes.containsKey(T);
  }

  /// Clears all registered types.
  static void clear() {
    registeredTypes.clear();
    GetIt.I.reset();
  }
}
