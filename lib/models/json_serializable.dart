/// Contract for anything that can be turned into a JSON-compatible map.
///
/// Dart has no `interface` keyword — any class body can serve as an
/// interface when another class uses `implements` on it instead of
/// `extends`. That's what [Task] does below, satisfying the "implement
/// at least one interface" requirement independently of the Task
/// inheritance hierarchy.
abstract class JsonSerializable {
  Map<String, dynamic> toJson();
}
