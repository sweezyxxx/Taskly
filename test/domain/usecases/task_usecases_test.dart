import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:taskly/domain/entities/task_entity.dart';
import 'package:taskly/domain/repositories/task_repository.dart';
import 'package:taskly/domain/usecases/task_usecases.dart';

class MockTaskRepository extends Mock implements TaskRepository {}

class FakeTaskEntity extends Fake implements TaskEntity {}

void main() {
  late CreateTaskUseCase usecase;
  late MockTaskRepository repository;

  setUpAll(() {
    registerFallbackValue(FakeTaskEntity());
  });

  setUp(() {
    repository = MockTaskRepository();
    usecase = CreateTaskUseCase(repository);
  });

  final tTask = TaskEntity(
    id: '1',
    title: 'Test Task',
    description: 'Test Desc',
    status: TaskStatus.todo,
    priority: TaskPriority.high,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
    isSynced: false,
  );

  test('should call createTask on the repository', () async {
    when(
      () => repository.createTask(any()),
    ).thenAnswer((_) async => Future.value());

    await usecase(tTask);

    verify(() => repository.createTask(tTask)).called(1);
    verifyNoMoreInteractions(repository);
  });

  test('should call deleteTask on the repository', () async {
    final deleteUseCase = DeleteTaskUseCase(repository);
    when(() => repository.deleteTask(any())).thenAnswer((_) async => Future.value());

    await deleteUseCase('1');

    verify(() => repository.deleteTask('1')).called(1);
  });

  test('should call syncWithCloud on the repository', () async {
    final syncUseCase = SyncTasksUseCase(repository);
    when(() => repository.syncWithCloud()).thenAnswer((_) async => Future.value());

    await syncUseCase();

    verify(() => repository.syncWithCloud()).called(1);
  });
}
