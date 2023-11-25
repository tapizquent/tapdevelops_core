import 'package:equatable/equatable.dart';

/// A class that represents a query argument.
class QueryArg extends Equatable {
  /// Creates a new instance of [QueryArg].
  ///
  /// [field] is the field to query.
  /// [isEqualTo] is the value to compare if the field is equal to.
  /// [isLessThan] is the value to compare if the field is less than.
  /// [isLessThanOrEqualTo] is the value to compare if the field is less than
  /// or equal to.
  /// [isGreaterThan] is the value to compare if the field is greater than.
  /// [isGreaterThanOrEqualTo] is the value to compare if the field is greater
  /// than or equal to.
  /// [isNull] is the value to compare if the field is null.
  /// [whereIn] is the value to compare if the field is in.
  /// [arrayContainsAny] is the value to compare if the field contains any.
  /// [arrayContains] is the value to compare if the field contains.
  const QueryArg(
    this.field, {
    this.isEqualTo,
    this.isLessThan,
    this.isLessThanOrEqualTo,
    this.isGreaterThan,
    this.isGreaterThanOrEqualTo,
    this.isNull,
    this.whereIn,
    this.arrayContainsAny,
    this.arrayContains,
  });

  /// The field to query.
  final Object field;

  /// Value to compare if the field is equal to.
  final Object? isEqualTo;

  /// Value to compare if the field is less than.
  final Object? isLessThan;

  /// Value to compare if the field is less than or equal to.
  final Object? isLessThanOrEqualTo;

  /// Value to compare if the field is greater than.
  final Object? isGreaterThan;

  /// Value to compare if the field is greater than or equal to.
  final Object? isGreaterThanOrEqualTo;

  /// Value to compare if the field contains.
  final Object? arrayContains;

  /// Value to compare if the field contains any.
  final List<Object>? arrayContainsAny;

  /// Value to compare if the field is in.
  final List<Object>? whereIn;

  /// Value to compare if the field is null.
  final bool? isNull;

  @override
  List<Object?> get props => [
        field,
        isEqualTo,
        isLessThan,
        isLessThanOrEqualTo,
        isGreaterThan,
        isGreaterThanOrEqualTo,
        isNull,
        whereIn,
        arrayContainsAny,
        arrayContains,
      ];
}
