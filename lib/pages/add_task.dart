import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:peeto_planner/components/tasktype_listview.dart';
import 'package:provider/provider.dart';

import '../components/appbar.dart';
import '../components/task.dart';
import '../main.dart';
import '../utils/task_type.dart';

double toDouble(TimeOfDay myTime) => myTime.hour + myTime.minute / 60.0;

class AddTaskPage extends StatefulWidget {
  final PlannerState plannerState;
  const AddTaskPage({super.key, required this.plannerState});

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  late TextEditingController titleController;
  late TextEditingController descriptionController = TextEditingController();
  QuillController _controller = QuillController.basic();
  late PlannerTaskType selectedTaskType;
  late DateTime selectedStartTime;
  DateTime? selectedEndTime;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    titleController = TextEditingController(
        text: widget.plannerState.currentTask == null
            ? 'New Title'
            : widget.plannerState.currentTask!.title);
    selectedTaskType = widget.plannerState.currentTask != null
        ? widget.plannerState.currentTask!.taskType
        : widget.plannerState.taskTypes.first;
    _controller = widget.plannerState.currentTask != null
        ? QuillController(
            document: Document.fromJson(
                jsonDecode(widget.plannerState.currentTask!.description)),
            selection: const TextSelection.collapsed(offset: 0),
          )
        : QuillController.basic();

    if (widget.plannerState.currentTask != null) {
      selectedStartTime = widget.plannerState.currentTask!.startTime;
      selectedEndTime = widget.plannerState.currentTask!.endTime;
    } else {
      selectedStartTime = DateTime.now();
    }
  }

  @override
  Widget build(BuildContext context) {
    var plannerState = widget.plannerState;
    DateTime currentDateTime = DateTime.now();

    return QuillProvider(
      configurations: QuillConfigurations(
        controller: _controller,
        sharedConfigurations: const QuillSharedConfigurations(
          locale: Locale('en'),
        ),
      ),
      child: Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8.0),
                  topRight: Radius.circular(8.0),
                ),
                color: Colors.white,
              ),
              child: Column(
                children: [
                  // top container
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.blueGrey,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8.0),
                        topRight: Radius.circular(8.0),
                      ),
                    ),
                    child: Column(
                      children: [
                        // buttons
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              InkWell(
                                onTap: () => Navigator.pop(context),
                                child: const Row(
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 8.0),
                                      child: Icon(
                                        Icons.arrow_back,
                                        color: Colors.white60,
                                        size: 20,
                                      ),
                                    ),
                                    Text(
                                      'Return',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Text(
                                'Create a new task',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white70,
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  var descriptionDelta = jsonEncode(
                                      _controller.document.toDelta().toJson());
                                  var textDescription =
                                      _controller.document.toPlainText();
                                  plannerState.addTask(
                                    PlannerTask(
                                        titleController.text,
                                        descriptionDelta,
                                        textDescription,
                                        selectedTaskType,
                                        selectedStartTime,
                                        selectedEndTime,
                                        plannerState.currentTask != null
                                            ? plannerState.currentTask!.uuid
                                            : null),
                                  );
                                  Navigator.pop(context);
                                },
                                child: const Row(
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 8.0),
                                      child: Icon(
                                        Icons.save,
                                        color: Colors.white60,
                                        size: 20,
                                      ),
                                    ),
                                    Text(
                                      'Save',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // title
                        Padding(
                          padding: const EdgeInsets.only(
                            top: 16.0,
                            left: 16.0,
                          ),
                          child: TextFormField(
                            style: TextStyle(
                              fontSize: 24,
                              color: Colors.white,
                            ),
                            controller: titleController,
                          ),
                        ),

                        // task type
                        /*Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            DropdownMenu<PlannerTaskType>(
                              textStyle: TextStyle(color: Colors.white),
                              width: 300,
                              initialSelection:
                                  plannerState.currentTaskType != null
                                      ? plannerState.currentTaskType
                                      : plannerState.taskTypes.first,
                              onSelected: (PlannerTaskType? newType) {
                                // This is called when the user selects an item.
                                setState(() {
                                  selectedTaskType = newType!;
                                });
                              },
                              dropdownMenuEntries: plannerState.taskTypes
                                  .map<DropdownMenuEntry<PlannerTaskType>>(
                                      (PlannerTaskType taskType) {
                                return DropdownMenuEntry<PlannerTaskType>(
                                    value: taskType, label: taskType.typeName);
                              }).toList(),
                            ),
                          ],
                        ),*/

                        // date buttons
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // start date
                              InkWell(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Icon(
                                          Icons.timer_outlined,
                                          size: 14,
                                          color: Colors.white70,
                                        ),
                                        SizedBox(
                                          width: 3,
                                        ),
                                        Text(
                                          'Start',
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      '${selectedStartTime.day.toString().padLeft(2, '0')}.${selectedStartTime.month.toString().padLeft(2, '0')}.${selectedStartTime.year}',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      '${selectedStartTime.hour.toString().padLeft(2, '0')}:${selectedStartTime.minute.toString().padLeft(2, '0')}',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    )
                                  ],
                                ),
                                onTap: () async {
                                  final date = await showDatePicker(
                                      context: context,
                                      initialDate: currentDateTime,
                                      firstDate: currentDateTime
                                          .subtract(const Duration(days: 365)),
                                      lastDate: currentDateTime
                                          .add(const Duration(days: 365)));
                                  if (date == null) return;

                                  if (mounted) {
                                    final time = await showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.now(),
                                    );
                                    if (time == null) return;
                                    setState(() {
                                      selectedStartTime = DateTime(
                                        date.year,
                                        date.month,
                                        date.day,
                                        time.hour,
                                        time.minute,
                                      );
                                    });
                                  }
                                },
                              ),

                              // end date
                              InkWell(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Icon(
                                          Icons.timer_outlined,
                                          size: 14,
                                          color: Colors.white70,
                                        ),
                                        SizedBox(
                                          width: 3,
                                        ),
                                        Text(
                                          'End',
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                    selectedEndTime == null
                                        ? Text(
                                            'Not set',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                            ),
                                          )
                                        : Text(
                                            '${selectedEndTime!.day.toString().padLeft(2, '0')}.${selectedEndTime!.month.toString().padLeft(2, '0')}.${selectedEndTime!.year}',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                            ),
                                          ),
                                    selectedEndTime == null
                                        ? Container()
                                        : Text(
                                            '${selectedEndTime!.hour.toString().padLeft(2, '0')}:${selectedEndTime!.minute.toString().padLeft(2, '0')}',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                            ),
                                          ),
                                  ],
                                ),
                                onTap: () async {
                                  final date = await showDatePicker(
                                    context: context,
                                    initialDate:
                                        selectedEndTime ?? selectedStartTime,
                                    firstDate:
                                        selectedEndTime ?? selectedStartTime,
                                    lastDate:
                                        (selectedEndTime ?? selectedStartTime)
                                            .add(Duration(days: 365)),
                                  );
                                  if (date == null) return;

                                  if (mounted) {
                                    final time = await showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.fromDateTime(
                                          selectedEndTime ?? selectedStartTime),
                                    );
                                    if (time == null) return;
                                    if (mounted) {
                                      DateTime newEndTime = DateTime(
                                          date.year,
                                          date.month,
                                          date.day,
                                          time.hour,
                                          time.minute);
                                      if (newEndTime
                                          .isBefore(selectedStartTime)) {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: const Text('Miu!'),
                                              content: const Text(
                                                'End time must be after start time',
                                              ),
                                              actions: <Widget>[
                                                TextButton(
                                                  style: TextButton.styleFrom(
                                                    textStyle: Theme.of(context)
                                                        .textTheme
                                                        .labelLarge,
                                                  ),
                                                  child: const Text('OK'),
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                        return;
                                      }
                                      setState(() {
                                        selectedEndTime = newEndTime;
                                      });
                                    }
                                  }
                                },
                              ),

                              // task type
                              PopupMenuButton<PlannerTaskType>(
                                color: Colors.white,
                                initialValue: plannerState.currentTaskType ??
                                    plannerState.taskTypes.first,
                                // Callback that sets the selected popup menu item.
                                onSelected: (PlannerTaskType newType) {
                                  setState(() {
                                    selectedTaskType = newType;
                                  });
                                },
                                itemBuilder: (BuildContext context) =>
                                    plannerState.taskTypes
                                        .map<PopupMenuItem<PlannerTaskType>>(
                                            (PlannerTaskType taskType) {
                                  return PopupMenuItem<PlannerTaskType>(
                                    value: taskType,
                                    child: Text(taskType.typeName),
                                  );
                                }).toList(),
                                child: Column(
                                  children: [
                                    const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Icon(
                                          Icons.task,
                                          size: 14,
                                          color: Colors.white70,
                                        ),
                                        SizedBox(
                                          width: 3,
                                        ),
                                        Text(
                                          'Type',
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 3.0),
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(3.0),
                                            child: Image.asset(
                                              imagePathFromTaskTypeName[
                                                  selectedTaskType.typeName]!,
                                              height: 30,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  QuillToolbarProvider(
                    toolbarConfigurations: const QuillToolbarConfigurations(),
                    child: QuillBaseToolbar(
                      configurations: QuillBaseToolbarConfigurations(
                        toolbarSize: 15 * 2,
                        color: Colors.white,
                        multiRowsDisplay: false,
                        childrenBuilder: (context) {
                          final controller = context.requireQuillController;
                          return [
                            QuillToolbarHistoryButton(
                              controller: controller,
                              options: const QuillToolbarHistoryButtonOptions(
                                  isUndo: true),
                            ),
                            QuillToolbarHistoryButton(
                              controller: controller,
                              options: const QuillToolbarHistoryButtonOptions(
                                  isUndo: false),
                            ),
                            QuillToolbarToggleStyleButton(
                              attribute: Attribute.bold,
                              controller: controller,
                              options:
                                  const QuillToolbarToggleStyleButtonOptions(
                                iconData: Icons.format_bold,
                                iconSize: 20,
                              ),
                            ),
                            QuillToolbarToggleStyleButton(
                              attribute: Attribute.italic,
                              controller: controller,
                              options:
                                  const QuillToolbarToggleStyleButtonOptions(
                                iconData: Icons.format_italic,
                                iconSize: 20,
                              ),
                            ),
                            QuillToolbarToggleStyleButton(
                              attribute: Attribute.underline,
                              controller: controller,
                              options:
                                  const QuillToolbarToggleStyleButtonOptions(
                                iconData: Icons.format_underline,
                                iconSize: 20,
                              ),
                            ),
                            QuillToolbarClearFormatButton(
                              controller: controller,
                              options:
                                  const QuillToolbarClearFormatButtonOptions(
                                iconData: Icons.format_clear,
                                iconSize: 20,
                              ),
                            ),
                            QuillToolbarToggleCheckListButton(
                                options:
                                    QuillToolbarToggleCheckListButtonOptions(),
                                controller: controller),
                            QuillToolbarSelectHeaderStyleButtons(
                              controller: controller,
                              options:
                                  const QuillToolbarSelectHeaderStyleButtonsOptions(
                                iconSize: 20,
                              ),
                            ),
                            QuillToolbarToggleStyleButton(
                              attribute: Attribute.ol,
                              controller: controller,
                              options:
                                  const QuillToolbarToggleStyleButtonOptions(
                                iconData: Icons.format_list_numbered,
                                iconSize: 20,
                              ),
                            ),
                            QuillToolbarToggleStyleButton(
                              attribute: Attribute.ul,
                              controller: controller,
                              options:
                                  const QuillToolbarToggleStyleButtonOptions(
                                iconData: Icons.format_list_bulleted,
                                iconSize: 20,
                              ),
                            ),
                            QuillToolbarColorButton(
                                controller: controller, isBackground: false),
                            QuillToolbarColorButton(
                              controller: controller,
                              isBackground: true,
                            ),
                          ];
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    child: QuillEditor.basic(
                      configurations: const QuillEditorConfigurations(
                        padding: EdgeInsets.all(16.0),
                        readOnly: false,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
