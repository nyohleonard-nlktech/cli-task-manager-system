# CLI Task Manager

A command-line task management application written in pure Dart (no
Flutter). Tasks are persisted to a local `tasks.json` file, so state
survives between runs.

## Requirements

- Dart SDK ≥ 3.0 (`dart --version` to check)

## Setup

```bash
dart pub get
```

## Running the app

```bash
dart run bin/main.dart <command> [args]
```

### Commands

| Command | Example | Notes |
|---|---|---|
| `add` | `dart run bin/main.dart add "Write report" --priority high --deadline 2026-09-01` | `--priority` is `low`\|`medium`\|`high` (default `medium`). `--deadline` is `YYYY-MM-DD`. Add `--urgent` to create an `UrgentTask` instead of a `StandardTask` — this requires `--deadline`. |
| `list` | `dart run bin/main.dart list` | Sorted by priority (high → low) by default. Add `--sort-by-date` to sort by deadline instead (tasks with no deadline sort last). |
| `done` | `dart run bin/main.dart done t3` | Marks task `t3` complete. |
| `delete` | `dart run bin/main.dart delete t3` | Removes task `t3` permanently. |
| `help` | `dart run bin/main.dart help` | Prints usage. |

## Running the tests

```bash
dart test
```

This runs 12 tests across three files:

- `test/task_test.dart` — the `Task`/`StandardTask`/`UrgentTask` model
  hierarchy: validation, JSON round-tripping, and the overridden
  `isOverdue` escalation behaviour.
- `test/json_task_repository_test.dart` — the JSON-file-backed
  repository: persistence survives a fresh instance, deletes persist,
  deleting an unknown id is a no-op.
- `test/task_service_test.dart` — sorting (by priority, by deadline)
  and the custom-exception error paths.

## Architecture

```
lib/
  models/
    task.dart              abstract Task (implements JsonSerializable)
    standard_task.dart      StandardTask extends Task
    urgent_task.dart        UrgentTask extends Task (overrides isOverdue)
    json_serializable.dart  the interface Task implements
    priority.dart           Priority enum
  exceptions/
    task_exceptions.dart    AppException and its three subclasses
  repository/
    repository.dart         abstract Repository<T> (generic)
    json_task_repository.dart  Repository<Task> backed by tasks.json
  services/
    task_service.dart       business logic: add/list/done/delete, sorting
  cli/
    cli_runner.dart          argument parsing and command dispatch
bin/
  main.dart                  entrypoint; catches AppException at the boundary
test/
  task_test.dart
  json_task_repository_test.dart
  task_service_test.dart
```

**Where each technical requirement lives**, for grading convenience:

- **Abstract class + inheritance**: `Task` (abstract) → `StandardTask`,
  `UrgentTask` (`lib/models/`). `UrgentTask` overrides `isOverdue` to
  flag tasks inside an escalation window, not just past their deadline.
- **Interface**: `JsonSerializable` (`lib/models/json_serializable.dart`),
  implemented by `Task` via `implements`.
- **Generics**: `Repository<T>` (`lib/repository/repository.dart`),
  instantiated as `Repository<Task>` by `JsonTaskRepository`.
- **Custom exceptions**: `AppException` and its subclasses
  `TaskNotFoundException`, `InvalidTaskException`,
  `TaskPersistenceException` (`lib/exceptions/task_exceptions.dart`),
  thrown by the service/repository layers and caught once at the
  boundary in `bin/main.dart`.
- **Persistence**: `JsonTaskRepository` reads/writes `tasks.json` on
  every mutation (`lib/repository/json_task_repository.dart`).

## Known limitations

- No `edit`/`update` command exposed at the CLI layer yet, though
  `Repository.update` supports it.
- IDs are sequential (`t1`, `t2`, ...) rather than UUIDs — fine for a
  single-user local CLI, would need to change for concurrent writers.
