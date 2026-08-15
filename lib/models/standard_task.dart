import 'priority.dart';
import 'task.dart';

/// An ordinary task with no special escalation behaviour.
class StandardTask extends Task {
  StandardTask({
    required super.id,
    required super.title,
    required super.priority,
    super.deadline,
    super.isDone = false,
  });

  @override
  String get typeTag => 'StandardTask';

  factory StandardTask.fromJson(Map<String, dynamic> json) => StandardTask(
        id: json['id'] as String,
        title: json['title'] as String,
        priority: Priority.fromString(json['priority'] as String),
        deadline: json['deadline'] == null
            ? null
            : DateTime.parse(json['deadline'] as String),
        isDone: json['isDone'] as bool? ?? false,
      );
}
