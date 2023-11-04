import 'package:flutter/material.dart';
import 'package:peeto_planner/components/task.dart';
import 'package:peeto_planner/main.dart';

class Timeline extends StatelessWidget {
  const Timeline({
    Key? key,
    required this.children,
    this.indicators,
    this.isLeftAligned = true,
    this.itemGap = 12.0,
    this.gutterSpacing = 4.0,
    this.padding = const EdgeInsets.all(8),
    this.controller,
    this.lineColor = Colors.grey,
    this.physics,
    this.shrinkWrap = true,
    this.primary = false,
    this.reverse = false,
    this.indicatorSize = 50.0,
    this.lineGap = 4.0,
    this.indicatorColor = Colors.blue,
    this.indicatorStyle = PaintingStyle.fill,
    this.strokeCap = StrokeCap.butt,
    this.strokeWidth = 2.0,
    this.style = PaintingStyle.stroke,
  })  : itemCount = children.length,
        assert(itemGap >= 0),
        assert(lineGap >= 0),
        assert(indicators == null || children.length == indicators.length),
        super(key: key);

  final List<Widget> children;
  final double itemGap;
  final double gutterSpacing;
  final List<Widget>? indicators;
  final bool isLeftAligned;
  final EdgeInsets padding;
  final ScrollController? controller;
  final int itemCount;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final bool primary;
  final bool reverse;

  final Color lineColor;
  final double lineGap;
  final double indicatorSize;
  final Color indicatorColor;
  final PaintingStyle indicatorStyle;
  final StrokeCap strokeCap;
  final double strokeWidth;
  final PaintingStyle style;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: padding,
      separatorBuilder: (_, __) => SizedBox(height: itemGap),
      physics: physics,
      shrinkWrap: shrinkWrap,
      itemCount: itemCount,
      controller: controller,
      reverse: reverse,
      primary: primary,
      itemBuilder: (context, index) {
        final child = children[index];
        final _indicators = indicators;

        Widget? indicator;
        if (_indicators != null) {
          indicator = _indicators[index];
        }

        final isFirst = index == 0;
        final isLast = index == itemCount - 1;

        final timelineTile = <Widget>[
          CustomPaint(
            foregroundPainter: _TimelinePainter(
              hideDefaultIndicator: indicator != null,
              lineColor: lineColor,
              indicatorColor: indicatorColor,
              indicatorSize: indicatorSize,
              indicatorStyle: indicatorStyle,
              isFirst: isFirst,
              isLast: isLast,
              lineGap: lineGap,
              strokeCap: strokeCap,
              strokeWidth: strokeWidth,
              style: style,
              itemGap: itemGap,
            ),
            child: SizedBox(
              height: double.infinity,
              width: indicatorSize,
              child: indicator,
            ),
          ),
          SizedBox(width: gutterSpacing),
          Expanded(child: child),
        ];

        return IntrinsicHeight(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children:
                isLeftAligned ? timelineTile : timelineTile.reversed.toList(),
          ),
        );
      },
    );
  }
}

class _TimelinePainter extends CustomPainter {
  _TimelinePainter({
    required this.hideDefaultIndicator,
    required this.indicatorColor,
    required this.indicatorStyle,
    required this.indicatorSize,
    required this.lineGap,
    required this.strokeCap,
    required this.strokeWidth,
    required this.style,
    required this.lineColor,
    required this.isFirst,
    required this.isLast,
    required this.itemGap,
  })  : linePaint = Paint()
          ..color = lineColor
          ..strokeCap = strokeCap
          ..strokeWidth = strokeWidth
          ..style = style,
        circlePaint = Paint()
          ..color = indicatorColor
          ..style = indicatorStyle;

  final bool hideDefaultIndicator;
  final Color indicatorColor;
  final PaintingStyle indicatorStyle;
  final double indicatorSize;
  final double lineGap;
  final StrokeCap strokeCap;
  final double strokeWidth;
  final PaintingStyle style;
  final Color lineColor;
  final Paint linePaint;
  final Paint circlePaint;
  final bool isFirst;
  final bool isLast;
  final double itemGap;

  @override
  void paint(Canvas canvas, Size size) {
    final indicatorRadius = indicatorSize / 2;
    final halfItemGap = itemGap / 2;
    final indicatorMargin = indicatorRadius + lineGap;

    final top = size.topLeft(Offset(indicatorRadius, 0.0 - halfItemGap));
    final centerTop = size.centerLeft(
      Offset(indicatorRadius, -indicatorMargin),
    );

    final bottom = size.bottomLeft(Offset(indicatorRadius, 0.0 + halfItemGap));
    final centerBottom = size.centerLeft(
      Offset(indicatorRadius, indicatorMargin),
    );

    if (!isFirst) canvas.drawLine(top, centerTop, linePaint);
    if (!isLast) canvas.drawLine(centerBottom, bottom, linePaint);

    if (!hideDefaultIndicator) {
      final Offset offsetCenter = size.centerLeft(Offset(indicatorRadius, 0));

      canvas.drawCircle(offsetCenter, indicatorRadius, circlePaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class TimelineView extends StatelessWidget {
  final PlannerState plannerState;
  const TimelineView({super.key, required this.plannerState});

  @override
  Widget build(BuildContext context) {
    var color = Colors.amber;
    List<List<Widget>> indicatorAndChildren = getIndicatorAndTasks(context);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Timeline(
          indicators: indicatorAndChildren[0],
          children: indicatorAndChildren[1],
        ),
      ),
    );
  }

  List<List<Widget>> getIndicatorAndTasks(BuildContext context) {
    List<Widget> indicators = [];
    Map<DateTime, List<Widget>> tasksFromToday = {};
    DateTime currentTime = DateTime.now();
    for (var task in plannerState.tasks.values) {
      if (task.startTime.isAfter(currentTime)) {
        DateTime reducedTime = DateTime(
            task.startTime.year, task.startTime.month, task.startTime.day);
        if (!tasksFromToday.containsKey(reducedTime)) {
          tasksFromToday[reducedTime] = [];
        }
        tasksFromToday[reducedTime]!.add(getTaskButton(context, task, true));
      }
      if (task.endTime != null) {
        if (task.endTime!.isAfter(currentTime)) {
          DateTime reducedTime = DateTime(
              task.endTime!.year, task.endTime!.month, task.endTime!.day);
          if (!tasksFromToday.containsKey(reducedTime)) {
            tasksFromToday[reducedTime] = [];
          }
          tasksFromToday[reducedTime]!.add(getTaskButton(context, task, false));
        }
      }
    }

    var sortedTasksFromToday = Map.fromEntries(tasksFromToday.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key)));

    List<Widget> combinedTasksFromToday = [];
    for (var entry in sortedTasksFromToday.entries) {
      combinedTasksFromToday.add(Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey,
                spreadRadius: 2.0,
                blurRadius: 3.0,
              )
            ]),
        child: Column(
          children: entry.value,
        ),
      ));
      indicators.add(Center(
        child: Text(
          '${entry.key.day.toString().padLeft(2, '0')}.${entry.key.month.toString().padLeft(2, '0')}.${entry.key.year.toString().padLeft(2, '0')}',
          style: TextStyle(
            fontSize: 8,
          ),
        ),
      ));
    }

    return [indicators, combinedTasksFromToday];
  }

  Widget getTaskButton(BuildContext context, PlannerTask task, bool isStart) {
    return InkWell(
        onTap: () {
          plannerState.setCurrentTask(task);
          Navigator.pushNamed(context, '/add_task');
        },
        child: Text(task.title));
  }
}
