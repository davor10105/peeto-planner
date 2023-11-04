import 'package:flutter/material.dart';
import 'package:peeto_planner/components/task.dart';
import 'package:peeto_planner/main.dart';
import 'package:peeto_planner/pages/add_task.dart';
import 'package:peeto_planner/utils/pages.dart';
import 'package:peeto_planner/utils/task_type.dart';
import 'package:provider/provider.dart';

import '../components/appbar.dart';

List<Widget> getTaskContainers(
    PlannerState plannerState, BuildContext context) {
  List<Widget> taskContainers = [];
  for (var task in plannerState.tasks.values) {
    print(plannerState.currentTaskType!.typeName);
    print(task.taskType.typeName);
    if (plannerState.currentTaskType!.typeName != task.taskType.typeName) {
      continue;
    }
    taskContainers.add(InkWell(
      onTap: () {
        plannerState.setCurrentTask(task);
        Navigator.pushNamed(context, '/add_task');
      },
      child: Container(
        clipBehavior: Clip.hardEdge,
        height: 50,
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(8.0))),
        child: Center(
            child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                task.title,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                task.textDescription,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        )),
      ),
    ));
  }
  return taskContainers;
}

class ViewTaskTypePage extends StatelessWidget {
  const ViewTaskTypePage({super.key});

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
          body: GridView.count(
            primary: false,
            padding: const EdgeInsets.all(20),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            crossAxisCount: 2,
            children: getTaskContainers(plannerState, context),
          )),
    );
  }
}
