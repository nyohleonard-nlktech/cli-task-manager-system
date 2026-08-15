import '../exceptions/task_exceptions.dart';
import '../models/priority.dart';
import '../services/task_service.dart';

/// Parses argv and dispatches to [TaskService]. Kept separate from
/// bin/main.dart so it can be unit tested without spawning a process.
class CliRunner {
  final TaskService service;

  CliRunner(this.service);

  /// Returns the text that would be printed to stdout. Throwing
  /// [AppException]s propagate to the caller (bin/main.dart), which is
  /// where they're formatted into user-facing error output.
  String run(List<String> args) {
    if (args.isEmpty) return _usage();

    final command = args.first;
    final rest = args.skip(1).toList();

    switch (command) {
      case 'add':
        return _handleAdd(rest);
      case 'list':
        return _handleList(rest);
      case 'done':
        return _handleDone(rest);
      case 'delete':
        return _handleDelete(rest);
      case 'help':
      case '--help':
      case '-h':
        return _usage();
      default:
        throw InvalidTaskException('unknown command "$command". Run "help" for usage.');
    }
  }

  String _handleAdd(List<String> args) {
    if (args.isEmpty) {
      throw InvalidTaskException('add requires a title, e.g. add "Buy milk" --priority high');
    }
    final title = args.first;
    Priority priority = Priority.medium;
    DateTime? deadline;
    bool urgent = false;

    for (var i = 1; i < args.length; i++) {
      switch (args[i]) {
        case '--priority':
          priority = Priority.fromString(args[++i]);
          break;
        case '--deadline':
          deadline = DateTime.parse(args[++i]);
          break;
        case '--urgent':
          urgent = true;
          break;
      }
    }

    final task = service.addTask(
      title: title,
      priority: priority,
      deadline: deadline,
      urgent: urgent,
    );
    return 'Added ${task.typeTag} ${task.id}: "${task.title}"';
  }

  String _handleList(List<String> args) {
    var sortBy = SortMode.priority;
    if (args.contains('--sort-by-date')) sortBy = SortMode.deadline;

    final tasks = service.listTasks(sortBy: sortBy);
    if (tasks.isEmpty) return 'No tasks yet.';
    return tasks.map((t) => t.toString()).join('\n');
  }

  String _handleDone(List<String> args) {
    if (args.isEmpty) throw InvalidTaskException('done requires a task id.');
    final task = service.markDone(args.first);
    return 'Marked done: ${task.id} "${task.title}"';
  }

  String _handleDelete(List<String> args) {
    if (args.isEmpty) throw InvalidTaskException('delete requires a task id.');
    service.deleteTask(args.first);
    return 'Deleted ${args.first}';
  }

  String _usage() => '''
CLI Task Manager

Usage:
  add "<title>" [--priority low|medium|high] [--deadline 2026-09-01] [--urgent]
  list [--sort-by-date]        (default sort: priority, high first)
  done <id>
  delete <id>
  help
''';
}
