import 'package:hive/hive.dart';

part 'coin.g.dart';

@HiveType(typeId: 3)
class Coin extends HiveObject {
  @HiveField(0)
  int coinAmount = 0;

  Coin({
    required this.coinAmount,
  });
}
