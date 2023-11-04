import 'package:flutter_quill/flutter_quill.dart';
import 'package:peeto_planner/utils/task_type.dart';
import 'package:uuid/uuid.dart';

class PlannerTask {
  late String title;
  late Delta description;
  late String textDescription;
  late PlannerTaskType taskType;
  bool isDone = false;
  late String uuid;

  PlannerTask(String title, Delta description, String textDescription,
      PlannerTaskType taskType, String? uuid) {
    this.title = title;
    this.description = description;
    this.textDescription = textDescription;
    this.taskType = taskType;
    this.uuid = uuid != null ? uuid : const Uuid().v4();
  }
}
