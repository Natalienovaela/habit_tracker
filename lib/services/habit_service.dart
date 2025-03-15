import 'package:hive/hive.dart';
import 'package:namer_app/boxes.dart';
import 'package:namer_app/models/category.dart';
import 'package:namer_app/models/coin.dart';
import '../models/habit.dart';

class HabitService {
  Habit changeCategoryTitle(int habitKey, String title) {
    Habit? habit = habitBox.get(habitKey);
    if (habit != null) {
      habit.categoryTitle = title;
      habit.save();
      return habit;
    } else {
      throw Exception("Habit with key $habitKey not found");
    }
  }

  /// Marks a habit as completed today
  void markHabitAsCompleted(int habitKey) {
    Habit? habit = habitBox.get(habitKey);
    if (habit != null && !habit.isCompletedToday) {
      habit.completedDates ??= [];
      habit.completedDates!.add(DateTime.now());
      print(habit.completedDates![0]);
      habit.save();

      Category category = categoryBox.values.firstWhere(
        (category) => category.title == habit.categoryTitle,
      );

      category.habits?.removeWhere((h) => h.key == habit.key);
      category.habits?.add(habit);
      categoryBox.put(category.key, category);

      Coin coin = coinBox.values.toList()[0];
      print(coin.coinAmount);
      int amount = coin.coinAmount + habit.coinAmount;
      coinBox.put(coin.key, Coin(coinAmount: amount));
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
    }
  }

  void calculateHabitPercentages() {}
}
