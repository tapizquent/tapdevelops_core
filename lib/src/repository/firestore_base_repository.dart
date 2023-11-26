import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:meta/meta.dart';
import 'package:quiver/time.dart';
import 'package:tapdevelops_core/src/core/from_json_factory.dart';
import 'package:tapdevelops_core/src/core/is_null_or_empty.dart';
import 'package:tapdevelops_core/src/model/idatabase_entiry.dart';
import 'package:tapdevelops_core/src/model/order_by.dart';
import 'package:tapdevelops_core/src/model/query_arg.dart';
import 'package:tapdevelops_core/src/repository/ibase_repository.dart';

/// When implementing this BaseRepository, the Entity needs to be registered
/// inside the fromJsonFactory map and returning the .fromJson for that entity,
/// otherwise the app will go into an infinite loop.
abstract class FirestoreBaseRepository<T extends IDatabaseEntity>
    implements IBaseRepository<T> {
  /// The FirestoreBaseRepository constructor.
  /// [collectionType] : The type of the collection. This is used to determine
  /// the path to the collection in the database.
  /// [clock] : The clock used to get the current time.
  /// [firestore] : The firestore instance to use. Defaults to the instance
  /// registered in the `DependencyInjectionManager`.
  FirestoreBaseRepository({
    Type? collectionType,
    Clock? clock,
    FirebaseFirestore? firestore,
  })  : clock = clock ?? const Clock(),
        firestore = firestore ?? GetIt.I.get<FirebaseFirestore>() {
    collection = this.firestore.collection(
          collectionType != null ? collectionType.toString() : T.toString(),
        );
  }

  /// Do NOT override or set this field. This should only be modified by
  /// BaseInnerCollection to allow access to subCollections.
  /// If you are extending this class, you should be able to use every method
  /// without ever touching this field.
  @protected
  late CollectionReference collection;

  /// Do NOT override or set this field. This should only be modified by
  /// BaseInnerCollection to allow access to subCollections.
  /// If you are extending this class, you should be able to use every method
  /// without ever touching this field.
  @protected
  final FirebaseFirestore firestore;

  /// The path to the collection in the database.
  String get path => collection.path;

  /// The clock used to get the current time.
  late Clock clock;

  /// [args] : arguments to filter documents by. This appends the filter to the
  /// query and retrieves documents where arguments match. Executed on the
  /// server.
  ///
  /// [orderBy] : orderBy filter. Returns documents ordered by the field
  /// specified.
  ///
  /// `GUID`s need to be provided as `GUID.toString().`
  /// `DateTime`s need to be provided as `DateTime.toIso8601String()`
  ///
  /// NOTE: If args is not provided, orderBy must be provided, and vice versa.
  @override
  Stream<T?> getOne({
    List<QueryArg>? args,
    List<OrderBy>? orderBy,
  }) {
    if (isNullOrEmpty(orderBy)) {
      assert(
        !isNullOrEmpty(args),
        'To get one item, `args` needs to be provided when `orderBy` is not',
      );
    }

    if (isNullOrEmpty(args)) {
      assert(
        !isNullOrEmpty(orderBy),
        'To get one item, `orderBy` needs to be provided when `args` is not',
      );
    }

    final query = _buildQuery(
      collection: collection,
      args: args,
      orderBy: orderBy,
      limit: 1,
    );

    return _getSingleFromQuery(
      query: query,
      mapper: (DocumentSnapshot document) {
        final data = document.data();
        if (data == null || data is! Map<String, dynamic>) return null;

        return getFromJsonFactory(T, document.data()! as Map<String, dynamic>)
            as T?;
      },
    );
  }

  @override
  Stream<T?> getById({required String id}) {
    return collection.doc(id).snapshots().map((snapShot) {
      if (!snapShot.exists) return null;
      return getFromJsonFactory(T, snapShot.data()! as Map<String, dynamic>);
    });
  }

  /// [args] : optional arguments to filter documents by. This appends the
  /// filter to the query and retrieves documents where arguments match.
  /// Executed on the server.
  ///
  /// [orderBy] : optional orderBy filter. Returns documents ordered by the
  /// field specified.
  ///
  /// `GUIDs` need to be provided as `GUID.toString().`
  /// `DateTime`s need to be provided as `DateTime.toIso8601String()`
  ///
  /// [clientSideFilters] : optional list of filter functions that execute a
  /// `.where()` on the result on the client side
  ///
  /// ex: `clientSidefilters: (event) => event.startTime > DateTime.now()`
  ///
  /// [orderComparer] : optional comparisson function. If provided your
  /// resulting data will be sorted based on it on the client
  ///
  /// ex: `orderComparer: (event1, event2) =>
  /// event1.name.compareTo(event2.name)`
  @override
  Stream<List<T>> getAll({
    List<QueryArg>? args,
    List<OrderBy>? orderBy,
    List<ItemFilter<T>>? clientSideFilters,
    ItemComparer<T>? orderComparer,
    int? limit,
  }) {
    final query = _buildQuery(
      collection: collection,
      args: args,
      orderBy: orderBy,
      limit: limit,
    );
    return _getListFromQuery(
      query: query,
      mapper: (DocumentSnapshot document) =>
          getFromJsonFactory(T, document.data()! as Map<String, dynamic>),
      clientSideFilters: clientSideFilters,
      orderComparer: orderComparer,
    );
  }

  /// If the document does not yet exist, it will be created.
  /// Otherwise, the document will be overwritten with the new item data
  @override
  Future<void> insert({required T item}) {
    final toInsert = _prepareItemForInsertion(item);
    return collection.doc(toInsert.id.toString()).set(toInsert.toJson());
  }

  /// If the documents do not yet exist, they will be created.
  /// Otherwise, the documents will be overwritten with the new items data
  @override
  Future<void> insertMany({required List<T> items}) {
    final batch = firestore.batch();
    for (final item in items) {
      final toInsert = _prepareItemForInsertion(item);
      final document = collection.doc(toInsert.id.toString());
      batch.set(document, toInsert.toJson());
    }
    return batch.commit();
  }

  @override
  Future<void> update({required T item}) {
    final toUpdate = _prepareItemForUpdate(item);
    return collection.doc(toUpdate.id.toString()).update(toUpdate.toJson());
  }

  @override
  Future<void> updateMany({required List<T> items}) {
    final batch = firestore.batch();
    for (final item in items) {
      final toUpdate = _prepareItemForUpdate(item);
      final document = collection.doc(toUpdate.id.toString());
      batch.update(document, toUpdate.toJson());
    }
    return batch.commit();
  }

  @override
  Future<void> delete({required String id}) {
    return collection.doc(id).delete();
  }

  IDatabaseEntity _prepareItemForInsertion(T item) {
    final now = clock.now().toUtc();
    return item.copyWith(createdAt: now, updatedAt: now);
  }

  IDatabaseEntity _prepareItemForUpdate(T item) {
    return item.copyWith(updatedAt: clock.now().toUtc());
  }
}

Query _buildQuery({
  required Query collection,
  List<QueryArg>? args,
  List<OrderBy>? orderBy,
  int? limit,
}) {
  var ref = collection;

  if (args != null) {
    for (final arg in args) {
      if (arg.isEqualTo != null) {
        ref = ref.where(arg.field, isEqualTo: arg.isEqualTo);
      }
      if (arg.isGreaterThan != null) {
        ref = ref.where(arg.field, isGreaterThan: arg.isGreaterThan);
      }
      if (arg.isGreaterThanOrEqualTo != null) {
        ref = ref.where(
          arg.field,
          isGreaterThanOrEqualTo: arg.isGreaterThanOrEqualTo,
        );
      }
      if (arg.isLessThan != null) {
        ref = ref.where(arg.field, isLessThan: arg.isLessThan);
      }
      if (arg.isLessThanOrEqualTo != null) {
        ref =
            ref.where(arg.field, isLessThanOrEqualTo: arg.isLessThanOrEqualTo);
      }
      if (arg.isNull != null) {
        ref = ref.where(arg.field, isNull: arg.isNull);
      }
      if (arg.arrayContains != null) {
        ref = ref.where(arg.field, arrayContains: arg.arrayContains);
      }
    }
  }
  if (orderBy != null) {
    for (final order in orderBy) {
      ref = ref.orderBy(order.field, descending: order.descending);
    }
  }

  if (limit != null) {
    ref = ref.limit(limit);
  }

  return ref;
}

/// DocumentMapper
/// This is a function that takes a document and returns an object.
typedef DocumentMapper<T extends IDatabaseEntity?> = T Function(
  DocumentSnapshot document,
);

///
/// Convenience Method to access the data of a Query as a stream while applying
/// a mapping function on each document with optional client side filtering and
/// sorting
///
/// [query] : the data source
///
/// [mapper] : mapping function that gets applied to every document in the
/// query.
/// Typically used to deserialize the Map returned from FireStore
///
/// [clientSideFilters] : optional list of filter functions that execute a
/// `.where()`
/// on the result on the client side
///
/// [orderComparer] : optional comparisson function. If provided your resulting
/// data will be sorted based on it on the client
Stream<List<T>> _getListFromQuery<T extends IDatabaseEntity>({
  required Query query,
  required DocumentMapper<T> mapper,
  List<ItemFilter<T>>? clientSideFilters,
  ItemComparer<T>? orderComparer,
}) {
  return query.snapshots().map((snapShot) {
    var items = snapShot.docs.map(mapper);

    if (clientSideFilters != null) {
      for (final filter in clientSideFilters) {
        items = items.where(filter);
      }
    }

    final asList = items.toList();
    if (orderComparer != null) {
      asList.sort(orderComparer);
    }

    return asList;
  });
}

Stream<T?> _getSingleFromQuery<T extends IDatabaseEntity?>({
  required Query query,
  required DocumentMapper<T?> mapper,
}) {
  return query.snapshots().map((snapShot) {
    if (snapShot.docs.isEmpty) return null;
    return mapper(snapShot.docs.single);
  });
}
