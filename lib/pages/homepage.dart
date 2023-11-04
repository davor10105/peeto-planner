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

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    var plannerState = context.watch<PlannerState>();
    return DefaultTabController(
      length: 3,
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: const Text('MIU'),
            bottom: const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.task)),
                Tab(icon: Icon(Icons.calendar_month)),
                Tab(icon: Icon(Icons.timeline)),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              plannerState.setCurrentTask(null);
              Navigator.pushNamed(context, '/add_task');
            },
            child: Icon(Icons.add),
          ),
          body: TabBarView(
            children: [
              TaskTypeListView(plannerState: plannerState),
              CalendarView(plannerState: plannerState),
              TimelineView(plannerState: plannerState),
            ],
          ),
        ),
      ),
    );
  }
}
