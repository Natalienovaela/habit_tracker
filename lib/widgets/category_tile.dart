import 'package:flutter/material.dart';
import 'package:namer_app/models/category.dart';
import 'package:namer_app/pages/category_habit_page.dart';

class CategoryTile extends StatelessWidget {
  const CategoryTile({super.key, required this.category});

  final Category category;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CategoryHabitPage(category: category)),
          );
        },
        child: Card(
          color: Colors.cyan[50],
          child: Padding(
            padding:
                const EdgeInsets.only(top: 10, bottom: 10, right: 5, left: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                    icon: Icon(Icons.numbers, size: 25, fill: 0.9),
                    color: Colors.cyan[700],
                    onPressed: () async {}),
                Text(category.title, style: TextStyle(color: Colors.black87)),
              ],
            ),
          ),
        ));
  }
}
