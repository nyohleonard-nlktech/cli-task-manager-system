import 'dart:io';

import 'package:cli_task_manager/models/priority.dart';
import 'package:cli_task_manager/models/standard_task.dart';
import 'package:cli_task_manager/repository/json_task_repository.dart';
import 'package:test/test.dart';

void main() {
  late Directory tempDir;
  late String storePath;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('task_repo_test_');
    storePath = '${tempDir.path}/tasks.json';
  });

  tearDown(() {
    tempDir.deleteSync(recursive: true);
  });

  test('add() persists to disk so a fresh repository instance can read it back', () {
    final repo1 = JsonTaskRepository(storePath);
    repo1.add(StandardTask(id: 't1', title: 'Buy milk', priority: Priority.low));

    // Simulate the next CLI invocation: brand-new repository, same file.
    final repo2 = JsonTaskRepository(storePath);
    expect(repo2.getAll(), hasLength(1));
    expect(repo2.findById('t1')?.title, 'Buy milk');
  });

  test('delete() removes the task and persists the removal', () {
    final repo = JsonTaskRepository(storePath);
    repo.add(StandardTask(id: 't1', title: 'Temp task', priority: Priority.low));

    final removed = repo.delete('t1');
    expect(removed, isTrue);

    final reloaded = JsonTaskRepository(storePath);
    expect(reloaded.getAll(), isEmpty);
  });

  test('delete() returns false for a non-existent id and does not touch the file', () {
    final repo = JsonTaskRepository(storePath);
    repo.add(StandardTask(id: 't1', title: 'Keep me', priority: Priority.low));

    final removed = repo.delete('does-not-exist');
    expect(removed, isFalse);
    expect(repo.getAll(), hasLength(1));
  });
}
