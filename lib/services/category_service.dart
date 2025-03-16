import 'package:namer_app/boxes.dart';
import 'package:namer_app/models/category.dart';
import 'package:namer_app/models/date_summary.dart';
import 'package:namer_app/models/habit.dart';
import 'package:namer_app/services/other_service.dart';

class CategoryService {
  final otherService = OtherService();

  void deleteCategory(Category category) {
    List<Habit> habits = habitBox.values
        .where((habit) => habit.categoryTitle == category.title)
        .toList();
    if (habits.isNotEmpty) {
      for (var habit in habits) {
        DateSummary? dateSummary = dateBox.values.firstWhere(
          (dateSummary) =>
              dateSummary.date ==
              otherService.normalizeDate(DateTime.now()).toString(),
        );
        if (habit.isCompletedToday) {
          dateSummary.habitCompleted?.removeWhere((h) => h.key == habit.key);
        } else {
          dateSummary.habitIncompleted?.removeWhere((h) => h.key == habit.key);
        }
        dateBox.put(dateSummary.key, dateSummary);

        habitBox.delete(habit.key);
      }
    }

    categoryBox.delete(category.key);
  }
}
