import 'dart:convert';
import 'dart:io';

import '../exceptions/task_exceptions.dart';
import '../models/task.dart';
import 'repository.dart';

/// A [Repository] of [Task] backed by a local JSON file.
///
/// Every mutating call ([add], [update], [delete]) writes the full
/// in-memory list back to disk immediately, so the file on disk is
/// always consistent with what the CLI reports — there is no separate
/// "save" step to forget.
class JsonTaskRepository implements Repository<Task> {
  final File _file;
  List<Task> _cache;

  JsonTaskRepository(String path)
      : _file = File(path),
        _cache = [] {
    _cache = _load();
  }

  List<Task> _load() {
    if (!_file.existsSync()) return [];
    try {
      final raw = _file.readAsStringSync();
      if (raw.trim().isEmpty) return [];
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((e) => Task.fromJson(e as Map<String, dynamic>))
          .toList();
    } on FormatException catch (e) {
      throw TaskPersistenceException('corrupted store at ${_file.path}: ${e.message}');
    } on FileSystemException catch (e) {
      throw TaskPersistenceException('cannot read ${_file.path}: ${e.message}');
    }
  }

  void _persist() {
    try {
      final encoded = jsonEncode(_cache.map((t) => t.toJson()).toList());
      _file.writeAsStringSync(encoded);
    } on FileSystemException catch (e) {
      throw TaskPersistenceException('cannot write ${_file.path}: ${e.message}');
    }
  }

  @override
  List<Task> getAll() => List.unmodifiable(_cache);

  @override
  Task? findById(String id) {
    for (final t in _cache) {
      if (t.id == id) return t;
    }
    return null;
  }

  @override
  void add(Task item) {
    _cache.add(item);
    _persist();
  }

  @override
  bool update(String id, Task item) {
    final index = _cache.indexWhere((t) => t.id == id);
    if (index == -1) return false;
    _cache[index] = item;
    _persist();
    return true;
  }

  @override
  bool delete(String id) {
    final removed = _cache.length;
    _cache.removeWhere((t) => t.id == id);
    final changed = _cache.length != removed;
    if (changed) _persist();
    return changed;
  }
}
