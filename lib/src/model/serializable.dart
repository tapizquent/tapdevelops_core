// ignore_for_file: one_member_abstracts
/// Classes that implement serializable must also have a factory constructor
/// `Class.fromJson(Map<String, Object?> json)`;
abstract class Serializable {
  /// Returns a json representation of the current object. Json is represented
  /// in the application as a [Map<String, Object>]
  Map<String, Object?> toJson();
}
