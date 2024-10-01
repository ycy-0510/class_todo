import 'package:class_todo_list/logic/calendar_task_notifier.dart';
import 'package:class_todo_list/logic/class_table_notifier.dart';
import 'package:class_todo_list/logic/form_notifier.dart';
import 'package:class_todo_list/logic/task_notifier.dart';
import 'package:class_todo_list/page/home_page.dart';
import 'package:class_todo_list/page/setting_page.dart';
import 'package:class_todo_list/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import 'package:toastification/toastification.dart';

class HomeTaskBody extends ConsumerWidget {
  const HomeTaskBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    TaskViewType taskViewTypeState = ref.watch(taskViewTypeProvider);
    TaskState taskState = ref.watch(taskProvider);
    CalendarTaskState calendarTaskState = ref.watch(calendarTaskProvider);
    ClassTableState classTableState = ref.watch(classTableProvider);
    Map<int, List<Task>> tasksMap = taskState.tasksMap;
    Map<int, List<CalendarTask>> calendarTasksMap = calendarTaskState.tasksMap;

    return LoadingView(
      loading: taskState.loading || classTableState.loading,
      child: PageView.builder(
          controller: PageController(initialPage: 1000),
          onPageChanged: (value) {
            ref.read(dateProvider.notifier).go(value);
            HapticFeedback.selectionClick();
          },
          itemBuilder: (context, idx) {
            List<Task> tasks = tasksMap[idx - 1000] ?? [];
            List<Task> showTasks = [];
            List<CalendarTask> calendarTask =
                calendarTasksMap[idx - 1000] ?? [];
            List<Task> importantTasks = [];
            bool showPast = ref.watch(pastSwitchProvider);
            for (int i = 0; i < tasks.length; i++) {
              if (tasks[i].date.isAfter(ref.watch(nowTimeProvider)) ||
                  showPast) {
                showTasks.add(tasks[i]);
              }
            }
            for (int i = 0; i < tasks.length; i++) {
              if (tasks[i].date.isAfter(ref.watch(nowTimeProvider)) &&
                  tasks[i].top) {
                importantTasks.add(tasks[i]);
              }
            }
            if (MediaQuery.of(context).size.width > 800 &&
                MediaQuery.of(context).size.width >
                    MediaQuery.of(context).size.height) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Expanded(child: SizedBox()),
                      Expanded(
                        child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 5, horizontal: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                const Text(
                                  '顯示過去項目',
                                  style: TextStyle(fontSize: 15),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Switch(
                                  value: showPast,
                                  onChanged: (value) {
                                    HapticFeedback.mediumImpact();
                                    ref
                                        .read(pastSwitchProvider.notifier)
                                        .update((state) => value);
                                  },
                                ),
                              ],
                            )),
                      )
                    ],
                  ),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: TaskTableView(tasks, idx - 1000)),
                        Expanded(
                          child: TaskListView(
                            showTasks,
                            showDateTitle: true,
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              );
            } else {
              switch (taskViewTypeState) {
                case TaskViewType.table:
                  return TaskTableView(tasks, idx - 1000);
                case TaskViewType.list:
                  return Column(
                    children: [
                      Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              const Text(
                                '顯示過去項目',
                                style: TextStyle(fontSize: 15),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Switch(
                                value: showPast,
                                onChanged: (value) {
                                  HapticFeedback.mediumImpact();
                                  ref
                                      .read(pastSwitchProvider.notifier)
                                      .update((state) => value);
                                },
                              ),
                            ],
                          )),
                      Expanded(
                        child: TaskListView(
                          showTasks,
                          showDateTitle: true,
                        ),
                      ),
                    ],
                  );
                case TaskViewType.calendar:
                  if (ref.watch(googleApiProvider).loggedIn) {
                    return CalendarTaskListView(
                      calendarTask,
                      showDateTitle: true,
                    );
                  } else {
                    return Center(
                      child: OutlinedButton.icon(
                          onPressed: () =>
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => const SettingPage(),
                              )),
                          icon: const Icon(Icons.open_in_new),
                          label: const Text('前往設定')),
                    );
                  }
              }
            }
          }),
    );
  }
}

class TaskTableView extends ConsumerWidget {
  const TaskTableView(this.tasks, this.week, {super.key});
  final List<Task> tasks;
  final int week;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<TimeOfDay> classTimes = ref.watch(classTableProvider).time;
    List<String> lesson = ref.watch(classTableProvider).table;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Table(
            border: TableBorder.all(
                color: Colors.grey,
                width: 2,
                borderRadius: BorderRadius.circular(20)),
            children: [
              TableRow(children: [
                for (int d = 0; d < 6; d++)
                  Builder(builder: (context) {
                    DateTime today = ref.watch(dateProvider).now;
                    DateTime date = ref
                        .watch(dateProvider)
                        .thisWeek
                        .add(Duration(days: 7 * week))
                        .add(Duration(days: d + 1));
                    bool isToday = false;
                    if (date.isBefore(today) &&
                        date.add(const Duration(days: 1)).isAfter(today)) {
                      isToday = true;
                    }
                    int month = date.month;
                    int day = date.day;
                    String weekday =
                        ['日', '一', '二', '三', '四', '五', '六'][date.weekday % 7];
                    return Container(
                      decoration: BoxDecoration(
                          color: Theme.of(context).cardTheme.color,
                          borderRadius: d == 0
                              ? const BorderRadius.only(
                                  topLeft: Radius.circular(25))
                              : d == 6 - 1
                                  ? const BorderRadius.only(
                                      topRight: Radius.circular(25))
                                  : null),
                      height: 50,
                      alignment: Alignment.center,
                      child: Text(
                        '$month/$day\n($weekday)',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: isToday ? Colors.blue : null,
                          fontWeight: isToday ? FontWeight.bold : null,
                        ),
                      ),
                    );
                  }),
              ]),
              for (int l = 0; l < 9; l++)
                TableRow(
                    decoration: l == 0 || l == 4 || l == 7
                        ? const BoxDecoration(
                            border: Border(
                            bottom: BorderSide(
                                width: 5,
                                color: Colors.grey,
                                strokeAlign: BorderSide.strokeAlignInside),
                          ))
                        : null,
                    children: [
                      for (int d = 0; d < 6; d++)
                        Container(
                          decoration: BoxDecoration(
                              color: Theme.of(context).cardTheme.color,
                              borderRadius: l == 9 - 1
                                  ? d == 0
                                      ? const BorderRadius.only(
                                          bottomLeft: Radius.circular(25))
                                      : d == 6 - 1
                                          ? const BorderRadius.only(
                                              bottomRight: Radius.circular(25))
                                          : null
                                  : null),
                          margin: l == 0 || l == 4 || l == 7
                              ? const EdgeInsets.only(bottom: 5)
                              : null,
                          height: 60,
                          alignment: Alignment.center,
                          child: TextButton(
                            onPressed: () {
                              HapticFeedback.selectionClick();
                              showModalBottomSheet(
                                  showDragHandle: true,
                                  context: context,
                                  builder: (context) => BottomSheet(
                                      className: lesson[d * 9 + l],
                                      weekDay: d + 1,
                                      lessonIdx: l));
                            },
                            onLongPress: () {
                              final DateTime date = ref
                                  .watch(dateProvider)
                                  .thisWeek
                                  .add(Duration(days: 7 * week))
                                  .add(Duration(days: d + 1))
                                  .copyWith(
                                    hour: classTimes[l].hour,
                                    minute: classTimes[l].minute,
                                    second: 0,
                                  );
                              if (ref.watch(nowTimeProvider).isBefore(date)) {
                                HapticFeedback.mediumImpact();
                                ref.read(formProvider.notifier).dateChange(ref
                                    .watch(dateProvider)
                                    .thisWeek
                                    .add(Duration(days: 7 * week))
                                    .add(Duration(days: d + 1))
                                    .copyWith(
                                      hour: classTimes[l].hour,
                                      minute: classTimes[l].minute,
                                      second: 0,
                                    ));
                                showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (BuildContext context) =>
                                        const TaskForm());
                              }
                            },
                            child: Text(
                              lesson[d * 9 + l],
                              style: TextStyle(
                                fontSize: hasTask(d + 1, l, tasks) ? 16 : 15,
                                fontWeight: hasTask(d + 1, l, tasks)
                                    ? FontWeight.w900
                                    : null,
                                color: hasTask(d + 1, l, tasks)
                                    ? Colors.red
                                    : null,
                              ),
                            ),
                          ),
                        ),
                    ]),
            ]),
      ),
    );
  }

  bool hasTask(int weekDay, int lessonIdx, List<Task> tasks) {
    int counter = 0;
    for (Task task in tasks) {
      if (task.classTime == lessonIdx && task.date.weekday == weekDay) {
        counter++;
      }
    }
    return counter > 0;
  }
}

class TaskListView extends ConsumerWidget {
  const TaskListView(this.tasks,
      {this.showDateTitle = false, this.short = false, super.key});

  final bool showDateTitle;
  final bool short;
  final List<Task> tasks;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final borderRadius = BorderRadius.circular(20);
    Map<String, String> usersData = ref.watch(usersProvider);
    Color headerColor = Theme.of(context).colorScheme.secondaryContainer;
    return Card(
      clipBehavior: Clip.hardEdge,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius,
      ),
      elevation: showDateTitle ? 1 : 0,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: GroupedListView<Task, int>(
        physics: const BouncingScrollPhysics(),
        elements: tasks,
        groupBy: (task) => task.top ? -1 : task.date.weekday % 7,
        groupHeaderBuilder: (Task task) => showDateTitle
            ? ColoredBox(
                color: headerColor,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Text(
                    task.top
                        ? '置頂'
                        : DateFormat('yyyy/MM/dd EE', 'zh-TW')
                            .format(task.date),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
              )
            : const SizedBox(),
        stickyHeaderBackgroundColor: Colors.transparent,
        separator: const Divider(
          thickness: 0.5,
          indent: 80,
          endIndent: 20,
          height: 0,
        ),
        itemBuilder: (context, Task task) {
          String lessonName = [-1, 0, 8].contains(task.classTime)
              ? DateFormat('HH:mm', 'zh-TW').format(task.date)
              : '第${task.classTime}節';
          return InkWell(
            onLongPress: () {
              showDialog(
                context: context,
                builder: (context) {
                  return TaskDetail(task, lessonName);
                },
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Checkbox(
                      value: ref.watch(todoProvider).contains(task.taskId),
                      onChanged: (value) {
                        HapticFeedback.mediumImpact();
                        ref.read(todoProvider.notifier).changeData(task.taskId);
                      },
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 5,
                          crossAxisAlignment: WrapCrossAlignment.end,
                          children: [
                            if (task.top)
                              const Icon(
                                Icons.push_pin,
                                color: Colors.red,
                                size: 25,
                              ),
                            Text(
                              task.name,
                              style: const TextStyle(fontSize: 18),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        if (!short)
                          Text(
                            '$lessonName ${[
                              '考試',
                              '作業',
                              '報告',
                              '提醒',
                              '繳交',
                            ][task.type]}',
                            style: const TextStyle(fontSize: 15),
                          ),
                        if (!short)
                          Text(
                            usersData[task.userId] ?? '',
                            style: const TextStyle(fontSize: 10),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: PopupMenuButton(
                      itemBuilder: (context) => <PopupMenuEntry>[
                        PopupMenuItem(
                            enabled: task.userId ==
                                ref.watch(authProvider).user?.uid,
                            value: 'top',
                            child: Row(
                              children: [
                                Icon(task.top
                                    ? Icons.push_pin_outlined
                                    : Icons.push_pin),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(task.top ? '取消置頂' : '置頂'),
                              ],
                            )),
                        const PopupMenuItem(
                            value: 'copy',
                            child: Row(
                              children: [
                                Icon(Icons.copy),
                                SizedBox(
                                  width: 10,
                                ),
                                Text('複製項目'),
                              ],
                            )),
                        const PopupMenuItem(
                            enabled: false,
                            value: 'star',
                            child: Row(
                              children: [
                                Icon(Icons.star),
                                SizedBox(
                                  width: 10,
                                ),
                                Text('標記星號'),
                              ],
                            )),
                        PopupMenuItem(
                            enabled: task.userId ==
                                ref.watch(authProvider).user?.uid,
                            value: 'edit',
                            child: const Row(
                              children: [
                                Icon(Icons.edit_note),
                                SizedBox(
                                  width: 10,
                                ),
                                Text('修改'),
                              ],
                            )),
                      ],
                      onSelected: (value) async {
                        HapticFeedback.selectionClick();
                        switch (value) {
                          case 'top':
                            task.pinTop(ref);
                            break;
                          case 'edit':
                            ref.read(formProvider.notifier).startUpdate(task);
                            showDialog(
                              context: context,
                              builder: (context) => const TaskForm(),
                            );
                            break;
                          case 'star':
                            break;
                          case 'copy':
                            await Clipboard.setData(
                                ClipboardData(text: task.name));
                            toastification.show(
                              type: ToastificationType.info,
                              style: ToastificationStyle.flatColored,
                              title: const Text("已複製到剪貼簿"),
                              description: Text(task.name),
                              alignment: Alignment.topCenter,
                              showProgressBar: false,
                              autoCloseDuration:
                                  const Duration(milliseconds: 1500),
                            );
                            break;
                        }
                      },
                      tooltip: '更多',
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        useStickyGroupSeparators: true, // optional
      ),
    );
  }
}

class CalendarTaskListView extends ConsumerWidget {
  const CalendarTaskListView(this.tasks,
      {this.showDateTitle = false, this.short = false, super.key});

  final bool showDateTitle;
  final bool short;
  final List<CalendarTask> tasks;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final borderRadius = BorderRadius.circular(20);
    Color headerColor = Theme.of(context).colorScheme.secondaryContainer;
    return Card(
      clipBehavior: Clip.hardEdge,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius,
      ),
      elevation: showDateTitle ? 1 : 0,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: GroupedListView<CalendarTask, int>(
        physics: const BouncingScrollPhysics(),
        elements: tasks,
        groupBy: (task) => task.date.weekday % 7,
        groupHeaderBuilder: (CalendarTask task) => showDateTitle
            ? ColoredBox(
                color: headerColor,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Text(
                    DateFormat('yyyy/MM/dd EE', 'zh-TW').format(task.date),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
              )
            : const SizedBox(),
        stickyHeaderBackgroundColor: Colors.transparent,
        separator: const Divider(
          thickness: 0.5,
          indent: 80,
          endIndent: 20,
          height: 0,
        ),
        itemBuilder: (context, CalendarTask task) {
          String lessonName = [-1, 0, 8].contains(task.classTime)
              ? DateFormat('HH:mm', 'zh-TW').format(task.date)
              : '第${task.classTime}節';
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Checkbox(
                    value: ref.watch(todoProvider).contains(task.taskId),
                    onChanged: (value) {
                      HapticFeedback.mediumImpact();
                      ref.read(todoProvider.notifier).changeData(task.taskId);
                    },
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.name,
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 2),
                      if (!short)
                        Text(
                          '$lessonName ',
                          style: const TextStyle(fontSize: 15),
                        ),
                    ],
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: PopupMenuButton(
                    itemBuilder: (context) => <PopupMenuEntry>[
                      const PopupMenuItem(
                          value: 'copy',
                          child: Row(
                            children: [
                              Icon(Icons.copy),
                              SizedBox(
                                width: 10,
                              ),
                              Text('複製項目'),
                            ],
                          )),
                      const PopupMenuItem(
                          enabled: false,
                          value: 'star',
                          child: Row(
                            children: [
                              Icon(Icons.star),
                              SizedBox(
                                width: 10,
                              ),
                              Text('標記星號'),
                            ],
                          )),
                    ],
                    onSelected: (value) async {
                      HapticFeedback.selectionClick();
                      switch (value) {
                        case 'copy':
                          await Clipboard.setData(
                              ClipboardData(text: task.name));
                          toastification.show(
                            type: ToastificationType.info,
                            style: ToastificationStyle.flatColored,
                            title: const Text("已複製到剪貼簿"),
                            alignment: Alignment.topCenter,
                            showProgressBar: false,
                            autoCloseDuration:
                                const Duration(milliseconds: 1500),
                          );
                          break;
                      }
                    },
                    tooltip: '更多',
                  ),
                ),
              ],
            ),
          );
        },
        useStickyGroupSeparators: true, // optional
      ),
    );
  }
}

class TaskForm extends ConsumerStatefulWidget {
  const TaskForm({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TaskFormState();
}

class _TaskFormState extends ConsumerState<TaskForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _controller = TextEditingController();
  bool willRemove = false;

  @override
  void initState() {
    _controller.text = ref.read(formProvider).name;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      contentPadding: const EdgeInsets.all(20),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(ref.watch(formProvider).formStatus == TaskFormStatus.create
              ? '新增項目'
              : '修改項目'),
          IconButton(
              onPressed: () {
                Navigator.of(context).pop();
                ref.read(formProvider.notifier).editFinish();
              },
              icon: const Icon(Icons.close))
        ],
      ),
      children: [
        SizedBox(
          width: 300,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: '請輸入完整，如：英文U1單字',
                    hintStyle: TextStyle(height: 2),
                    labelText: '項目名稱',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty || value.length < 2) {
                      return '請輸入項目名稱';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    willRemove = false;
                    _formKey.currentState!.validate();
                    ref.read(formProvider.notifier).nameChange(value);
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                        color: Colors.grey.shade600,
                        style: BorderStyle.solid,
                        width: 0.80),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                        borderRadius: BorderRadius.circular(15),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 7),
                        value: ref.watch(formProvider).type,
                        onChanged: (int? value) {
                          willRemove = false;
                          ref.read(formProvider.notifier).typeChange(value!);
                        },
                        items: const [
                          DropdownMenuItem<int>(
                            value: 0,
                            child: Text('考試'),
                          ),
                          DropdownMenuItem<int>(
                            value: 1,
                            child: Text('作業'),
                          ),
                          DropdownMenuItem<int>(
                            value: 2,
                            child: Text('報告'),
                          ),
                          DropdownMenuItem<int>(
                            value: 3,
                            child: Text('提醒'),
                          ),
                          DropdownMenuItem<int>(
                            value: 4,
                            child: Text('繳交'),
                          ),
                        ]),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 2, bottom: 8),
                  child: Text(
                    '需清點繳交物品請選擇「繳交」',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                        color: Colors.grey.shade600,
                        style: BorderStyle.solid,
                        width: 0.80),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {
                          willRemove = false;
                          showDatePicker(
                                  context: context,
                                  initialDate: ref
                                          .read(formProvider)
                                          .date
                                          .isBefore(DateTime.now())
                                      ? DateTime.now()
                                      : ref.read(formProvider).date,
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.now()
                                      .add(const Duration(days: 150)))
                              .then((DateTime? dateTime) {
                            if (dateTime == null) return;
                            ref
                                .read(formProvider.notifier)
                                .dateChange(dateTime);
                          });
                        },
                        style: TextButton.styleFrom(),
                        child: Text(
                          DateFormat('yyyy/MM/dd EE', 'zh-TW')
                              .format(ref.watch(formProvider).date),
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          willRemove = false;
                          showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(
                                ref.read(formProvider).date),
                          ).then((TimeOfDay? time) {
                            if (time == null) return;
                            ref.read(formProvider.notifier).timeChange(time);
                          });
                        },
                        style: TextButton.styleFrom(),
                        child: Text(
                          DateFormat('HH:mm', 'zh-TW')
                              .format(ref.watch(formProvider).date),
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        if (ref.watch(formProvider).formStatus == TaskFormStatus.create)
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                HapticFeedback.lightImpact();
                toastification.show(
                  type: ToastificationType.info,
                  style: ToastificationStyle.flatColored,
                  title: const Text("建立資料中"),
                  alignment: Alignment.topCenter,
                  showProgressBar: false,
                  autoCloseDuration: const Duration(milliseconds: 1500),
                );
                Navigator.of(context).pop();
                ref.read(formProvider.notifier).create();
              } else {
                HapticFeedback.heavyImpact();
              }
            },
            child: const Text(
              '建立',
              style: TextStyle(fontSize: 18),
            ),
          ),
        if (ref.watch(formProvider).formStatus == TaskFormStatus.update)
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    HapticFeedback.lightImpact();
                    toastification.show(
                      type: ToastificationType.info,
                      style: ToastificationStyle.flatColored,
                      title: const Text("更新資料中"),
                      alignment: Alignment.topCenter,
                      showProgressBar: false,
                      autoCloseDuration: const Duration(milliseconds: 1500),
                    );
                    Navigator.of(context).pop();
                    ref.read(formProvider.notifier).update();
                  } else {
                    HapticFeedback.heavyImpact();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  '更新',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                ),
                onPressed: () {
                  if (!willRemove) {
                    HapticFeedback.lightImpact();
                    setState(() {
                      willRemove = true;
                    });
                  } else {
                    HapticFeedback.heavyImpact();
                    toastification.show(
                      type: ToastificationType.info,
                      style: ToastificationStyle.flatColored,
                      title: const Text("刪除資料中"),
                      alignment: Alignment.topCenter,
                      showProgressBar: false,
                      autoCloseDuration: const Duration(milliseconds: 1500),
                    );
                    Navigator.of(context).pop();
                    ref.read(formProvider.notifier).remove();
                    willRemove = false;
                  }
                },
                child: Text(
                  willRemove ? '確認刪除' : '刪除',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class TaskDetail extends ConsumerWidget {
  final Task task;
  final String lessonName;
  const TaskDetail(this.task, this.lessonName, {super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SimpleDialog(
      contentPadding: const EdgeInsets.all(20),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(task.name),
          IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.close))
        ],
      ),
      children: [
        Text(
          '''
時間：\t${DateFormat('yyyy/MM/dd EE HH:mm', 'zh-TW').format(task.date)}
類別：\t${['考試', '作業', '報告', '提醒', '繳交'][task.type]}
課程：\t$lessonName
建立者：\t${ref.watch(usersProvider)[task.userId]}
狀態：\t${task.top ? '已釘選' : '未釘選'}''',
          style: const TextStyle(fontSize: 18, height: 1.5),
        ),
        const SizedBox(
          height: 5,
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          child: const Text('好'),
        ),
      ],
    );
  }
}

class BottomSheet extends ConsumerWidget {
  const BottomSheet(
      {required this.className,
      required this.weekDay,
      required this.lessonIdx,
      super.key});
  final String className;
  final int weekDay;
  final int lessonIdx;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<TimeOfDay> classTimes = ref.watch(classTableProvider).time;
    int week = ref.watch(dateProvider).week;
    TaskState taskState = ref.watch(taskProvider);
    List<Task> tasks = taskState.tasksMap[week] ?? [];
    List<Task> tasksForThisClass = [];
    for (Task task in tasks) {
      if (task.classTime == lessonIdx && task.date.weekday == weekDay) {
        tasksForThisClass.add(task);
      }
    }

    DateTime date = ref
        .watch(dateProvider)
        .thisWeek
        .add(Duration(days: 7 * week))
        .add(Duration(days: weekDay))
        .copyWith(
          hour: classTimes[lessonIdx].hour,
          minute: classTimes[lessonIdx].minute,
          second: 0,
        );

    return SizedBox(
      height: 400,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${date.month}/${date.day} 第$lessonIdx節 $className',
                  style: const TextStyle(fontSize: 22.5),
                ),
                IconButton(
                  onPressed: ref.watch(nowTimeProvider).isBefore(date)
                      ? () {
                          HapticFeedback.mediumImpact();
                          ref.read(formProvider.notifier).dateChange(date);
                          showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) =>
                                  const TaskForm());
                        }
                      : null,
                  icon: const Icon(Icons.add_task),
                  tooltip: '新增事項在這一節課',
                ),
              ],
            ),
          ),
          Expanded(
            child: TaskListView(tasksForThisClass),
          ),
          const SizedBox(
            height: 10,
          )
        ],
      ),
    );
  }
}
