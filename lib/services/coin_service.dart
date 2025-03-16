import 'package:namer_app/boxes.dart';
import 'package:namer_app/models/coin.dart';

class CoinService {
  void redeem(int amount) {
    Coin coin = coinBox.values.toList()[0];

    if (coin.coinAmount < amount) {
      throw Exception("Coin available is less than the specified amount");
    } else {
      print('coin amount ${coin.coinAmount}');
      int newAmount = coin.coinAmount - amount;
      print(newAmount);
      coinBox.put(coin.key, Coin(coinAmount: newAmount));
    }
  }
}
