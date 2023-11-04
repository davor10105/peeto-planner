import 'package:flutter/material.dart';
import 'package:peeto_planner/components/task.dart';
import 'package:peeto_planner/main.dart';
import 'package:peeto_planner/pages/add_task.dart';
import 'package:peeto_planner/utils/pages.dart';
import 'package:peeto_planner/utils/task_type.dart';
import 'package:provider/provider.dart';

import '../components/appbar.dart';

List<Widget> getTaskContainers(PlannerState plannerState) {
  List<Widget> taskContainers = [];
  for (var task in plannerState.tasks.values) {
    taskContainers.add(Container(
      height: 50,
      child: Center(child: Text('${task.title}')),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(8.0))),
    ));
  }
  return taskContainers;
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    var plannerState = context.watch<PlannerState>();
    return SafeArea(
      child: Scaffold(
        appBar: getPeetoAppBar(context),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            plannerState.setCurrentTask(null);
            Navigator.pushNamed(context, '/add_task');
          },
          child: Icon(Icons.add),
        ),
        body: /*GridView.count(
            primary: false,
            padding: const EdgeInsets.all(20),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            crossAxisCount: 2,
            children: getTaskContainers(plannerState),
          ) */
            ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: plannerState.taskTypes.length,
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: InkWell(
                      onTap: () {
                        plannerState
                            .setCurrentTaskType(plannerState.taskTypes[index]);
                        Navigator.pushNamed(context, '/view_tasktype');
                      },
                      child: Container(
                        height: 50,
                        child: Center(
                            child: Row(
                          children: [
                            Text('${plannerState.taskTypes[index].typeName}'),
                            getTaskTypeInfo(context, plannerState,
                                plannerState.taskTypes[index]),
                          ],
                        )),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.all(Radius.circular(8.0))),
                      ),
                    ),
                  );
                }),
      ),
    );
  }

  Widget getTaskTypeInfo(BuildContext context, PlannerState plannerState,
      PlannerTaskType taskType) {
    List<PlannerTask> tasks = [];
    int completedTasks = 0;
    for (var task in plannerState.tasks.values) {
      if (task.taskType != taskType) continue;
      tasks.add(task);
      if (task.isDone) completedTasks += 1;
    }

    return Row(
      children: [
        Text(
          'Num: ${tasks.length}',
          style: Theme.of(context).textTheme.labelMedium,
        ),
        Text(
          'Completed: ${completedTasks}',
          style: Theme.of(context).textTheme.labelMedium,
        ),
      ],
    );
  }
}
