import 'package:flutter/material.dart';
import 'package:namer_app/models/reward.dart';
import 'package:namer_app/pages/reward_page.dart';

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
            Row(
              children: [
                Icon(Icons.attach_money, color: Colors.amber),
                Text('${reward.coinCost}'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
