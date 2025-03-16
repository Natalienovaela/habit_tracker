import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:namer_app/boxes.dart';
import 'package:namer_app/models/category.dart';
import 'package:namer_app/models/coin.dart';
import 'package:namer_app/models/date_summary.dart';
import 'package:namer_app/services/other_service.dart';
import '../models/habit.dart';

class HabitService {
  ValueNotifier<Map<DateTime, int>> heatMapDataNotifier = ValueNotifier({});

  void changeCategoryTitle(String oldTitle, String title) {
    Category category =
        categoryBox.values.firstWhere((element) => element.title == oldTitle);

    List<Habit> habitList = [];

    if (category.habits != null) {
      List<Habit> habits = category.habits!;
      for (var habit in habits) {
        Habit _habit = Habit(
            categoryTitle: title,
            title: habit.title,
            coinAmount: habit.coinAmount,
            creationDate: habit.creationDate,
            completedDates: habit.completedDates);
        habitList.add(_habit);
        habitBox.put(habit.key, _habit);
      }
    }

    categoryBox.put(category.key, Category(title: title, habits: habitList));
  }

  void deleteHabit(Habit habit) {
    DateSummary? dateSummary = dateBox.values.firstWhere(
      (dateSummary) =>
          dateSummary.date == normalizeDate(DateTime.now()).toString(),
    );
    if (habit.isCompletedToday) {
      dateSummary.habitCompleted?.removeWhere((h) => h.key == habit.key);
    } else {
      dateSummary.habitIncompleted?.removeWhere((h) => h.key == habit.key);
    }
    dateBox.put(dateSummary.key, dateSummary);

    Category category = categoryBox.values
        .firstWhere((category) => category.title == habit.categoryTitle);
    category.habits!.remove(habit);
    categoryBox.put(category.key, category);
    habitBox.delete(habit.key);
  }

  void addHabit(Habit newHabit, String categoryTitle) {
    habitBox.add(newHabit);
    Category temp = categoryBox.values
        .firstWhere((category) => category.title == categoryTitle);
    temp.habits!.add(newHabit);
    categoryBox.put(temp.key, temp);
  }

  void editHabit(Habit habit, Habit newHabit, String newCategoryTitle) {
    if (habit.categoryTitle != newCategoryTitle) {
      Category temp = categoryBox.values
          .firstWhere((category) => category.title == habit.categoryTitle);

      temp.habits!.remove(habit);
      categoryBox.put(temp.key, temp);

      temp = categoryBox.values
          .firstWhere((category) => category.title == newCategoryTitle);

      temp.habits!.add(habit);
      categoryBox.put(temp.key, temp);
    }

    final otherService = OtherService();
    DateSummary date = dateBox.values.firstWhere((date) =>
        date.date == otherService.normalizeDate(DateTime.now()).toString());
    if (habit.isCompletedToday) {
      date.habitCompleted!.remove(habit);
      date.habitCompleted!.add(newHabit);
    } else {
      date.habitIncompleted!.remove(habit);
      date.habitIncompleted!.add(newHabit);
    }

    habitBox.put(habit.key, newHabit);
  }

  /// Marks a habit as completed today
  void markHabitAsCompleted(int habitKey) {
    Habit? habit = habitBox.get(habitKey);
    if (habit != null && !habit.isCompletedToday) {
      habit.completedDates ??= [];
      habit.completedDates!.add(DateTime.now());
      habit.save();

      Category category = categoryBox.values.firstWhere(
        (category) => category.title == habit.categoryTitle,
      );

      category.habits?.removeWhere((h) => h.key == habit.key);
      category.habits?.add(habit);
      categoryBox.put(category.key, category);

      Coin coin = coinBox.values.toList()[0];
      int amount = coin.coinAmount + habit.coinAmount;
      coinBox.put(coin.key, Coin(coinAmount: amount));

      DateSummary? dateSummary = dateBox.values.firstWhere(
        (dateSummary) =>
            dateSummary.date == normalizeDate(DateTime.now()).toString(),
      );
      dateSummary.habitIncompleted?.removeWhere((h) => h.key == habit.key);
      dateSummary.habitCompleted?.add(habit);
      dateBox.put(dateSummary.key, dateSummary);
    }
  }

  void markHabitAsNotCompleted(int habitKey) {
    Habit? habit = habitBox.get(habitKey);
    if (habit != null && habit.isCompletedToday) {
      habit.completedDates!.removeLast();
      habit.save();

      Category category = categoryBox.values.firstWhere(
        (category) => category.title == habit.categoryTitle,
      );

      category.habits?.removeWhere((h) => h.key == habit.key);
      category.habits?.add(habit);
      categoryBox.put(category.key, category);

      Coin coin = coinBox.values.toList()[0];
      int amount = coin.coinAmount - habit.coinAmount;
      coinBox.put(coin.key, Coin(coinAmount: amount));

      DateSummary? dateSummary = dateBox.values.firstWhere(
        (dateSummary) =>
            dateSummary.date == normalizeDate(DateTime.now()).toString(),
      );
      dateSummary.habitCompleted?.removeWhere((h) => h.key == habit.key);
      dateSummary.habitIncompleted?.add(habit);
      dateBox.put(dateSummary.key, dateSummary);
    }
  }

  DateTime normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  Map<DateTime, int> getHeatmapData(List dateSummaries) {
    Map<DateTime, int> heatMapData = {};

    for (var dateSummary in dateSummaries) {
      // Convert the string date back to DateTime
      DateTime date = DateTime.parse(dateSummary.date);

      // Add the completion rate to the map for this date
      heatMapData[date] = dateSummary.completionRate;
    }

    return heatMapData;
  }

  void updateHeatMap() {
    final habits = habitBox.values.toList();

    Map<DateTime, int> heatMapData = {};

// Step 1: Collect all dates where habits were completed (normalized)
    Set<DateTime> allCompletedDates = {};
    for (var habit in habits) {
      for (var date in habit.completedDates!) {
        allCompletedDates.add(normalizeDate(date));
      }
    }

// Step 2: Calculate completed/total habits for each date
    for (var date in allCompletedDates) {
      int completedOnThisDate = 0;
      int totalHabitsOnThisDate = 0;

      for (var habit in habits) {
        if (!habit.creationDate.isAfter(date)) {
          // Habit existed on this date
          totalHabitsOnThisDate++;
          if (habit.completedDates!.any((d) => normalizeDate(d) == date)) {
            completedOnThisDate++;
          }
        }
      }

      if (totalHabitsOnThisDate > 0) {
        heatMapData[date] =
            (100 * (completedOnThisDate / totalHabitsOnThisDate)).toInt();
      } else {
        heatMapData[date] = 0;
      }
    }
    heatMapDataNotifier.value = heatMapData;
  }

  void calculateHabitPercentages() {}
}
