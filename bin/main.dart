import 'dart:io';

import 'package:cli_task_manager/cli/cli_runner.dart';
import 'package:cli_task_manager/exceptions/task_exceptions.dart';
import 'package:cli_task_manager/repository/json_task_repository.dart';
import 'package:cli_task_manager/services/task_service.dart';

void main(List<String> arguments) {
  final repo = JsonTaskRepository('tasks.json');
  final service = TaskService(repo);
  final runner = CliRunner(service);

  try {
    print(runner.run(arguments));
  } on AppException catch (e) {
    stderr.writeln('Error: $e');
    exit(1);
  } on FormatException catch (e) {
    stderr.writeln('Error: invalid input — ${e.message}');
    exit(1);
  }
}
