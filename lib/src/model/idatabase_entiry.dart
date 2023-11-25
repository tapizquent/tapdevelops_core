import 'package:equatable/equatable.dart';
import 'package:guid/guid.dart';

import 'package:tapdevelops_core/src/model/serializable.dart';

/// Base class for all items that are written to the database.
///
/// When implementing this class, a `IDatabaseEntity.fromJson` factory
/// constructor should also be added. FromJson will be used to read from
/// documents from the database
abstract class IDatabaseEntity extends Equatable implements Serializable {
  /// Creates a new instance of [IDatabaseEntity].
  GUID get id;

  /// The date and time the document was created.
  DateTime get createdAt;

  /// The date and time the document was last updated.
  DateTime get updatedAt;

  @override
  Map<String, Object?> toJson();

  /// Returns the current [IDatabaseEntity] with the updated values passed.
  /// All other fields are kept the same.
  IDatabaseEntity copyWith({DateTime? createdAt, DateTime? updatedAt});
}
