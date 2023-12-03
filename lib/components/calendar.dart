import 'package:flutter/material.dart';
import 'package:peeto_planner/components/task.dart';
import 'package:peeto_planner/main.dart';
import 'package:table_calendar/table_calendar.dart';

import '../pages/add_task.dart';
import 'tasktype_listview.dart';

class CalendarView extends StatefulWidget {
  final PlannerState plannerState;
  const CalendarView({super.key, required this.plannerState});

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView>
    with TickerProviderStateMixin {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();
  late List<PlannerTask> selectedTasks;
  late AnimationController bottomDrawerController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    bottomDrawerController = BottomSheet.createAnimationController(this);
    bottomDrawerController.duration = const Duration(milliseconds: 500);

    selectedTasks = getEventsForDay(DateTime.now());
  }

  @override
  void dispose() {
    // TODO: implement dispose
    bottomDrawerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    DateTime today = DateTime.now();
    List<Widget> listTiles = getListTileContainers();
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                    color: Color.fromARGB(83, 0, 0, 0),
                    blurRadius: 8,
                    spreadRadius: 2),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TableCalendar(
                firstDay: today.subtract(const Duration(days: 365)),
                lastDay: today.add(const Duration(days: 365)),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                calendarStyle: const CalendarStyle(
                  markerSize: 10,
                  markerDecoration: BoxDecoration(
                    color: Colors.lightBlueAccent,
                    shape: BoxShape.circle,
                  ),
                  weekendDecoration: BoxDecoration(
                    color: Color.fromARGB(25, 3, 168, 244),
                    shape: BoxShape.circle,
                  ),
                  weekendTextStyle: TextStyle(
                    color: Colors.blueGrey,
                  ),
                ),
                startingDayOfWeek: StartingDayOfWeek.monday,
                daysOfWeekStyle: const DaysOfWeekStyle(
                    weekdayStyle: TextStyle(fontSize: 12),
                    weekendStyle: TextStyle(fontSize: 12)),
                eventLoader: getEventsForDay,
                selectedDayPredicate: (day) {
                  // Use `selectedDayPredicate` to determine which day is currently selected.
                  // If this returns true, then `day` will be marked as selected.

                  // Using `isSameDay` is recommended to disregard
                  // the time-part of compared DateTime objects.
                  return isSameDay(_selectedDay, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  if (!isSameDay(_selectedDay, selectedDay)) {
                    // Call `setState()` when updating the selected day
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                      selectedTasks = getEventsForDay(selectedDay);
                    });
                  }
                },
                onFormatChanged: (format) {
                  if (_calendarFormat != format) {
                    // Call `setState()` when updating calendar format
                    setState(() {
                      _calendarFormat = format;
                    });
                  }
                },
                onPageChanged: (focusedDay) {
                  // No need to call `setState()` here
                  _focusedDay = focusedDay;
                },
              ),
            ),
          ),
          const SizedBox(height: 16.0),
          listTiles.isEmpty
              ? Container()
              : Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                    boxShadow: [
                      BoxShadow(
                          color: Color.fromARGB(83, 0, 0, 0),
                          blurRadius: 8,
                          spreadRadius: 2),
                    ],
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(
                          'Tasks for date: ${_selectedDay!.day.toString().padLeft(2, "0")}.${_selectedDay!.month.toString().padLeft(2, "0")}.${_selectedDay!.year}',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Divider(),
                      Column(children: listTiles)
                    ],
                  ),
                ),
        ],
      ),
    );
  }

  List<PlannerTask> getEventsForDay(DateTime day) {
    List<PlannerTask> dayTasks = [];
    for (var task in widget.plannerState.tasks.values) {
      if (task.startTime.year == day.year &&
          task.startTime.month == day.month &&
          task.startTime.day == day.day) {
        dayTasks.add(task);
      } else if (task.endTime != null) {
        if (day.isBefore(task.endTime!) && day.isAfter(task.startTime)) {
          dayTasks.add(task);
        }
      }
    }
    return dayTasks;
  }

  List<Widget> getListTileContainers() {
    List<Widget> listContainers = [];
    for (var selectedTask in selectedTasks) {
      Widget container = ListTile(
        onTap: () {
          widget.plannerState.setCurrentTask(selectedTask);
          //Navigator.pushNamed(context, '/add_task');
          showModalBottomSheet<void>(
            backgroundColor: Colors.transparent,
            isScrollControlled: true,
            transitionAnimationController: bottomDrawerController,
            context: context,
            builder: (BuildContext context) {
              return FractionallySizedBox(
                  heightFactor: 0.85,
                  child: AddTaskPage(plannerState: widget.plannerState));
            },
          );
        },
        title: Text('${selectedTask.title}'),
        trailing: Image.asset(
          imagePathFromTaskTypeName[selectedTask.taskType.typeName]!,
          height: 30,
        ),
        leading: selectedTask.isDone
            ? Image.asset(
                'lib/images/verified.gif',
                height: 30,
              )
            : Image.asset(
                'lib/images/letter-x.gif',
                height: 30,
              ),
      );
      if (listContainers.isNotEmpty) {
        listContainers.add(const Divider());
      }
      listContainers.add(container);
    }

    return listContainers;
  }
}
