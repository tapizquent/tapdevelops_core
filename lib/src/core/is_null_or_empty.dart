/// Checks if the given object is null or empty.
bool isNullOrEmpty(dynamic obj) {
  // Check for null
  if (obj == null) return true;

  // Check for and cast to String, List, or Map, then check if they are empty
  if (obj is String) return obj.isEmpty;
  if (obj is List) return obj.isEmpty;
  if (obj is Map) return obj.isEmpty;

  // Return false for all other types
  return false;
}
