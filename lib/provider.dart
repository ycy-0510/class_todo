import 'package:class_todo_list/logic/auth_notifier.dart';
import 'package:class_todo_list/logic/calendar_task_notifier.dart';
import 'package:class_todo_list/logic/class_table_notifier.dart';
import 'package:class_todo_list/logic/connectivety_notifier.dart';
import 'package:class_todo_list/logic/date_notifier.dart';
import 'package:class_todo_list/logic/form_notifier.dart';
import 'package:class_todo_list/logic/google_api_notifier.dart';
import 'package:class_todo_list/logic/notification_notifier.dart';
import 'package:class_todo_list/logic/nowtime_notifier.dart';
import 'package:class_todo_list/logic/remote_config_notifier.dart';
import 'package:class_todo_list/logic/rss_read_notifier.dart';
import 'package:class_todo_list/logic/rss_url_notifier.dart';
import 'package:class_todo_list/logic/school_notifier.dart';
import 'package:class_todo_list/logic/self_number_notifier.dart';
import 'package:class_todo_list/logic/submit_notifier.dart';
import 'package:class_todo_list/logic/task_notifier.dart';
import 'package:class_todo_list/logic/todo_notifier.dart';
import 'package:class_todo_list/logic/users_notifier.dart';
import 'package:class_todo_list/logic/users_number_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) {
    return AuthNotifier(ref);
  },
);

final googleApiProvider =
    StateNotifierProvider<GoogleApiNotifier, GoogleApiState>(
  (ref) {
    return GoogleApiNotifier(ref);
  },
);

final notificationProvider =
    StateNotifierProvider.autoDispose<NotificationNotifier, NotificationState>(
  (ref) {
    return NotificationNotifier(ref);
  },
);

final formProvider =
    StateNotifierProvider<TaskFormNotifier, TaskFormState>((ref) {
  return TaskFormNotifier(ref);
});

final dateProvider = StateNotifierProvider<DateNotifier, DateState>((ref) {
  return DateNotifier();
});

final taskProvider =
    StateNotifierProvider.autoDispose<TaskNotifier, TaskState>((ref) {
  return TaskNotifier(ref);
});

final calendarTaskProvider =
    StateNotifierProvider.autoDispose<CalendarTaskNotifier, CalendarTaskState>(
        (ref) {
  return CalendarTaskNotifier(ref);
});

final classTableProvider =
    StateNotifierProvider<ClassTableNotifier, ClassTableState>(
        (ref) => ClassTableNotifier(ref));

final submittedProvider =
    StateNotifierProvider.autoDispose<SubmittedNotifier, SubmittedState>((ref) {
  return SubmittedNotifier(ref);
});

final usersProvider =
    StateNotifierProvider.autoDispose<UsersNotifier, Map<String, String>>(
        (ref) {
  return UsersNotifier(ref);
});

final usersNumberProvider =
    StateNotifierProvider.autoDispose<UsersNumberNotifier, Map<String, String>>(
        (ref) {
  return UsersNumberNotifier(ref);
});

final connectivityStatusProvider = StateNotifierProvider.autoDispose<
    ConnectivityStatusNotifier, ConnectivityStatus>((ref) {
  return ConnectivityStatusNotifier();
});

enum TaskViewType { table, list, calendar }

final taskViewTypeProvider =
    StateProvider<TaskViewType>((ref) => TaskViewType.table);

enum UsersType { users, students }

final usersTypeProvider = StateProvider<UsersType>((ref) => UsersType.users);

final pastSwitchProvider = StateProvider.autoDispose<bool>((ref) => false);

final nowTimeProvider = StateNotifierProvider<NowTimeNotifier, DateTime>(
    (ref) => NowTimeNotifier());

final todoProvider = StateNotifierProvider<TodoNotifier, List<String>>(
    (ref) => TodoNotifier(ref));

final selfNumberProvider = StateNotifierProvider<SelfNumberNotifier, String>(
    (ref) => SelfNumberNotifier());

final rssUrlProvider = StateNotifierProvider<RssUrlNotifier, RssUrlState>(
    (ref) => RssUrlNotifier(ref));

final schoolAnnouncementProvider =
    StateNotifierProvider<SchoolAnnouncementNotifier, SchoolAnnouncementState>(
        (ref) => SchoolAnnouncementNotifier(ref));

final rssReadProvider = StateNotifierProvider<RssReadNotifier, List<String>>(
    (ref) => RssReadNotifier(ref));

final rssReadFilterProvider = StateProvider<bool>((ref) => false);

final bottomTabProvider = StateProvider<int>((ref) => 0);

final remoteConfigProvider = NotifierProvider<RemoteConfigNotifier, bool>(() {
  return RemoteConfigNotifier();
});
