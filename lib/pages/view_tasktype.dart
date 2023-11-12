import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:peeto_planner/components/task.dart';
import 'package:peeto_planner/main.dart';
import 'package:peeto_planner/pages/add_task.dart';
import 'package:peeto_planner/utils/pages.dart';
import 'package:peeto_planner/utils/task_type.dart';
import 'package:provider/provider.dart';

import '../components/appbar.dart';

List<Widget> getTaskContainers(
    PlannerState plannerState,
    BuildContext context,
    PlannerTaskType currentPlannerTaskType,
    AnimationController bottomDrawerController) {
  List<Widget> taskContainers = [];
  for (var task in plannerState.tasks.values) {
    if (currentPlannerTaskType.typeName != task.taskType.typeName) {
      continue;
    }
    taskContainers.add(Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: InkWell(
        onTap: () {
          plannerState.setCurrentTask(task);
          //Navigator.pushNamed(context, '/add_task');
          showModalBottomSheet<void>(
            backgroundColor: Colors.transparent,
            isScrollControlled: true,
            transitionAnimationController: bottomDrawerController,
            context: context,
            builder: (BuildContext context) {
              return FractionallySizedBox(
                  heightFactor: 0.85,
                  child: AddTaskPage(plannerState: plannerState));
            },
          );
        },
        child: Slidable(
          // Specify a key if the Slidable is dismissible.
          //key: const ValueKey(0),
          direction: Axis.horizontal,

          // The start action pane is the one at the left or the top side.
          endActionPane: ActionPane(
            extentRatio: 0.8,
            // A motion is a widget used to control how the pane animates.
            motion: const BehindMotion(),

            // A pane can dismiss the Slidable.
            //dismissible: DismissiblePane(onDismissed: () {}),

            // All actions are defined in the children parameter.
            children: [
              // A SlidableAction can have an icon and/or a label.
              SlidableAction(
                onPressed: (context) {
                  if (!task.isDone) {
                    plannerState.completeTask(task);
                  } else {
                    plannerState.uncompleteTask(task);
                  }
                },
                flex: 2,
                backgroundColor:
                    task.isDone ? Colors.blueGrey : Colors.greenAccent,
                foregroundColor: Colors.white,
                icon: Icons.check,
                label: task.isDone ? 'Un-Complete' : 'Complete',
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(8.0),
                  topLeft: Radius.circular(8.0),
                ),
              ),
              SlidableAction(
                onPressed: (context) {
                  plannerState.deleteTask(task);
                  print('DELETED');
                },
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                icon: Icons.delete,
                label: 'Delete',
                borderRadius: const BorderRadius.only(
                  bottomRight: Radius.circular(8.0),
                  bottomLeft: Radius.circular(8.0),
                ),
              ),
            ],
          ),
          child: /*ListTile(
            title: Text(
              task.title,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            subtitle: Text(
              task.textDescription,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ), */
              Container(
            clipBehavior: Clip.hardEdge,
            height: 150,
            decoration: BoxDecoration(
                color: Color.fromARGB(255, 223, 239, 252),
                border: Border.all(
                  color: Color.fromARGB(255, 190, 225, 253),
                ),
                borderRadius: BorderRadius.all(Radius.circular(8.0))),
            child: Center(
                child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Center(
                          child: Text(
                            task.title,
                            style: TextStyle(
                              color: Colors.blueAccent,
                            ),
                          ),
                        ),
                      ),
                      task.isDone ? Icon(Icons.check) : Container(),
                    ],
                  ),
                  Text(
                    task.textDescription,
                    style: TextStyle(
                      color: const Color.fromARGB(255, 163, 204, 238),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )),
          ),
        ),
        /*Container(
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
        ),*/
      ),
    ));
  }
  return taskContainers;
}

class ViewTaskTypePage extends StatefulWidget {
  final PlannerState plannerState;
  final PlannerTaskType currentPlannerTaskType;
  const ViewTaskTypePage(
      {super.key,
      required this.plannerState,
      required this.currentPlannerTaskType});

  @override
  State<ViewTaskTypePage> createState() => _ViewTaskTypePageState();
}

class _ViewTaskTypePageState extends State<ViewTaskTypePage>
    with TickerProviderStateMixin {
  late AnimationController bottomDrawerController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    bottomDrawerController = BottomSheet.createAnimationController(this);
    bottomDrawerController.duration = const Duration(milliseconds: 500);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    bottomDrawerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //var plannerState = context.watch<PlannerState>();
    /*return SafeArea(
      child: Scaffold(
          appBar: getPeetoAppBar(context),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              plannerState.setCurrentTask(null);
              Navigator.pushNamed(context, '/add_task');
            },
            child: Icon(Icons.add),
          ),
          //body: ListView(children: getTaskContainers(plannerState, context)))
          body: GridView.count(
            primary: false,
            padding: const EdgeInsets.all(20),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            crossAxisCount: 2,
            children: getTaskContainers(plannerState, context),
          )),
    );*/

    return Column(
        children: getTaskContainers(widget.plannerState, context,
            widget.currentPlannerTaskType, bottomDrawerController));
  }
}
