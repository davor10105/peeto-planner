import 'package:flutter/material.dart';
import 'package:peeto_planner/main.dart';

import '../pages/view_tasktype.dart';
import '../utils/task_type.dart';
import 'task.dart';

class TaskTypeListView extends StatelessWidget {
  final PlannerState plannerState;
  const TaskTypeListView({super.key, required this.plannerState});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: plannerState.taskTypes.length,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: const EdgeInsets.all(2.0),
            child: /*InkWell(
              onTap: () {
                plannerState.setCurrentTaskType(plannerState.taskTypes[index]);
                Navigator.pushNamed(context, '/view_tasktype');
              },
              child: Container(
                height: 50,
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(8.0))),
                child: Center(
                    child: Row(
                  children: [
                    Text('${plannerState.taskTypes[index].typeName}'),
                    getTaskTypeInfo(
                        context, plannerState, plannerState.taskTypes[index]),
                  ],
                )),
              ),
            ),*/
                Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: ExpansionTile(
                title: Text(plannerState.taskTypes[index].typeName),
                subtitle: getTaskTypeInfo(
                    context, plannerState, plannerState.taskTypes[index]),
                children: <Widget>[
                  ViewTaskTypePage(
                    plannerState: plannerState,
                    currentPlannerTaskType: plannerState.taskTypes[index],
                  ),
                ],
              ),
            ),
          );
        });
  }

  Widget getTaskTypeInfo(BuildContext context, PlannerState plannerState,
      PlannerTaskType taskType) {
    List<PlannerTask> tasks = [];
    int completedTasks = 0;

    for (var task in plannerState.tasks.values) {
      if (task.taskType.typeName != taskType.typeName) continue;
      tasks.add(task);
      if (task.isDone) completedTasks += 1;
    }

    return Row(
      children: [
        Text(
          'Num: ${tasks.length}',
          style: Theme.of(context).textTheme.labelMedium,
        ),
        SizedBox(
          width: 20,
        ),
        Text(
          'Completed: ${completedTasks}',
          style: Theme.of(context).textTheme.labelMedium,
        ),
      ],
    );
  }
}
