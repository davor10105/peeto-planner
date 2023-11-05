import 'package:hive/hive.dart';

part 'task_type.g.dart';

@HiveType(typeId: 2)
class PlannerTaskType {
  @HiveField(0)
  final String typeName;

  PlannerTaskType(this.typeName);
}
