import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:taskly/data/models/task_model.dart';

abstract class TaskRemoteDataSource {
  Stream<List<TaskModel>> watchRemoteTasks();
  Future<void> pushTask(TaskModel task);
  Future<void> deleteRemoteTask(String id);
}

class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  final FirebaseFirestore firestore;

  TaskRemoteDataSourceImpl({required this.firestore});

  String get userId => FirebaseAuth.instance.currentUser!.uid;

  CollectionReference<Map<String, dynamic>> get _tasks =>
      firestore.collection('Users').doc(userId).collection('tasks');

  @override
  Stream<List<TaskModel>> watchRemoteTasks() {
    return _tasks.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => TaskModel.fromJson(doc.data(), doc.id))
          .toList();
    });
  }

  @override
  Future<void> pushTask(TaskModel task) async {
    await _tasks.doc(task.id).set(task.toJson(), SetOptions(merge: true));
  }

  @override
  Future<void> deleteRemoteTask(String id) async {
    await _tasks.doc(id).delete();
  }
}
