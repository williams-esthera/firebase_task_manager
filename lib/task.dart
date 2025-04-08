class Task {
  final String name;
  final bool isCompleted;
  //nested list
  final List<String> subtasks;

  Task({required this.name, required this.isCompleted, required this.subtasks});

  //get task name
  String getTaskName() {
    return name;
  }

  //get task is completed
  bool getTaskIsCompleted() {
    return isCompleted;
  }

  //get task subtasks
  List<String> getTaskSubtasks() {
    return subtasks;  
  }

  //to json
  Map<String, dynamic> toJson() {
    return {'name': name, 'isCompleted': isCompleted, 'subtasks': subtasks};
  }
}
