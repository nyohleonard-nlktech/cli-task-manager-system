# CLI Task Manager System

A pure-Dart command-line task management application.

## Requirements
Dart SDK >=3.0.0 and <4.0.0.

## Setup
```bash
git clone https://github.com/nyohleonard-nlktech/cli-task-manager-system.git
cd cli-task-manager-system
dart pub get
```

## Run
```bash
dart run
```
If a named executable is defined under bin/, run it with `dart run bin/<entrypoint>.dart`.

## Test and analyze
```bash
dart test
dart analyze
```

## Structure
```text
bin/       # Executable entry point
lib/       # Application logic
test/      # Automated tests
pubspec.yaml
pubspec.lock
```

Keep reusable task operations in lib/ and command-line input/output in bin/. Add tests for task lifecycle behavior as features are extended.

No license file is present. All rights reserved unless an explicit license is added.
