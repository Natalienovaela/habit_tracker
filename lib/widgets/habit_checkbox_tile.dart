import 'package:flutter/material.dart';
import 'package:namer_app/boxes.dart';
import 'package:namer_app/models/habit.dart';
import 'package:namer_app/services/habit_service.dart';

class HabitCheckboxTile extends StatelessWidget {
  const HabitCheckboxTile({super.key, required this.habit});

  final Habit habit;

  @override
  Widget build(BuildContext context) {
    final completed = habit.isCompletedToday;
    return Card(
      color: habit.isCompletedToday ? Colors.cyan[700] : Colors.cyan[50],
      child: Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 10, right: 20, left: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [
              IconButton(
                  icon: habit.isCompletedToday
                      ? Icon((Icons.check_box_rounded), size: 25, weight: 0.8)
                      : Icon(Icons.check_box_outline_blank,
                          size: 25, fill: 0.9),
                  color:
                      habit.isCompletedToday ? Colors.white : Colors.cyan[700],
                  onPressed: () async {
                    final habitService = HabitService();
                    if (habit.isCompletedToday) {
                      habitService.markHabitAsNotCompleted(habit.key);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                              Text("\$${habit.coinAmount} has been deducted"),
                          behavior: SnackBarBehavior.floating,
                          margin:
                              EdgeInsets.only(bottom: 80, left: 16, right: 16),
                          duration:
                              Duration(seconds: 1), // Shortens the display time
                        ),
                      );
                    } else {
                      habitService.markHabitAsCompleted(habit.key);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("You received \$${habit.coinAmount}"),
                          behavior: SnackBarBehavior.floating,
                          margin:
                              EdgeInsets.only(bottom: 80, left: 16, right: 16),
                          duration:
                              Duration(seconds: 1), // Shortens the display time
                        ),
                      );
                    }
                  }),
              Text(habit.title,
                  style: completed
                      ? TextStyle(color: Colors.white)
                      : TextStyle(color: Colors.black87)),
            ]),
            Row(mainAxisAlignment: MainAxisAlignment.start, children: [
              Icon(Icons.attach_money, color: Colors.amber),
              Text('${habit.coinAmount}')
            ])
          ],
        ),
      ),
    );
  }
}
