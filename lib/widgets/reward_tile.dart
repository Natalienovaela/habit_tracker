import 'package:flutter/material.dart';
import 'package:namer_app/boxes.dart';
import 'package:namer_app/models/reward.dart';
import 'package:namer_app/pages/reward_page.dart';
import 'package:namer_app/services/coin_service.dart';
import 'package:namer_app/services/other_service.dart';

class RewardTile extends StatelessWidget {
  const RewardTile({super.key, required this.reward});

  final Reward reward;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.cyan[50],
      child: Padding(
        padding: const EdgeInsets.only(
          top: 10,
          bottom: 10,
          right: 20,
          left: 10,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                  icon: Icon(Icons.numbers, size: 25, fill: 0.9),
                  color: Colors.cyan[700],
                  onPressed: () async {},
                ),
                Text(reward.title, style: TextStyle(color: Colors.black87)),
              ],
            ),
            TextButton(
              onPressed: () {
                _showUseDialog(context, reward);
              },
              style: TextButton.styleFrom(
                backgroundColor:
                    Colors.cyan[500], // Set the background color to cyan500
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      4), // Set a smaller border radius for less rounding
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.attach_money, color: Colors.amber),
                  Text(
                    '${reward.coinCost}',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium!
                        .copyWith(color: Colors.white),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void _showUseDialog(BuildContext context, Reward reward) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text("Confirm Redeem"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Item: ${reward.title}"),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.attach_money, color: Colors.amber),
                      Text(
                        '${reward.coinCost}',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium!
                            .copyWith(color: Colors.black),
                      ),
                    ],
                  ),
                  //Text("Price: \$${reward.coinCost}"),
                  SizedBox(height: 10),
                  Text("Are you sure you want to redeem this item?"),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () =>
                    Navigator.pop(context), // Close the dialog (Cancel)
                child: Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () {
                  final otherService = OtherService();
                  try {
                    final coinService = CoinService();
                    coinService.redeem(reward.coinCost);
                    rewardBox.delete(reward.key);
                    ScaffoldMessenger.of(context).showSnackBar(
                        otherService.message("Item redeemed successfully."));
                  } catch (error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        otherService.message("Failed to redeem item: $error"));
                  }
                  Navigator.pop(
                      context); // Close the dialog after action is taken
                },
                child: Text("Redeem"),
              ),
            ],
          );
        });
      },
    );
  }
}
