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
    category = widget.category;
    _titleController = TextEditingController(text: category.title);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _saveChanges(String newTitle) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(seconds: 1), () async {
      try {
        habitService.changeCategoryTitle(category.title, newTitle);

        // Update local category and save the new title in Hive
        setState(() {
          category = categoryBox.values
              .firstWhere((element) => element.title == newTitle);
        });

        print('Category updated: $newTitle');
      } catch (error) {
        print(error);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to change title: $error"),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(bottom: 80, left: 16, right: 16),
            duration: Duration(seconds: 1),
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
                            print(_titleController.text);
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
              final habits = category.habits;
              if (habits == null || habits.isEmpty) {
                return Center(
                  child: SizedBox(
                    width: double.infinity,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "No habits tracked. Start tracking now!",
                          textAlign: TextAlign.center,
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

                int ageA = now.difference(a.creationDate).inDays + 1;
                int ageB = now.difference(b.creationDate).inDays + 1;

                double densityA = a.completedDates!.length / ageA;
                double densityB = b.completedDates!.length / ageB;

                int densityComparison = densityB.compareTo(densityA);
                if (densityComparison != 0) return densityComparison;

                return a.title.compareTo(b.title);
              });
              return ListView.builder(
                padding: EdgeInsets.only(right: 5, left: 5, bottom: 5),
                physics: BouncingScrollPhysics(),
                itemCount: habits.length,
                itemBuilder: (context, index) {
                  final habit = habits[index];
                  DateTime now = DateTime.now();
                  int ageA = now.difference(habit.creationDate).inDays + 1;
                  double densityA = habit.completedDates!.length / ageA;

                  return Dismissible(
                    key: Key(habit.key.toString()),
                    direction: DismissDirection.horizontal,
                    confirmDismiss: (direction) async {
                      if (direction == DismissDirection.startToEnd) {
                        return true;
                      } else if (direction == DismissDirection.endToStart) {
                        _showEditHabitDialog(context, habit);
                        return false;
                      }
                      return false;
                    },
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
                          duration: Duration(seconds: 1),
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

  void _showEditHabitDialog(BuildContext context, Habit habit) {
    final habitTitleController = TextEditingController(text: habit.title);
    final coinsController =
        TextEditingController(text: habit.coinAmount.toString());

    List<Category> categories = categoryBox.values.toList();
    String categoryTitle =
        habit.categoryTitle; // Pre-fill category with existing value
    String? errorMessage;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text("Edit Habit"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: habitTitleController,
                    decoration: InputDecoration(
                      labelText: "Habit Title",
                      errorText: errorMessage,
                    ),
                  ),
                  SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: categoryTitle,
                    items: categories.map((category) {
                      return DropdownMenuItem(
                        value: category.title,
                        child: Text(category.title),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        categoryTitle = value!;
                      });
                    },
                    decoration: InputDecoration(labelText: "Category"),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: coinsController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Coins",
                      icon: Icon(Icons.attach_money, color: Colors.amber),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () {
                  final habitTitle = habitTitleController.text.trim();
                  final coins = int.tryParse(coinsController.text) ?? 0;

                  if (habitTitle.isNotEmpty) {
                    bool titleExists = habitBox.values.any((h) =>
                        h.title.toLowerCase() == habitTitle.toLowerCase() &&
                        h.key != habit.key);

                    if (titleExists) {
                      setState(() {
                        errorMessage = "Habit title already exists";
                      });
                    } else {
                      setState(() {
                        errorMessage = null;
                      });

                      try {
                        final newHabit = Habit(
                          title: habitTitle,
                          categoryTitle: categoryTitle,
                          coinAmount: coins,
                          creationDate: habit.creationDate,
                          completedDates: habit.completedDates,
                        );
                        habitService.editHabit(habit, newHabit, categoryTitle);
                      } catch (error) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Failed to edit habit: $error"),
                            behavior: SnackBarBehavior.floating,
                            margin: EdgeInsets.only(
                                bottom: 80, left: 16, right: 16),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      }
                      Navigator.pop(context);
                    }
                  }
                },
                child: Text("Save"),
              ),
            ],
          );
        });
      },
    );
  }
}
