import 'package:tapdevelops_core/src/core/dependency_injection_manager.dart';

/// Extension methods for [Object].
///
/// This extension adds a `resolve` method to [Object] that allows for
/// resolving dependencies from the `DependencyInjectionManager`.
extension ResolvableObject on Object? {
  /// Returns the resolved value from `DependencyInjectionManager`
  /// if `this` is null, or `this` if it is not null
  T resolve<T extends Object>() {
    return this as T? ?? DependencyInjectionManager.resolve<T>();
  }
}
