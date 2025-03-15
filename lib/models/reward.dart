import 'package:hive/hive.dart';

part 'reward.g.dart';

@HiveType(typeId: 2)
class Reward extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  int coinCost;

  Reward({
    required this.title,
    required this.coinCost,
  });
}
