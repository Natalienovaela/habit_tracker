import 'package:hive/hive.dart';
import 'package:namer_app/models/habit.dart';

part 'category.g.dart';

@HiveType(typeId: 1)
class Category extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  List<Habit>? habits;

  Category({required this.title, List<Habit>? habits}) : habits = habits ?? [];
}
