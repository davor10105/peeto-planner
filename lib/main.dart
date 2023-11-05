import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:peeto_planner/pages/homepage.dart';
import 'package:peeto_planner/utils/task_type.dart';
import 'package:provider/provider.dart';
import 'components/task.dart';
import 'pages/add_task.dart';
import 'pages/view_tasktype.dart';
import 'utils/pages.dart';

void main() async {
  await Hive.initFlutter();

  Hive.registerAdapter(PlannerTaskAdapter());
  Hive.registerAdapter(PlannerTaskTypeAdapter());

  await Hive.openBox<PlannerTask>('planner-tasks');
  runApp(const MainApp());
}

class PlannerState extends ChangeNotifier {
  var tasks = Hive.box<PlannerTask>('planner-tasks');

  List<PlannerTaskType> taskTypes = [
    PlannerTaskType('School'),
    PlannerTaskType('Work'),
    PlannerTaskType('Fun'),
    PlannerTaskType('Other'),
  ];

  //Map<String, PlannerTask> tasks = {};

  PlannerPage currentPage = PlannerPage.HOME_PAGE;
  PlannerTask? currentTask;
  PlannerTaskType? currentTaskType;

  get title => null;

  void addTask(PlannerTask task) {
    //var taskBox = Hive.box<PlannerTask>('planner-tasks');
    tasks.put(task.uuid, task);
    //tasks.put(task.uuid, task);
    notifyListeners();
  }

  void addTaskType(String taskTypeName) {
    taskTypes.add(PlannerTaskType(taskTypeName));
    notifyListeners();
  }

  void setPage(PlannerPage page) {
    currentPage = page;
    notifyListeners();
  }

  void setCurrentTask(PlannerTask? task) {
    currentTask = task;
    notifyListeners();
  }

  void setCurrentTaskType(PlannerTaskType? taskType) {
    currentTaskType = taskType;
    notifyListeners();
  }
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => PlannerState(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.light,
        title: 'Peeto Planner',
        initialRoute: '/',
        routes: {
          '/': (context) =>
              HomePage(plannerState: context.watch<PlannerState>()),
          '/add_task': (context) =>
              AddTaskPage(plannerState: context.watch<PlannerState>()),
          '/view_tasktype': (context) => const ViewTaskTypePage(),
        },
        theme: ThemeData(
          primaryColor: Colors.black,
          scaffoldBackgroundColor: Colors.grey[500],

          // Define the default font family.
          fontFamily: 'Roboto',

          // Define the default `TextTheme`. Use this to specify the default
          // text styling for headlines, titles, bodies of text, and more.
          textTheme: TextTheme(
            displayLarge: TextStyle(fontSize: 72, fontWeight: FontWeight.bold),
            labelMedium: TextStyle(fontSize: 10),
            labelSmall: TextStyle(fontSize: 8),
            titleLarge: TextStyle(fontSize: 36),
            bodyMedium: TextStyle(
              fontSize: 24,
            ),
            bodySmall: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[400]),
          ),
        ),
      ),
    );
  }
}
