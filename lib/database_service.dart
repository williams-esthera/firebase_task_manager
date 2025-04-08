import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._internal();
  DatabaseService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Authentication methods
  Future<String?> verifyLogin(String username, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: username,
        password: password,
      );
      return userCredential.user?.uid;
    } catch (e) {
      return null;
    }
  }

  Future<String?> addLogin(String username, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: username,
        password: password,
      );
      
      // Store additional user data in Firestore
      await _firestore.collection('users').doc(userCredential.user?.uid).set({
        'username': username,
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      return userCredential.user?.uid;
    } catch (e) {
      return null;
    }
  }

  Future<bool> isUsernameTaken(String username) async {
    final querySnapshot = await _firestore
        .collection('users')
        .where('username', isEqualTo: username)
        .get();
    return querySnapshot.docs.isNotEmpty;
  }

  // Task methods
  Future<void> addTask(String userId, String taskName) async {
    await _firestore.collection('tasks').add({
      'userId': userId,
      'taskName': taskName,
      'isCompleted': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteTask(String taskId) async {
    await _firestore.collection('tasks').doc(taskId).delete();
  }

  Future<void> toggleTaskCompletion(String taskId, bool isCompleted) async {
    await _firestore.collection('tasks').doc(taskId).update({
      'isCompleted': isCompleted,
    });
  }

  Stream<QuerySnapshot> getTasks(String userId) {
    return _firestore
        .collection('tasks')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
} 