import 'package:tapdevelops_core/src/model/idatabase_entiry.dart';
import 'package:tapdevelops_core/src/model/order_by.dart';
import 'package:tapdevelops_core/src/model/query_arg.dart';

/// ItemFilter
///
/// This is a function that takes an item and returns a bool.
/// It is used to filter items on the client side.
typedef ItemFilter<T> = bool Function(T);

/// ItemComparer
///
/// This is a function that takes two items and returns an int.
/// It is used to compare items on the client side.
typedef ItemComparer<T> = int Function(T item1, T item2);

/// IBaseRepository
///
/// This is the base repository interface.
abstract class IBaseRepository<T extends IDatabaseEntity> {
  /// Gets one item from the repository as a stream.
  Stream<T?> getOne({
    List<QueryArg> args,
    List<OrderBy> orderBy,
  });

  /// Gets one item from the repository by id as a stream.
  Stream<T?> getById({required String id});

  /// Gets all items from the repository as a stream.
  Stream<List<T>> getAll({
    List<QueryArg> args,
    List<OrderBy> orderBy,
    List<ItemFilter<T>> clientSideFilters,
    ItemComparer<T> orderComparer,
    int limit,
  });

  /// Inserts an item into the repository.
  Future<void> insert({required T item});

  /// Inserts many items into the repository.
  Future<void> insertMany({required List<T> items});

  /// Updates an item in the repository.
  Future<void> update({required T item});

  /// Updates many items in the repository.
  Future<void> updateMany({required List<T> items});

  /// Deletes an item from the repository.
  Future<void> delete({required String id});
}
