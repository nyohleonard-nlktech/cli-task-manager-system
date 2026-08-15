/// Generic CRUD contract. `T` is deliberately unconstrained here so this
/// type could back a repository for any entity, not just [Task] — the
/// task-specific pieces (JSON encode/decode, id extraction) live in
/// [JsonTaskRepository], which supplies `T = Task`.
abstract class Repository<T> {
  List<T> getAll();
  T? findById(String id);
  void add(T item);

  /// Returns true if an item with the given id was found and replaced.
  bool update(String id, T item);

  /// Returns true if an item with the given id was found and removed.
  bool delete(String id);
}
