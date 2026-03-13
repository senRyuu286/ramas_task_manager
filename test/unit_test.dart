import 'package:task_manager/models/task.dart';
import 'package:task_manager/services/task_service.dart';
import 'package:test/test.dart';

void main() {
  Task createTask({
    String id = '00',
    String title = 'Test',
    bool completed = false,
    Priority priority = Priority.medium,
    DateTime? dueDate
  }) {
    return Task(
      id: id,
      title: title,
      isCompleted: completed,
      priority: priority,
      dueDate: dueDate ?? DateTime.now()
    );
  }

  group('Task Model — Constructor & Properties', () {
    late Task task;

    setUp(() {
      task = Task(
        id: '00',
        title: 'Test00',
        dueDate: DateTime(2025, 3, 10, 21, 15),
      );

      task = createTask();
    });

    test(
      'Default Values Test: Task model assigns default values when optional fields are not provided',
      () {
        expect(task.description, isEmpty);
        expect(task.isCompleted, isFalse);
      },
    );

    test(
      'Required Field Assignment Test: Task model correctly stores values provided for required fields during creation',
      () {
        expect(task.id, equals('00'));
        expect(task.title, equals('Test00'));
      },
    );

    test(
      'Priority Assignment Test: Task model stores the default priority value correctly',
      () {
        expect(task.priority, equals(Priority.medium));
      },
    );

    test(
      'Due Date Storage Test: Task model stores the provided due date correctly when creating a task',
      () {
        expect(task.dueDate, equals(DateTime(2025, 3, 10, 21, 15)));
      },
    );
  });

  group('Task Model — copyWith()', () {
    late Task task;

    setUp(() {
      task = Task(
        id: '00',
        title: 'Test00',
        dueDate: DateTime(2025, 3, 10, 21, 15),
        description: 'Task Model Test for copyWith() function.',
        priority: Priority.high,
        isCompleted: true,
      );
    });

    test(
      'Partial Update Test: copyWith updates only the provided fields while keeping other fields unchanged',
      () {
        task = task.copyWith(
          title: 'Test01',
          priority: Priority.low,
          isCompleted: false,
        );

        expect(
          [
            task.id,
            task.title,
            task.dueDate,
            task.description,
            task.priority,
            task.isCompleted,
          ],
          equals([
            '00',
            'Test01',
            DateTime(2025, 3, 10, 21, 15),
            'Task Model Test for copyWith() function.',
            Priority.low,
            isFalse,
          ]),
        );
      },
    );

    test(
      'Full Update Test: copyWith updates all fields when new values are provided for every property',
      () {
        task = task.copyWith(
          id: '02',
          title: 'Test02',
          dueDate: DateTime(2025, 3, 11, 13, 30),
          description:
              'Task Model Test for copyWith() function. This is now updated.',
          priority: Priority.low,
          isCompleted: false,
        );

        expect(
          [
            task.id,
            task.title,
            task.dueDate,
            task.description,
            task.priority,
            task.isCompleted,
          ],
          equals([
            '02',
            'Test02',
            DateTime(2025, 3, 11, 13, 30),
            'Task Model Test for copyWith() function. This is now updated.',
            Priority.low,
            isFalse,
          ]),
        );
      },
    );

    test(
      'Immutability Test: copyWith returns a new task instance without modifying the original task',
      () {
        final task03 = task.copyWith(id: '03', title: 'Test03');

        expect(
          [
            task.id,
            task.title,
            task.dueDate,
            task.description,
            task.priority,
            task.isCompleted,
          ],
          equals([
            '00',
            'Test00',
            DateTime(2025, 3, 10, 21, 15),
            'Task Model Test for copyWith() function.',
            Priority.high,
            isTrue,
          ]),
        );

        expect(
          [
            task03.id,
            task03.title,
            task03.dueDate,
            task03.description,
            task03.priority,
            task03.isCompleted,
          ],
          equals([
            '03',
            'Test03',
            DateTime(2025, 3, 10, 21, 15),
            'Task Model Test for copyWith() function.',
            Priority.high,
            isTrue,
          ]),
        );
      },
    );
  });

  group('Task Model — isOverdue getter', () {
    late Task task;

    setUp(() {
      task = Task(id: '00', title: 'Test00', dueDate: DateTime.now());
    });

    test(
      'Past Due Incomplete Test: isOverdue returns true when the task is incomplete and the due date is in the past',
      () {
        task = task.copyWith(
          dueDate: DateTime.now().subtract(const Duration(days: 30)),
        );

        expect(task.isOverdue, isTrue);
      },
    );

    test(
      'Future Due Test: isOverdue returns false when the due date is in the future and the task is incomplete',
      () {
        task = task.copyWith(
          dueDate: DateTime.now().add(const Duration(days: 30)),
        );

        expect(task.isOverdue, isFalse);
      },
    );

    test(
      'Completed Past Due Test: isOverdue returns false when the task is completed even if the due date is in the past',
      () {
        task = task.copyWith(
          dueDate: DateTime.now().subtract(const Duration(days: 30)),
          isCompleted: true,
        );

        expect(task.isOverdue, isFalse);
      },
    );
  });

  group('Task Model — toJson() / fromJson()', () {
    late Task task;
    late Map<String, dynamic> json;
    late Task jsonTask;

    setUp(() {
      task = Task(id: '00', title: 'Test00', dueDate: DateTime.now());
      json = task.toJson();
      jsonTask = Task.fromJson(json);
    });

    test(
      'Serialization Round-Trip Test: converting a task to JSON and back produces an identical task',
      () {
        expect(
          [
            jsonTask.id,
            jsonTask.title,
            jsonTask.dueDate,
            jsonTask.description,
            jsonTask.priority,
            jsonTask.isCompleted,
          ],
          equals([
            task.id,
            task.title,
            task.dueDate,
            task.description,
            task.priority,
            task.isCompleted,
          ]),
        );
      },
    );

    test(
      'Field Type Preservation Test: task fields maintain correct types during JSON serialization and deserialization',
      () {
        expect(
          [
            jsonTask.id,
            jsonTask.title,
            jsonTask.dueDate,
            jsonTask.description,
            jsonTask.priority,
            jsonTask.isCompleted,
          ],
          [
            isA<String>(),
            isA<String>(),
            isA<DateTime>(),
            isA<String>(),
            isA<Priority>(),
            isA<bool>(),
          ],
        );
      },
    );

    test(
      'Priority Mapping Test: priority enum is correctly converted to index and restored during JSON conversion',
      () {
        expect(task.priority.index, equals(json['priority']));
        expect(task.priority, equals(jsonTask.priority));
      },
    );
  });

  group('TaskService — addTask()', () {
    late Task task;
    late TaskService taskService;

    setUp(() {
      task = Task(id: '00', title: 'Test00', dueDate: DateTime.now());
      taskService = TaskService();
    });

    test(
      'Successful Add Test: addTask adds a valid task to the task collection',
      () {
        taskService.addTask(task);

        expect(taskService.allTasks, contains(task));
      },
    );

    test(
      'Empty Title Validation Test: addTask throws ArgumentError when a task with an empty title is added',
      () {
        final emptyTask = task.copyWith(title: '');

        expect(() => taskService.addTask(emptyTask), throwsArgumentError);
      },
    );

    test(
      'Duplicate ID Handling Test: addTask allows multiple tasks with duplicate IDs in the collection',
      () {
        final taskDupe = task.copyWith();

        taskService.addTask(task);
        taskService.addTask(taskDupe);

        expect(task.id, equals(taskDupe.id));
        expect(taskService.allTasks, hasLength(2));
      },
    );
  });

  group('TaskService — deleteTask()', () {
    late Task task;
    late TaskService taskService;

    setUp(() {
      task = Task(id: '00', title: 'Test00', dueDate: DateTime.now());
      taskService = TaskService();

      taskService.addTask(task);
    });

    test(
      'Delete Existing Task Test: deleteTask removes a task when a matching ID exists',
      () {
        taskService.deleteTask('00');

        expect(taskService.allTasks, isNot(contains(task)));
      },
    );

    test(
      'Delete Nonexistent Task Test: deleteTask performs no action when the task ID does not exist',
      () {
        taskService.deleteTask('01');

        expect(taskService.allTasks, contains(task));
      },
    );
  });

  group('TaskService — toggleComplete()', () {
    late Task task;
    late TaskService taskService;

    setUp(() {
      task = Task(id: '00', title: 'Test00', dueDate: DateTime.now());
      taskService = TaskService();

      taskService.addTask(task);
    });

    test(
      'Toggle Incomplete to Complete Test: toggleComplete changes task status from incomplete to complete',
      () {
        taskService.toggleComplete('00');

        expect(taskService.allTasks.first.isCompleted, isTrue);
      },
    );

    test(
      'Toggle Complete to Incomplete Test: toggleComplete changes task status from complete to incomplete',
      () {
        taskService.toggleComplete('00');
        taskService.toggleComplete('00');

        expect(taskService.allTasks.first.isCompleted, isFalse);
      },
    );

    test(
      'Unknown Task ID Test: toggleComplete throws StateError when the task ID does not exist',
      () {
        expect(() => taskService.toggleComplete('01'), throwsStateError);
      },
    );
  });

  group('TaskService — getByStatus()', () {
    late Task task0;
    late Task task1;
    late Task task2;
    late Task task3;
    late Task task4;
    late TaskService taskService;

    setUp(() {
      task0 = Task(
        id: '00',
        title: 'Test00',
        dueDate: DateTime.now(),
        isCompleted: true,
      );
      task1 = Task(id: '01', title: 'Test01', dueDate: DateTime.now());
      task2 = Task(
        id: '02',
        title: 'Test02',
        dueDate: DateTime.now(),
        isCompleted: true,
      );
      task3 = Task(
        id: '03',
        title: 'Test03',
        dueDate: DateTime.now(),
        isCompleted: true,
      );
      task4 = Task(id: '04', title: 'Test04', dueDate: DateTime.now());
      taskService = TaskService();

      taskService.addTask(task0);
      taskService.addTask(task1);
      taskService.addTask(task2);
      taskService.addTask(task3);
      taskService.addTask(task4);
    });

    test(
      'Filter Active Tasks Test: getByStatus returns only incomplete tasks when filtering active status',
      () {
        List<Task> incompleteTasks = taskService.getByStatus(completed: false);

        expect(incompleteTasks, hasLength(2));
        expect([
          incompleteTasks[0].id,
          incompleteTasks[1].id,
        ], equals([taskService.allTasks[1].id, taskService.allTasks[4].id]));
      },
    );

    test(
      'Filter Completed Tasks Test: getByStatus returns only completed tasks when filtering completed status',
      () {
        List<Task> incompleteTasks = taskService.getByStatus(completed: true);

        expect(incompleteTasks, hasLength(3));
        expect(
          [incompleteTasks[0].id, incompleteTasks[1].id, incompleteTasks[2].id],
          equals([
            taskService.allTasks[0].id,
            taskService.allTasks[2].id,
            taskService.allTasks[3].id,
          ]),
        );
      },
    );
  });

  group('TaskService — sortByPriority()', () {
    late Task task0;
    late Task task1;
    late Task task2;
    late Task task3;
    late Task task4;
    late TaskService taskService;

    setUp(() {
      task0 = Task(
        id: '00',
        title: 'Test00',
        dueDate: DateTime.now(),
        priority: Priority.high,
      );
      task1 = Task(
        id: '01',
        title: 'Test01',
        dueDate: DateTime.now(),
        priority: Priority.low,
      );
      task2 = Task(
        id: '02',
        title: 'Test02',
        dueDate: DateTime.now(),
        priority: Priority.high,
      );
      task3 = Task(
        id: '03',
        title: 'Test03',
        dueDate: DateTime.now(),
        priority: Priority.medium,
      );
      task4 = Task(
        id: '04',
        title: 'Test04',
        dueDate: DateTime.now(),
        priority: Priority.medium,
      );
      taskService = TaskService();

      taskService.addTask(task0);
      taskService.addTask(task1);
      taskService.addTask(task2);
      taskService.addTask(task3);
      taskService.addTask(task4);
    });

    test(
      'Priority Sorting Test: sortByPriority returns tasks ordered from highest to lowest priority',
      () {
        List<Task> sortedTask = taskService.sortByPriority();

        expect(sortedTask.first.priority, equals(Priority.high));
        expect(sortedTask.last.priority, equals(Priority.low));
      },
    );

    test(
      'Immutability Sorting Test: sortByPriority does not modify the original task list',
      () {
        taskService.sortByDueDate();

        expect(
          [
            taskService.allTasks[0].priority,
            taskService.allTasks[1].priority,
            taskService.allTasks[2].priority,
            taskService.allTasks[3].priority,
            taskService.allTasks[4].priority,
          ],
          equals([
            Priority.high,
            Priority.low,
            Priority.high,
            Priority.medium,
            Priority.medium,
          ]),
        );
      },
    );
  });

  group('TaskService — sortByDueDate()', () {
    late Task task0;
    late Task task1;
    late Task task2;
    late Task task3;
    late Task task4;
    late TaskService taskService;

    final dueDate0 = DateTime.now().add(Duration(days: 30));
    final dueDate1 = DateTime.now().subtract(Duration(days: 30));
    final dueDate2 = DateTime.now().subtract(Duration(days: 3));
    final dueDate3 = DateTime.now().add(Duration(days: 15));
    final dueDate4 = DateTime.now().add(Duration(days: 25));

    setUp(() {
      task0 = Task(id: '00', title: 'Test00', dueDate: dueDate0);
      task1 = Task(id: '01', title: 'Test01', dueDate: dueDate1);
      task2 = Task(id: '02', title: 'Test02', dueDate: dueDate2);
      task3 = Task(id: '03', title: 'Test03', dueDate: dueDate3);
      task4 = Task(id: '04', title: 'Test04', dueDate: dueDate4);
      taskService = TaskService();

      taskService.addTask(task0);
      taskService.addTask(task1);
      taskService.addTask(task2);
      taskService.addTask(task3);
      taskService.addTask(task4);
    });

    test(
      'Due Date Sorting Test: sortByDueDate returns tasks ordered by earliest due date first',
      () {
        List<Task> sortedTask = taskService.sortByDueDate();

        expect(
          [
            sortedTask[0].dueDate,
            sortedTask[1].dueDate,
            sortedTask[2].dueDate,
            sortedTask[3].dueDate,
            sortedTask[4].dueDate,
          ],
          equals([
            taskService.allTasks[1].dueDate,
            taskService.allTasks[2].dueDate,
            taskService.allTasks[3].dueDate,
            taskService.allTasks[4].dueDate,
            taskService.allTasks[0].dueDate,
          ]),
        );
      },
    );

    test(
      'Original List Preservation Test: sortByDueDate does not modify the original task list',
      () {
        taskService.sortByDueDate();

        expect([
          taskService.allTasks[0].dueDate,
          taskService.allTasks[1].dueDate,
          taskService.allTasks[2].dueDate,
          taskService.allTasks[3].dueDate,
          taskService.allTasks[4].dueDate,
        ], equals([dueDate0, dueDate1, dueDate2, dueDate3, dueDate4]));
      },
    );
  });

  group('TaskService — statistics getter', () {
    late Task task0;
    late Task task1;
    late Task task2;
    late Task task3;
    late Task task4;
    late Task task5;
    late Task task6;
    late Task task7;
    late TaskService taskService;

    setUp(() {
      task0 = Task(
        id: '00',
        title: 'Test00',
        dueDate: DateTime.now().add(Duration(days: 30)),
        isCompleted: true,
      );
      task1 = Task(
        id: '01',
        title: 'Test01',
        dueDate: DateTime.now().subtract(Duration(days: 3)),
      );
      task2 = Task(
        id: '02',
        title: 'Test02',
        dueDate: DateTime.now().subtract(Duration(days: 5)),
        isCompleted: true,
      );
      task3 = Task(
        id: '03',
        title: 'Test03',
        dueDate: DateTime.now().add(Duration(days: 15)),
        isCompleted: true,
      );
      task4 = Task(
        id: '04',
        title: 'Test04',
        dueDate: DateTime.now().add(Duration(days: 30)),
      );
      task5 = Task(
        id: '05',
        title: 'Test05',
        dueDate: DateTime.now().add(Duration(days: 30)),
      );
      task6 = Task(
        id: '06',
        title: 'Test06',
        dueDate: DateTime.now().subtract(Duration(days: 10)),
      );
      task7 = Task(
        id: '07',
        title: 'Test07',
        dueDate: DateTime.now().add(Duration(days: 30)),
      );
      taskService = TaskService();

      taskService.addTask(task0);
      taskService.addTask(task1);
      taskService.addTask(task2);
      taskService.addTask(task3);
      taskService.addTask(task4);
      taskService.addTask(task5);
      taskService.addTask(task6);
      taskService.addTask(task7);
    });

    test(
      'Empty Statistics Test: statistics returns zero counts when there are no tasks',
      () {
        taskService = TaskService();

        final Map<String, int> statistics = taskService.statistics;

        expect([
          statistics['total'],
          statistics['completed'],
          statistics['overdue'],
        ], equals([0, 0, 0]));
      },
    );

    test(
      'Mixed Task Count Test: statistics returns correct counts for active and completed tasks',
      () {
        final Map<String, int> statistics = taskService.statistics;

        expect([statistics['total'], statistics['completed']], equals([8, 3]));
      },
    );

    test(
      'Overdue Count Accuracy Test: statistics correctly counts tasks that are overdue',
      () {
        final Map<String, int> statistics = taskService.statistics;

        expect(statistics['overdue'], equals(2));
      },
    );
  });
}