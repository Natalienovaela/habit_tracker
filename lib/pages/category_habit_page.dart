import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:namer_app/boxes.dart';
import 'package:namer_app/models/category.dart';
import 'package:namer_app/models/habit.dart';
import 'package:namer_app/services/habit_service.dart';

import 'package:namer_app/widgets/habit_tile.dart';

class CategoryHabitPage extends StatefulWidget {
  const CategoryHabitPage({super.key, required this.category});

  final Category category;

  @override
  State<CategoryHabitPage> createState() => _CategoryHabitPageState();
}

class _CategoryHabitPageState extends State<CategoryHabitPage> {
  bool _isEditing = false;
  late TextEditingController _titleController;
  late Category category;
  Timer? _debounceTimer;
  final habitService = HabitService();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.category.title);
    category = widget.category;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _saveChanges(String newTitle) {
    if (_debounceTimer != null && _debounceTimer!.isActive) {
      _debounceTimer!.cancel();
    }

    _debounceTimer = Timer(const Duration(seconds: 3), () {
      try {
        List<Habit> habits = category.habits!;
        if (habits.isNotEmpty) {
          for (var habit in habits) {
            habitService.changeCategoryTitle(habit.key, newTitle);
          }
        }
        final updatedCategory = Category(title: newTitle, habits: habits);
        categoryBox.put(widget.category.key, updatedCategory);
        print('Category updated: $newTitle');
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to change title: $error"),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(bottom: 80, left: 16, right: 16),
            duration: Duration(seconds: 1), // Shortens the display time
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Column(children: [
        Container(
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.pop(context);
                    }),
              ],
            )),
        GestureDetector(
          onTap: () {
            setState(() {
              _isEditing = true;
            });
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            width: double.infinity,
            child: _isEditing
                ? TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: "Category Title",
                      suffixIcon: IconButton(
                        icon: Icon(Icons.check),
                        onPressed: () {
                          setState(() {
                            _isEditing = false;
                            _saveChanges(_titleController.text);
                          });
                        },
                      ),
                    ),
                    autofocus: true,
                    onChanged: _saveChanges,
                    onSubmitted: (value) {
                      setState(() {
                        _isEditing = false;
                      });
                    },
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        category.title,
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.cyan[900]),
                      ),
                      Icon(Icons.edit, size: 20, color: Colors.grey)
                    ],
                  ),
          ),
        ),
        Container(
            padding: EdgeInsets.all(10),
            child: Text(
              style: theme.textTheme.headlineSmall!
                  .copyWith(color: Colors.cyan[900]),
              "Habits",
            )),
        Expanded(
          child: ValueListenableBuilder(
            valueListenable: categoryBox.listenable(),
            builder: (context, Box categoryBox, _) {
              print(category);
              final habits = category.habits;
              print(habits);
              if (habits == null || habits.isEmpty) {
                return Center(
                  child: SizedBox(
                    width: double.infinity, // Makes the Column take full width
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment:
                          CrossAxisAlignment.center, // Ensures text is centered
                      children: [
                        Text(
                          "No habits tracked. Start tracking now!",
                          textAlign: TextAlign
                              .center, // Ensures text alignment is centered
                          style: theme.textTheme.headlineSmall!
                              .copyWith(color: Colors.cyan[900]),
                        ),
                      ],
                    ),
                  ),
                );
              }
              habits.sort((a, b) {
                DateTime now = DateTime.now();

                // Calculate age in days
                int ageA = now.difference(a.creationDate).inDays +
                    1; // Avoid division by zero
                int ageB = now.difference(b.creationDate).inDays + 1;

                // Completion density (higher is better)
                double densityA = a.completedDates!.length / ageA;
                double densityB = b.completedDates!.length / ageB;

                // Sort by density first, then by title
                int densityComparison =
                    densityB.compareTo(densityA); // Higher first
                if (densityComparison != 0) return densityComparison;

                return a.title.compareTo(b.title); // Alphabetical fallback
              });
              return ListView.builder(
                padding: EdgeInsets.only(right: 5, left: 5, bottom: 5),
                physics: BouncingScrollPhysics(),
                itemCount: habits.length,
                itemBuilder: (context, index) {
                  final habit = habits[index];
                  DateTime now = DateTime.now();

                  // Calculate age in days
                  int ageA = now.difference(habit.creationDate).inDays + 1;
                  double densityA = habit.completedDates!.length / ageA;
                  print(habit.completedDates!.length);
                  print(ageA);
                  print(densityA);

                  return Dismissible(
                    key: Key(habit.key.toString()),
                    direction: DismissDirection.startToEnd,
                    onDismissed: (direction) {
                      // Handle Delete Action
                      Category category = categoryBox.values
                          .firstWhere((e) => e.title == habit.categoryTitle);
                      category.habits!.remove(habit);
                      categoryBox.put(category.key, category);
                      habitBox.delete(habit.key);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("${habit.title} deleted"),
                          behavior: SnackBarBehavior.floating,
                          margin:
                              EdgeInsets.only(bottom: 80, left: 16, right: 16),
                          duration:
                              Duration(seconds: 1), // Shortens the display time
                        ),
                      );
                    },
                    background: Container(
                      color: Colors.red,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.white),
                              SizedBox(width: 10),
                              Text("Delete",
                                  style: TextStyle(color: Colors.white)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    secondaryBackground: Container(
                      color: Colors.blue,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Icon(Icons.edit, color: Colors.white),
                              SizedBox(width: 10),
                              Text("Edit",
                                  style: TextStyle(color: Colors.white)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          HabitTile(
                              habit: habit, index: index, density: densityA)
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ]),
    );
  }
}
