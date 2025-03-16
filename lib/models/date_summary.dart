import 'package:hive/hive.dart';
import 'package:namer_app/models/habit.dart';

part 'date_summary.g.dart';

@HiveType(typeId: 4)
class DateSummary extends HiveObject {
  @HiveField(0)
  String date;

  @HiveField(1)
  List<Habit>? habitCompleted;

  @HiveField(2)
  List<Habit>? habitIncompleted;

  DateSummary(
      {required this.date,
      List<Habit>? habitCompleted,
      List<Habit>? habitIncompleted})
      : habitCompleted = habitCompleted ?? [],
        habitIncompleted = habitIncompleted ?? [];

  int get completionRate {
    final totalHabits =
        (habitCompleted?.length ?? 0) + (habitIncompleted?.length ?? 0);
    return totalHabits == 0
        ? 0
        : ((habitCompleted!.length / totalHabits) * 100).toInt();
  }
}
