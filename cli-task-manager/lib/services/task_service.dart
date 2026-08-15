import '../exceptions/task_exceptions.dart';
import '../models/priority.dart';
import '../models/standard_task.dart';
import '../models/task.dart';
import '../models/urgent_task.dart';
import '../repository/repository.dart';

enum SortMode { priority, deadline }

/// Orchestrates task operations on top of a [Repository<Task>].
/// Keeping this logic out of bin/main.dart means it's unit-testable
/// without touching argument parsing or stdout.
class TaskService {
  final Repository<Task> _repo;
  int _counter;

  TaskService(this._repo) : _counter = _repo.getAll().length;

  Task addTask({
    required String title,
    required Priority priority,
    DateTime? deadline,
    bool urgent = false,
  }) {
    final id = 't${++_counter}';
    final task = urgent
        ? UrgentTask(
            id: id,
            title: title,
            priority: priority,
            deadline: deadline ??
                (throw InvalidTaskException(
                    'an urgent task requires a deadline.')),
          )
        : StandardTask(
            id: id,
            title: title,
            priority: priority,
            deadline: deadline,
          );
    _repo.add(task);
    return task;
  }

  List<Task> listTasks({SortMode sortBy = SortMode.priority}) {
    final tasks = _repo.getAll().toList();
    switch (sortBy) {
      case SortMode.priority:
        // Descending: high first. Priority.index is low=0..high=2.
        tasks.sort((a, b) => b.priority.index.compareTo(a.priority.index));
        break;
      case SortMode.deadline:
        tasks.sort((a, b) {
          if (a.deadline == null && b.deadline == null) return 0;
          if (a.deadline == null) return 1; // no-deadline sorts last
          if (b.deadline == null) return -1;
          return a.deadline!.compareTo(b.deadline!);
        });
        break;
    }
    return tasks;
  }

  Task markDone(String id) {
    final task = _repo.findById(id);
    if (task == null) throw TaskNotFoundException(id);
    task.markDone();
    _repo.update(id, task);
    return task;
  }

  void deleteTask(String id) {
    final removed = _repo.delete(id);
    if (!removed) throw TaskNotFoundException(id);
  }
}
