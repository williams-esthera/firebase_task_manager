import 'package:cloud_firestore/cloud_firestore.dart';
import 'task.dart';

class ProductService {
  final CollectionReference<Task> _tasks = FirebaseFirestore.instance.collection('tasks');

  Future<void> addTask(Task task) async {
    await _tasks.add(task.toJson());
  }

  Future<void> updateTask(String id, Task task) async {
    await _tasks.doc(id).update(task.toJson());
  }

  Future<void> deleteTask(String id) async {
    await _tasks.doc(id).delete();
  }
}

