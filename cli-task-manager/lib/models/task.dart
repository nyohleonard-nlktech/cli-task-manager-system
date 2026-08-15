import '../exceptions/task_exceptions.dart';
import 'json_serializable.dart';
import 'priority.dart';
import 'standard_task.dart';
import 'urgent_task.dart';

/// Abstract base for every task type in the system.
///
/// [Task] is deliberately not instantiable directly — you get either a
/// [StandardTask] or an [UrgentTask]. This is the "Task → UrgentTask"
/// inheritance relationship required by the spec, and it also
/// `implements` [JsonSerializable] to satisfy the interface requirement.
abstract class Task implements JsonSerializable {
  final String id;
  String title;
  Priority priority;
  DateTime? deadline;
  bool isDone;

  Task({
    required this.id,
    required this.title,
    required this.priority,
    this.deadline,
    this.isDone = false,
  }) {
    if (title.trim().isEmpty) {
      throw InvalidTaskException('title must not be empty.');
    }
  }

  /// Human-readable type tag, overridden per subclass. Used both for
  /// display and as the JSON discriminator on deserialization.
  String get typeTag;

  /// Whether this task counts as overdue right now. [UrgentTask]
  /// overrides this to add an earlier "at risk" threshold — see there.
  bool get isOverdue {
    if (deadline == null || isDone) return false;
    return DateTime.now().isAfter(deadline!);
  }

  void markDone() => isDone = true;

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'priority': priority.name,
        'deadline': deadline?.toIso8601String(),
        'isDone': isDone,
        'type': typeTag,
      };

  /// Factory dispatch: reads the `type` discriminator written by
  /// [toJson] and rebuilds the correct concrete subclass.
  factory Task.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String? ?? 'StandardTask';
    switch (type) {
      case 'UrgentTask':
        return UrgentTask.fromJson(json);
      case 'StandardTask':
        return StandardTask.fromJson(json);
      default:
        throw TaskPersistenceException('Unknown task type "$type" in store.');
    }
  }

  @override
  String toString() {
    final status = isDone ? '[x]' : '[ ]';
    final dl = deadline == null ? '' : ' (due ${deadline!.toIso8601String().split('T').first})';
    final overdueTag = isOverdue ? ' OVERDUE' : '';
    return '$status $id  ${priority.name.toUpperCase().padRight(6)} $title$dl$overdueTag';
  }
}
