import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'register_page.dart';
import 'user_state.dart';
import 'database_service.dart';
import 'app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'task.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Task Manager',

       initialRoute: '/register',
      routes: {
        '/register': (context) => const RegisterPage(),
        '/main': (context) => TaskListScreen(title: 'Task Manager', credentials: UserState()),
      },
      theme: ThemeData(
        // This is the theme of your application.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: TaskListScreen(title: 'Task Manager', credentials: UserState()),
    );
  }
}

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key, required this.title, required this.credentials});

  final String title;
  final UserState credentials;
  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final DatabaseService _databaseService = DatabaseService.instance;
  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void addTask(String taskName) {
    if (taskName.isNotEmpty && widget.credentials.userId != null) {
      _databaseService.addTask(widget.credentials.userId!, taskName);
      _textController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.accent2,
        title: Text(widget.title),
        titleTextStyle: const TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.bold,
          color: AppColors.text,
        ),
      ),
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: 'Enter New Task',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  onPressed: () {
                    _textController.clear();
                  },
                  icon: const Icon(Icons.clear),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                addTask(_textController.text);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent1),
              child: const Text("Add", style: TextStyle(color: AppColors.background)),
            ),
            const Divider(
              height: 100,
              color: AppColors.accent1,
              thickness: 2,
              indent: 10,
              endIndent: 10,
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _databaseService.getTasks(widget.credentials.userId ?? ''),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(child: Text('Something went wrong'));
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final tasks = snapshot.data?.docs ?? [];

                  return ListView.separated(
                    itemCount: tasks.length,
                    itemBuilder: (BuildContext context, int index) {
                      final task = tasks[index];
                      final taskData = task.data() as Map<String, dynamic>;
                      final isCompleted = taskData['isCompleted'] ?? false;

                      return ListTile(
                        title: Text(
                          taskData['taskName'] ?? '',
                          style: TextStyle(
                            decoration: isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                          ),
                        ),
                        tileColor: AppColors.accent2,
                        onTap: () {
                          _databaseService.toggleTaskCompletion(task.id, !isCompleted);
                        },
                        leading: Checkbox(
                          value: isCompleted,
                          activeColor: AppColors.accent1,
                          onChanged: (checked) {
                            _databaseService.toggleTaskCompletion(task.id, checked ?? false);
                          },
                        ),
                        trailing: IconButton(
                          onPressed: () {
                            _databaseService.deleteTask(task.id);
                          },
                          icon: const Icon(Icons.delete),
                        ),
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 10),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
