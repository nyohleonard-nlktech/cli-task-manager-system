/// Base class for every exception this application can throw.
///
/// Extending a single [AppException] (rather than throwing raw [Exception]s
/// or [String]s) lets calling code do `on AppException catch (e)` in one
/// place — bin/main.dart — while still allowing specific catch clauses for
/// specific failures where that's useful.
abstract class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => message;
}

/// Thrown when a lookup, update, or delete references a task id that
/// does not exist in the repository.
class TaskNotFoundException extends AppException {
  final String taskId;
  TaskNotFoundException(this.taskId)
      : super('No task found with id "$taskId".');
}

/// Thrown when task data fails validation (e.g. empty title, deadline
/// already in the past, malformed priority) before it ever reaches
/// the repository.
class InvalidTaskException extends AppException {
  InvalidTaskException(String reason) : super('Invalid task: $reason');
}

/// Thrown when reading from or writing to the JSON store fails —
/// covers missing file permissions, corrupted JSON, and I/O errors.
class TaskPersistenceException extends AppException {
  TaskPersistenceException(String reason)
      : super('Persistence error: $reason');
}
