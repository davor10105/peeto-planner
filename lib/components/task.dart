import 'package:flutter_quill/flutter_quill.dart';
import 'package:peeto_planner/utils/task_type.dart';
import 'package:uuid/uuid.dart';

class PlannerTask {
  late String title;
  late Delta description;
  late String textDescription;
  late PlannerTaskType taskType;
  late DateTime startTime;
  DateTime? endTime;
  bool isDone = false;
  late String uuid;

  PlannerTask(this.title, this.description, this.textDescription, this.taskType,
      this.startTime, this.endTime, String? uuid) {
    this.uuid = uuid ?? const Uuid().v4();
  }
}
