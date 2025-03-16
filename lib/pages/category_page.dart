import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:namer_app/boxes.dart';
import 'package:namer_app/models/category.dart';
import 'package:namer_app/models/habit.dart';
import 'package:namer_app/services/category_service.dart';
import 'package:namer_app/services/other_service.dart';
import 'package:namer_app/widgets/category_tile.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  final categoryService = CategoryService();
  final otherService = OtherService();
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Column(children: [
        Container(
            padding: EdgeInsets.all(10),
            child: Text(
              style: theme.textTheme.headlineMedium!
                  .copyWith(color: Colors.cyan[900]),
              "Category",
            )),
        Expanded(
          child: ValueListenableBuilder(
            valueListenable: categoryBox.listenable(),
            builder: (context, Box categoryBox, _) {
              final categories = categoryBox.values.toList();
              categories.sort((a, b) => a.title.compareTo(b.title));
              return ListView.builder(
                padding: EdgeInsets.only(right: 5, left: 5, bottom: 5),
                physics: BouncingScrollPhysics(),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return Dismissible(
                    key: Key(category.key.toString()),
                    direction: DismissDirection.startToEnd,
                    onDismissed: (direction) {
                      categoryService.deleteCategory(category);

                      ScaffoldMessenger.of(context).showSnackBar(
                          otherService.message("${category.title} deleted"));
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
                        children: [CategoryTile(category: category)],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddCategoryDialog(context);
        },
        backgroundColor: Colors.cyan[500],
        foregroundColor: Colors.white,
        shape: CircleBorder(),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    String categoryTitle = "";
    String? errorMessage;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Add New Category"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: InputDecoration(
                          labelText: "Category Title", errorText: errorMessage),
                      onChanged: (value) => categoryTitle = value,
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
                    // Check if the category title already exists in the categoryBox
                    bool titleExists = categoryBox.values.any((category) =>
                        category.title.toLowerCase() ==
                        categoryTitle.toLowerCase());

                    if (titleExists) {
                      setState(() {
                        errorMessage = "Category title already exists";
                      });
                    } else {
                      setState(() {
                        errorMessage = null; // Clear the error message if valid
                      });

                      // Add the category if it doesn't exist
                      try {
                        categoryBox.add(Category(title: categoryTitle));
                      } catch (error) {
                        ScaffoldMessenger.of(context).showSnackBar(otherService
                            .message("Failed to add category: $error"));
                      }
                      Navigator.pop(context); // Close the dialog
                    }
                  },
                  child: Text("Add"),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
