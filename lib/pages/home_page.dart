import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:namer_app/boxes.dart';
import 'package:namer_app/models/category.dart';
import 'package:namer_app/models/habit.dart';
import 'package:namer_app/services/other_service.dart';
import 'package:namer_app/widgets/habit_checkbox_tile.dart';
import 'package:namer_app/widgets/my_heat_map.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final otherService = OtherService();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.only(top: 10),
            child: Text(
                style: theme.textTheme.headlineMedium!
                    .copyWith(color: Colors.cyan[900]),
                otherService.formatDate(DateTime.now())),
          ),
          Container(
            padding: EdgeInsets.all(10),
            child: MyHeatMap(),
          ),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: habitBox.listenable(),
              builder: (context, Box habitBox, _) {
                final habits = habitBox.values.toList();
                habits.sort((a, b) => a.isCompletedToday ? 1 : -1);
                return ListView.builder(
                  padding: EdgeInsets.only(right: 5, left: 5, bottom: 5),
                  physics: BouncingScrollPhysics(),
                  itemCount: habits.length,
                  itemBuilder: (context, index) {
                    final habit = habits[index];
                    return Dismissible(
                      key: Key(habit.key.toString()),
                      direction: DismissDirection.startToEnd,
                      onDismissed: (direction) {
                        // Handle Delete Action
                        Category category = categoryBox.values.firstWhere(
                            (category) =>
                                category.title == habit.categoryTitle);
                        category.habits!.remove(habit);
                        categoryBox.put(category.key, category);
                        habitBox.delete(habit.key);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("${habit.title} deleted"),
                            behavior: SnackBarBehavior.floating,
                            margin: EdgeInsets.only(
                                bottom: 80, left: 16, right: 16),
                            duration: Duration(
                                seconds: 1), // Shortens the display time
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
                          children: [HabitCheckboxTile(habit: habit)],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddHabitDialog(context);
        },
        backgroundColor: Colors.cyan[500],
        foregroundColor: Colors.white,
        shape: CircleBorder(),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showAddHabitDialog(BuildContext context) {
    String habitTitle = "";

    int coins = 0;

    List<Category> categories = categoryBox.values.toList();
    String categoryTitle = categories[0].title;
    String? errorMessage;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text("Add New Habit"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: InputDecoration(
                        labelText: "Habit Title", errorText: errorMessage),
                    onChanged: (value) => habitTitle = value,
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
                      decoration: InputDecoration(
                          labelText: "Coins",
                          icon: Icon(Icons.attach_money, color: Colors.amber)),
                      onChanged: (value) => coins = int.parse(value)),
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
                  if (habitTitle.isNotEmpty) {
                    bool titleExists = habitBox.values.any((habit) =>
                        habit.title.toLowerCase() == habitTitle.toLowerCase());

                    if (titleExists) {
                      setState(() {
                        errorMessage = "Habit title already exists";
                      });
                    } else {
                      setState(() {
                        errorMessage = null; // Clear the error message if valid
                      });

                      try {
                        final newHabit = Habit(
                            title: habitTitle,
                            categoryTitle: categoryTitle,
                            coinAmount: coins,
                            creationDate: DateTime
                                .now() // Associate the habit with the goal
                            );
                        habitBox.add(newHabit);
                        Category temp = categoryBox.values.firstWhere(
                            (category) => category.title == categoryTitle);
                        temp.habits!.add(newHabit);
                        categoryBox.put(temp.key, temp);
                      } catch (error) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Failed to add habit: $error"),
                            behavior: SnackBarBehavior.floating,
                            margin: EdgeInsets.only(
                                bottom: 80, left: 16, right: 16),
                            duration: Duration(
                                seconds: 1), // Shortens the display time
                          ),
                        );
                      }
                      Navigator.pop(context);
                    }
                  }
                },
                child: Text("Add"),
              ),
            ],
          );
        });
      },
    );
  }
}
