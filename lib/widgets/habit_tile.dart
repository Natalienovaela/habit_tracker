import 'package:flutter/material.dart';
import 'package:namer_app/models/habit.dart';

class HabitTile extends StatelessWidget {
  const HabitTile(
      {super.key,
      required this.habit,
      required this.index,
      required this.density});

  final Habit habit;
  final int index;
  final double density;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Stack(
        children: [
          // Background container
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: Colors.cyan[50], // Unfilled color
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          // Filled portion
          FractionallySizedBox(
            widthFactor: density, // Controls the fill percentage
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.cyan, // Filled color
                borderRadius: BorderRadius.horizontal(
                  left: Radius.circular(8),
                  right: Radius.circular(density == 1 ? 8 : 0),
                ),
              ),
            ),
          ),
          // Text and completion percentage
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(habit.title,
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                    "${(density * 100).toInt()}%",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    // Card(
    //   color: habit.isCompletedToday ? Colors.cyan[700] : Colors.cyan[50],
    //   child: Padding(
    //     padding: const EdgeInsets.only(top: 10, bottom: 10, right: 5, left: 5),
    //     child: Row(
    //       mainAxisAlignment: MainAxisAlignment.start,
    //       children: [
    //         Padding(
    //           padding: const EdgeInsets.only(left: 10.0, right: 10.0),
    //           child: Text((index + 1).toString(),
    //               style: completed
    //                   ? TextStyle(color: Colors.white, fontSize: 25)
    //                   : TextStyle(color: Colors.black87, fontSize: 25)),
    //         ),
    //         Text(habit.title,
    //             style: completed
    //                 ? TextStyle(color: Colors.white)
    //                 : TextStyle(color: Colors.black87)),
    //       ],
    //     ),
    //   ),
    // );
  }
}
