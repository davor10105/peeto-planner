import 'package:flutter_quill/flutter_quill.dart';
import 'package:hive/hive.dart';
import 'package:peeto_planner/utils/task_type.dart';
import 'package:uuid/uuid.dart';

part 'task.g.dart';

@HiveType(typeId: 1)
class PlannerTask {
  @HiveField(0)
  late String title;

  @HiveField(1)
  late String description;

  @HiveField(2)
  late String textDescription;

  @HiveField(3)
  late PlannerTaskType taskType;

  @HiveField(4)
  late DateTime startTime;

  @HiveField(5)
  DateTime? endTime;

  @HiveField(6, defaultValue: false)
  bool isDone = false;

  @HiveField(7)
  late String uuid;

  PlannerTask(this.title, this.description, this.textDescription, this.taskType,
      this.startTime, this.endTime, String? uuid) {
    this.uuid = uuid ?? const Uuid().v4();
  }
}
