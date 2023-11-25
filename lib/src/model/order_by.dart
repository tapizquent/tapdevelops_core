/// OrderBy class
///
/// This class is used to specify the field to order by and whether to order
class OrderBy {
  /// OrderBy constructor
  /// [field] is the field to order by
  /// [descending] is whether to order descending
  /// defaults to false
  OrderBy(this.field, {this.descending = false});

  /// field to order by
  final String field;

  /// whether to order descending
  final bool descending;
}
