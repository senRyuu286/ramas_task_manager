import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:task_manager/models/task.dart';
import 'package:task_manager/widgets/task_tile.dart';

void main() {
  Future<void> pumpTaskTile(
    WidgetTester tester, {
    required Task task,
    required VoidCallback onToggle,
    required VoidCallback onDelete,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TaskTile(task: task, onToggle: onToggle, onDelete: onDelete),
        ),
      ),
    );
  }

  Task createTask({
    String id = '00',
    String title = 'Test',
    bool completed = false,
    Priority priority = Priority.medium,
    DateTime? dueDate,
  }) {
    return Task(
      id: id,
      title: title,
      isCompleted: completed,
      priority: priority,
      dueDate: dueDate ?? DateTime.now(),
    );
  }

  group('TaskTile — Rendering', () {
    testWidgets(
      'Title Rendering Test: TaskTile displays the task title text correctly in the UI',
      (WidgetTester tester) async {
        final task = createTask(title: 'Task Tile Test');

        await pumpTaskTile(
          tester,
          task: task,
          onToggle: () {},
          onDelete: () {},
        );

        expect(find.text('Task Tile Test'), findsOneWidget);
      },
    );

    testWidgets(
      'Priority Label Rendering Test: TaskTile shows the correct priority label based on the task priority',
      (WidgetTester tester) async {
        final task = createTask(priority: Priority.high);

        await pumpTaskTile(
          tester,
          task: task,
          onToggle: () {},
          onDelete: () {},
        );

        expect(find.text('HIGH'), findsOneWidget);
      },
    );

    testWidgets(
      'Checkbox State Rendering Test: Checkbox reflects the task\'s isCompleted state correctly',
      (WidgetTester tester) async {
        final task = createTask(completed: true);

        await pumpTaskTile(
          tester,
          task: task,
          onToggle: () {},
          onDelete: () {},
        );

        final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));

        expect(checkbox.value, isTrue);
      },
    );

    testWidgets(
      'Delete Icon Rendering Test: TaskTile displays a delete icon button for removing the task',
      (WidgetTester tester) async {
        final task = createTask();

        await pumpTaskTile(
          tester,
          task: task,
          onToggle: () {},
          onDelete: () {},
        );

        expect(find.byIcon(Icons.delete), findsOneWidget);
      },
    );
  });

  group('TaskTile — Checkbox Interaction', () {
    testWidgets(
      'Checkbox Toggle Callback Test: onToggle callback is triggered when the checkbox is tapped',
      (WidgetTester tester) async {
        bool called = false;

        final task = createTask();

        await pumpTaskTile(
          tester,
          task: task,
          onToggle: () {
            called = true;
          },
          onDelete: () {},
        );

        await tester.tap(find.byType(Checkbox));
        await tester.pump();

        expect(called, isTrue);
      },
    );

    testWidgets(
      'Checkbox Single Invocation Test: onToggle callback is called exactly once when the checkbox is tapped',
      (WidgetTester tester) async {
        int count = 0;

        final task = createTask();

        await pumpTaskTile(
          tester,
          task: task,
          onToggle: () {
            count++;
          },
          onDelete: () {},
        );

        await tester.tap(find.byType(Checkbox));
        await tester.pump();

        expect(count, equals(1));
      },
    );
  });

  group('TaskTile — Delete Interaction', () {
    testWidgets(
      'Delete Button Callback Test: onDelete callback is triggered when the delete icon button is tapped',
      (WidgetTester tester) async {
        bool called = false;

        final task = createTask();

        await pumpTaskTile(
          tester,
          task: task,
          onToggle: () {},
          onDelete: () {
            called = true;
          },
        );

        await tester.tap(find.byIcon(Icons.delete));
        await tester.pump();

        expect(called, isTrue);
      },
    );

    testWidgets(
      'Delete Button Single Invocation Test: onDelete callback is called exactly once when the delete icon button is tapped',
      (WidgetTester tester) async {
        int count = 0;

        final task = createTask();

        await pumpTaskTile(
          tester,
          task: task,
          onToggle: () {},
          onDelete: () {
            count++;
          },
        );

        await tester.tap(find.byIcon(Icons.delete));
        await tester.pump();

        expect(count, equals(1));
      },
    );
  });

  group('TaskTile — Completed State UI', () {
    testWidgets(
      'Completed Task Style Test: Task title displays with a line-through decoration when the task is completed',
      (WidgetTester tester) async {
        final task = createTask(completed: true);

        await pumpTaskTile(
          tester,
          task: task,
          onToggle: () {},
          onDelete: () {},
        );

        final textWidget = tester.widget<Text>(find.text(task.title));

        expect(textWidget.style?.decoration, TextDecoration.lineThrough);
      },
    );

    testWidgets(
      'Active Task Style Test: Task title displays without text decoration when the task is not completed',
      (WidgetTester tester) async {
        final task = createTask();

        await pumpTaskTile(
          tester,
          task: task,
          onToggle: () {},
          onDelete: () {},
        );

        final textWidget = tester.widget<Text>(find.text(task.title));

        expect(textWidget.style?.decoration, isNot(TextDecoration.lineThrough));
      },
    );
  });

  group(
    'Tile Key Assignment Test: TaskTile uses a ValueKey that matches the task id',
    () {
      testWidgets(
        'Tile Key Assignment Test: TaskTile uses a ValueKey that matches the task id',
        (WidgetTester tester) async {
          final task = createTask(id: '00');

          await pumpTaskTile(
            tester,
            task: task,
            onToggle: () {},
            onDelete: () {},
          );

          expect(find.byKey(ValueKey(task.id)), findsOneWidget);
        },
      );

      testWidgets(
        'Widget Key Presence Test: Checkbox and delete button widgets have the correct assigned keys',
        (WidgetTester tester) async {
          final task = createTask(id: '00');

          await pumpTaskTile(
            tester,
            task: task,
            onToggle: () {},
            onDelete: () {},
          );

          expect(find.byKey(Key('checkbox_${task.id}')), findsOneWidget);
          expect(find.byKey(Key('delete_${task.id}')), findsOneWidget);
        },
      );
    },
  );
}
