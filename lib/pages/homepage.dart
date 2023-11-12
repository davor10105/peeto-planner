import 'package:flutter/material.dart';
import 'package:peeto_planner/components/calendar.dart';
import 'package:peeto_planner/components/task.dart';
import 'package:peeto_planner/components/timeline.dart';
import 'package:peeto_planner/main.dart';
import 'package:peeto_planner/pages/add_task.dart';
import 'package:peeto_planner/utils/pages.dart';
import 'package:peeto_planner/utils/task_type.dart';
import 'package:provider/provider.dart';

import '../components/appbar.dart';
import '../components/tasktype_listview.dart';

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

class HomePage extends StatefulWidget {
  final PlannerState plannerState;
  const HomePage({super.key, required this.plannerState});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
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
    return DefaultTabController(
      length: 3,
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            leading: Image.asset(
              'lib/images/cat.gif',
              height: 50,
            ),
            title: Text(
              'Peeto Planner',
              style: TextStyle(fontSize: 36, color: Colors.blueGrey),
            ),
            bottom: const TabBar(
              labelColor: Colors.blueGrey,
              tabs: [
                Tab(
                  icon: Icon(Icons.task),
                  text: 'Tasks',
                ),
                Tab(
                  icon: Icon(Icons.calendar_month),
                  text: 'Calendar',
                ),
                Tab(
                  icon: Icon(Icons.timeline),
                  text: 'Timeline',
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            icon: const Icon(Icons.add),
            label: Text('Add Task'),
            onPressed: () {
              widget.plannerState.setCurrentTask(null);
              //Navigator.pushNamed(context, '/add_task');
              showModalBottomSheet<void>(
                backgroundColor: Colors.transparent,
                isScrollControlled: true,
                transitionAnimationController: bottomDrawerController,
                context: context,
                builder: (BuildContext context) {
                  return FractionallySizedBox(
                    heightFactor: 0.9,
                    child: AddTaskPage(plannerState: widget.plannerState),
                  );
                },
              );
            },
          ),
          body: TabBarView(
            children: [
              TaskTypeListView(plannerState: widget.plannerState),
              CalendarView(plannerState: widget.plannerState),
              TimelineView(plannerState: widget.plannerState),
            ],
          ),
        ),
      ),
    );
  }
}
