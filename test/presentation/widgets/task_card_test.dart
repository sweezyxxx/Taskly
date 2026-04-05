import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:taskly/domain/entities/task_entity.dart';
import 'package:taskly/presentation/widgets/task_card.dart';

void main() {
  testWidgets('TaskCard displays title, priority and responds to toggle tap', (WidgetTester tester) async {
    final tTask = TaskEntity(
      id: '1',
      title: 'Buy Milk',
      description: 'Go to grocery store',
      status: TaskStatus.todo,
      priority: TaskPriority.high,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isSynced: false,
    );

    bool isToggled = false;

    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => Scaffold(
            body: TaskCard(
              task: tTask,
              onToggleStatus: () {
                isToggled = true;
              },
            ),
          ),
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
      ),
    );

    // Verify initial UI state
    expect(find.text('Buy Milk'), findsOneWidget);
    expect(find.text('HIGH'), findsOneWidget);

    // Simulate User Interaction
    // In TaskCard, the checkbox is a Container with width 24 wrapped in a GestureDetector.
    // InkWell is also present. We want to find the innermost GestureDetector which should be our checkbox.
    final checkboxFinder = find.descendant(
      of: find.byType(TaskCard),
      matching: find.byWidgetPredicate((widget) => widget is Container && widget.constraints?.maxWidth == 24),
    );
    
    await tester.tap(checkboxFinder);
    await tester.pumpAndSettle();

    // Verify interaction result
    expect(isToggled, isTrue);
  });
}
