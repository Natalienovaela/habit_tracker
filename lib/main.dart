import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:namer_app/boxes.dart';
import 'package:namer_app/models/coin.dart';
import 'package:namer_app/models/date_summary.dart';
import 'package:namer_app/pages/category_page.dart';
import 'package:namer_app/pages/home_page.dart';
import 'package:namer_app/pages/reward_page.dart';
import 'package:namer_app/services/other_service.dart';
import 'package:provider/provider.dart';
import 'package:namer_app/models/habit.dart';
import 'package:namer_app/models/category.dart';
import 'package:namer_app/models/reward.dart';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(HabitAdapter());
  Hive.registerAdapter(CategoryAdapter());
  Hive.registerAdapter(RewardAdapter());
  Hive.registerAdapter(CoinAdapter());
  Hive.registerAdapter(DateSummaryAdapter());

  // Delete all stored Hive boxes
  await Hive.deleteBoxFromDisk('categories');
  await Hive.deleteBoxFromDisk('habits');
  await Hive.deleteBoxFromDisk('rewards');
  await Hive.deleteBoxFromDisk("coins");
  await Hive.deleteBoxFromDisk('datesummaries');

  dateBox = await Hive.openBox<DateSummary>('datesummaries');

  categoryBox = await Hive.openBox<Category>('categories');
  await _loadCategoryBox();

  habitBox = await Hive.openBox<Habit>('habits');
  await _loadHabitBox();

  coinBox = await Hive.openBox<Coin>('coins');
  await _loadCoin();

  rewardBox = await Hive.openBox<Reward>('rewards');
  await _loadReward();

  final otherService = OtherService();

  bool exists = dateBox.values.any((date) =>
      date.date == otherService.normalizeDate(DateTime.now()).toString());

  if (!exists) {
    dateBox.add(DateSummary(
        date: otherService.normalizeDate(DateTime.now()).toString(),
        habitCompleted: [],
        habitIncompleted: habitBox.values.toList()));
  }

  runApp(MyApp());
}

Future<void> _loadCategoryBox() async {
  if (categoryBox.isEmpty) {
    categoryBox.addAll(<Category>[
      Category(title: "Health", habits: <Habit>[]),
      Category(title: "Wellness", habits: <Habit>[]),
      Category(title: "Knowledge", habits: <Habit>[]),
    ]);
  }
}

Future<void> _loadHabitBox() async {
  final otherService = OtherService();
  if (habitBox.isEmpty) {
    Category categoryHealth = categoryBox.values.firstWhere(
      (element) => element.title == "Health",
    );
    Category categoryWellness = categoryBox.values.firstWhere(
      (element) => element.title == "Wellness",
    );
    Category categoryKnowledge = categoryBox.values.firstWhere(
      (element) => element.title == "Knowledge",
    );
    var drinkWaterHabit = Habit(
      title: "Drink Water",
      categoryTitle: "Health",
      coinAmount: 10,
      creationDate: DateTime.now().subtract(Duration(days: 5)),
      completedDates: [
        DateTime.now().subtract(Duration(days: 1)),
        DateTime.now().subtract(Duration(days: 2)),
        DateTime.now().subtract(Duration(days: 3)),
      ],
    );

    var exerciseHabit = Habit(
      title: "Exercise",
      categoryTitle: "Health",
      coinAmount: 5,
      creationDate: DateTime.now().subtract(Duration(days: 2)),
      completedDates: [DateTime.now().subtract(Duration(days: 1))],
    );

    var readBookHabit = Habit(
      title: "Read a Book",
      categoryTitle: "Knowledge",
      coinAmount: 5,
      creationDate: DateTime.now(),
    );

    var meditationHabit = Habit(
      title: "Meditation",
      categoryTitle: "Wellness",
      coinAmount: 20,
      creationDate: DateTime.now(),
    );
    habitBox.addAll(<Habit>[
      drinkWaterHabit,
      exerciseHabit,
      readBookHabit,
      meditationHabit,
    ]);

    dateBox.add(DateSummary(
        date: otherService
            .normalizeDate(DateTime.now().subtract(Duration(days: 1)))
            .toString(),
        habitCompleted: [drinkWaterHabit, exerciseHabit],
        habitIncompleted: []));

    dateBox.add(DateSummary(
        date: otherService
            .normalizeDate(DateTime.now().subtract(Duration(days: 2)))
            .toString(),
        habitCompleted: [drinkWaterHabit],
        habitIncompleted: [exerciseHabit]));

    dateBox.add(DateSummary(
        date: otherService
            .normalizeDate(DateTime.now().subtract(Duration(days: 3)))
            .toString(),
        habitCompleted: [drinkWaterHabit],
        habitIncompleted: []));

    dateBox.add(DateSummary(
        date: otherService
            .normalizeDate(DateTime.now().subtract(Duration(days: 4)))
            .toString(),
        habitCompleted: [],
        habitIncompleted: [drinkWaterHabit]));

    dateBox.add(DateSummary(
        date: otherService
            .normalizeDate(DateTime.now().subtract(Duration(days: 5)))
            .toString(),
        habitCompleted: [],
        habitIncompleted: [drinkWaterHabit]));

    // Update the respective categories with the new habits
    categoryHealth.habits?.add(drinkWaterHabit);
    categoryHealth.habits?.add(exerciseHabit);
    categoryKnowledge.habits?.add(readBookHabit);
    categoryWellness.habits?.add(meditationHabit);

    // Save the updated categories back to the categoryBox
    await categoryBox.put(categoryHealth.key, categoryHealth);
    await categoryBox.put(categoryWellness.key, categoryWellness);
    await categoryBox.put(categoryKnowledge.key, categoryKnowledge);
  }
}

Future<void> _loadCoin() async {
  if (coinBox.isEmpty) {
    coinBox.add(Coin(coinAmount: 35));
  }
}

Future<void> _loadReward() async {
  if (rewardBox.isEmpty) {
    rewardBox.add(Reward(coinCost: 5, title: "Ice Cream!"));
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.cyanAccent),
        ),
        home: NavigationPage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {}

class NavigationPage extends StatefulWidget {
  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Number of tabs
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: TabBarView(
                  physics: BouncingScrollPhysics(),
                  children: [HomePage(), CategoryPage(), RewardPage()],
                ),
              ),
              // TabBar placed below the content
              Container(
                padding: EdgeInsets.only(right: 20, left: 20),
                color: Colors.cyanAccent.shade700,
                child: TabBar(
                  tabs: [
                    Tab(icon: Icon(Icons.home_filled, color: Colors.white)),
                    Tab(icon: Icon(Icons.category, color: Colors.white)),
                    Tab(icon: Icon(Icons.money, color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
