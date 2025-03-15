import 'package:hive/hive.dart';

part 'habit.g.dart';

@HiveType(typeId: 0)
class Habit extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String categoryTitle;

  @HiveField(2)
  int coinAmount;

  @HiveField(3)
  DateTime creationDate;

  @HiveField(4)
  List<DateTime>? completedDates;

  Habit({
    required this.title,
    required this.categoryTitle,
    required this.coinAmount,
    required this.creationDate,
    List<DateTime>? completedDates,
  }) : completedDates = completedDates ?? [];

  bool get isCompletedToday {
    if (completedDates == null || completedDates!.isEmpty) return false;
    final now = DateTime.now();
    var lastCompleted = completedDates!.last;
    return lastCompleted.year == now.year &&
        lastCompleted.month == now.month &&
        lastCompleted.day == now.day;
  }

  /// Mark habit as completed
  void markAsCompleted() {
    if (!isCompletedToday) {
      completedDates!.add(DateTime.now());
      save(); // Save changes in Hive
    }
  }

  void markAsNotCompleted() {
    if (isCompletedToday) {
      completedDates!.removeLast();
      save();
    }
  }
}
