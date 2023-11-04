import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
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
            ? 'New Task'
            : widget.plannerState.currentTask!.title);
    selectedTaskType = widget.plannerState.currentTaskType != null
        ? widget.plannerState.currentTaskType!
        : widget.plannerState.taskTypes.first;
    _controller = widget.plannerState.currentTask != null
        ? QuillController(
            document: Document.fromDelta(
                widget.plannerState.currentTask!.description),
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

    return SafeArea(
      child: Scaffold(
        appBar: getPeetoAppBar(context),
        body: QuillProvider(
          configurations: QuillConfigurations(
            controller: _controller,
            sharedConfigurations: const QuillSharedConfigurations(
              locale: Locale('en'),
            ),
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(8.0),
                    ),
                    color: Colors.white,
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          controller: titleController,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          // start date
                          MaterialButton(
                            color: Theme.of(context).cardColor,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Start date:',
                                  style: Theme.of(context).textTheme.labelSmall,
                                ),
                                Text(
                                  '${selectedStartTime.day.toString().padLeft(2, '0')}.${selectedStartTime.month.toString().padLeft(2, '0')}.${selectedStartTime.year} - ${selectedStartTime.hour.toString().padLeft(2, '0')}:${selectedStartTime.minute.toString().padLeft(2, '0')}',
                                  style:
                                      Theme.of(context).textTheme.labelMedium,
                                )
                              ],
                            ),
                            onPressed: () async {
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
                          MaterialButton(
                            color: Theme.of(context).cardColor,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'End date:',
                                  style: Theme.of(context).textTheme.labelSmall,
                                ),
                                selectedEndTime == null
                                    ? Text(
                                        'None',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelMedium,
                                      )
                                    : Text(
                                        '${selectedEndTime!.day.toString().padLeft(2, '0')}.${selectedEndTime!.month.toString().padLeft(2, '0')}.${selectedEndTime!.year} - ${selectedEndTime!.hour.toString().padLeft(2, '0')}:${selectedEndTime!.minute.toString().padLeft(2, '0')}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelMedium,
                                      )
                              ],
                            ),
                            onPressed: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate:
                                    selectedEndTime ?? selectedStartTime,
                                firstDate: selectedEndTime ?? selectedStartTime,
                                lastDate: (selectedEndTime ?? selectedStartTime)
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
                                  if (newEndTime.isBefore(selectedStartTime)) {
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
                        ],
                      ),
                      Expanded(
                        child: QuillEditor.basic(
                          configurations: const QuillEditorConfigurations(
                            padding: EdgeInsets.all(16.0),
                            readOnly: false,
                          ),
                        ),
                      ),
                      QuillToolbarProvider(
                        toolbarConfigurations:
                            const QuillToolbarConfigurations(),
                        child: QuillBaseToolbar(
                          configurations: QuillBaseToolbarConfigurations(
                            toolbarSize: 15 * 2,
                            multiRowsDisplay: true,
                            childrenBuilder: (context) {
                              final controller = context.requireQuillController;
                              return [
                                QuillToolbarHistoryButton(
                                  controller: controller,
                                  options:
                                      const QuillToolbarHistoryButtonOptions(
                                          isUndo: true),
                                ),
                                QuillToolbarHistoryButton(
                                  controller: controller,
                                  options:
                                      const QuillToolbarHistoryButtonOptions(
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
                                    controller: controller,
                                    isBackground: false),
                                QuillToolbarColorButton(
                                  controller: controller,
                                  isBackground: true,
                                ),
                              ];
                            },
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          MaterialButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Icon(Icons.arrow_back),
                                ),
                                Text('Return'),
                              ],
                            ),
                          ),
                          MaterialButton(
                            onPressed: () {
                              var descriptionDelta =
                                  _controller.document.toDelta();
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
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Icon(Icons.save_outlined),
                                ),
                                Text('Save'),
                              ],
                            ),
                          ),
                          DropdownMenu<PlannerTaskType>(
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
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
