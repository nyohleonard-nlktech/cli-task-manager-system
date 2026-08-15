import 'package:cli_task_manager/exceptions/task_exceptions.dart';
import 'package:cli_task_manager/models/priority.dart';
import 'package:cli_task_manager/models/standard_task.dart';
import 'package:cli_task_manager/models/urgent_task.dart';
import 'package:test/test.dart';

void main() {
  group('StandardTask', () {
    test('rejects an empty title with InvalidTaskException', () {
      expect(
        () => StandardTask(id: 't1', title: '   ', priority: Priority.low),
        throwsA(isA<InvalidTaskException>()),
      );
    });

    test('round-trips through toJson/fromJson preserving state', () {
      final original = StandardTask(
        id: 't1',
        title: 'Write report',
        priority: Priority.medium,
        deadline: DateTime(2026, 9, 1),
      );
      final rebuilt = StandardTask.fromJson(original.toJson());

      expect(rebuilt.id, original.id);
      expect(rebuilt.title, original.title);
      expect(rebuilt.priority, original.priority);
      expect(rebuilt.deadline, original.deadline);
    });
  });

  group('UrgentTask', () {
    test('requires a deadline at construction', () {
      // UrgentTask's constructor signature requires DateTime (non-nullable),
      // so this is enforced at compile time; this test documents that a
      // deadline in the past is still accepted (validity of the date
      // itself is a business decision, not a type error).
      final task = UrgentTask(
        id: 't2',
        title: 'File taxes',
        deadline: DateTime.now().subtract(const Duration(days: 1)),
      );
      expect(task.deadline, isNotNull);
    });

    test('overrides isOverdue to trigger inside the escalation window, '
        'unlike StandardTask which only triggers after the deadline', () {
      final nearDeadline = DateTime.now().add(const Duration(hours: 2));

      final urgent = UrgentTask(
        id: 't3',
        title: 'Submit grant application',
        deadline: nearDeadline,
        escalationWindow: const Duration(hours: 24),
      );
      final standard = StandardTask(
        id: 't4',
        title: 'Water the plants',
        priority: Priority.high,
        deadline: nearDeadline,
      );

      // Same deadline, two hours out: UrgentTask is already "overdue"
      // because it's inside its 24h escalation window; StandardTask is not.
      expect(urgent.isOverdue, isTrue);
      expect(standard.isOverdue, isFalse);
    });

    test('marking done suppresses isOverdue even inside the escalation window', () {
      final urgent = UrgentTask(
        id: 't5',
        title: 'Renew passport',
        deadline: DateTime.now().add(const Duration(hours: 1)),
      )..markDone();

      expect(urgent.isOverdue, isFalse);
    });
  });

  group('Priority', () {
    test('fromString parses valid values and rejects unknown ones', () {
      expect(Priority.fromString('HIGH'), Priority.high);
      expect(Priority.fromString(' low '), Priority.low);
      expect(() => Priority.fromString('urgent'), throwsArgumentError);
    });
  });
}
