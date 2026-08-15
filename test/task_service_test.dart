import 'dart:io';

import 'package:cli_task_manager/exceptions/task_exceptions.dart';
import 'package:cli_task_manager/models/priority.dart';
import 'package:cli_task_manager/repository/json_task_repository.dart';
import 'package:cli_task_manager/services/task_service.dart';
import 'package:test/test.dart';

void main() {
  late Directory tempDir;
  late TaskService service;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('task_service_test_');
    final repo = JsonTaskRepository('${tempDir.path}/tasks.json');
    service = TaskService(repo);
  });

  tearDown(() => tempDir.deleteSync(recursive: true));

  test('listTasks sorted by priority returns high before medium before low', () {
    service.addTask(title: 'Low one', priority: Priority.low);
    service.addTask(title: 'High one', priority: Priority.high);
    service.addTask(title: 'Medium one', priority: Priority.medium);

    final sorted = service.listTasks(sortBy: SortMode.priority);

    expect(sorted.map((t) => t.priority),
        [Priority.high, Priority.medium, Priority.low]);
  });

  test('listTasks sorted by deadline returns earliest first, no-deadline tasks last', () {
    service.addTask(
      title: 'No deadline',
      priority: Priority.medium,
    );
    service.addTask(
      title: 'Due later',
      priority: Priority.medium,
      deadline: DateTime(2026, 12, 1),
    );
    service.addTask(
      title: 'Due sooner',
      priority: Priority.medium,
      deadline: DateTime(2026, 9, 1),
    );

    final sorted = service.listTasks(sortBy: SortMode.deadline);

    expect(sorted.map((t) => t.title),
        ['Due sooner', 'Due later', 'No deadline']);
  });

  test('markDone on an unknown id throws TaskNotFoundException', () {
    expect(() => service.markDone('ghost'), throwsA(isA<TaskNotFoundException>()));
  });

  test('deleteTask on an unknown id throws TaskNotFoundException', () {
    expect(() => service.deleteTask('ghost'), throwsA(isA<TaskNotFoundException>()));
  });

  test('addTask with urgent:true but no deadline throws InvalidTaskException', () {
    expect(
      () => service.addTask(title: 'Missing deadline', priority: Priority.high, urgent: true),
      throwsA(isA<InvalidTaskException>()),
    );
  });
}
