import '../exceptions/task_exceptions.dart';
import 'priority.dart';
import 'task.dart';

/// A task that carries an escalation window: it counts as "at risk"
/// (and reports as overdue early) once it enters the final
/// [escalationWindow] before its deadline, not just after the
/// deadline passes like [StandardTask].
///
/// An [UrgentTask] *requires* a deadline — constructing one without
/// one is a validation failure, demonstrating that a subclass can
/// tighten the contract its base class leaves optional.
class UrgentTask extends Task {
  final Duration escalationWindow;

  // NOTE: super-parameter shorthand (`super.id`) can't be mixed with an
  // explicit `: super(...)` initializer call, and this constructor needs
  // the latter (to make `deadline` non-nullable and default `priority`
  // differently from the base class), so every field is forwarded
  // explicitly instead.
  UrgentTask({
    required String id,
    required String title,
    required DateTime deadline,
    Priority priority = Priority.high,
    bool isDone = false,
    this.escalationWindow = const Duration(hours: 24),
  }) : super(
          id: id,
          title: title,
          priority: priority,
          deadline: deadline,
          isDone: isDone,
        );

  @override
  String get typeTag => 'UrgentTask';

  /// Overrides [Task.isOverdue]: an urgent task is flagged as overdue
  /// as soon as it enters its escalation window, not only once the
  /// deadline has strictly passed.
  @override
  bool get isOverdue {
    if (isDone) return false;
    final threshold = deadline!.subtract(escalationWindow);
    return DateTime.now().isAfter(threshold);
  }

  @override
  Map<String, dynamic> toJson() => {
        ...super.toJson(),
        'escalationWindowMinutes': escalationWindow.inMinutes,
      };

  factory UrgentTask.fromJson(Map<String, dynamic> json) {
    final deadlineRaw = json['deadline'] as String?;
    if (deadlineRaw == null) {
      throw TaskPersistenceException(
          'UrgentTask "${json['id']}" is missing a deadline in the store.');
    }
    return UrgentTask(
      id: json['id'] as String,
      title: json['title'] as String,
      priority: Priority.fromString(json['priority'] as String),
      deadline: DateTime.parse(deadlineRaw),
      isDone: json['isDone'] as bool? ?? false,
      escalationWindow:
          Duration(minutes: json['escalationWindowMinutes'] as int? ?? 1440),
    );
  }
}
