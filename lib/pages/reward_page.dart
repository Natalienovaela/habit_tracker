import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:namer_app/boxes.dart';
import 'package:namer_app/models/coin.dart';
import 'package:namer_app/models/reward.dart';
import 'package:namer_app/services/other_service.dart';
import 'package:namer_app/widgets/reward_tile.dart';

class RewardPage extends StatefulWidget {
  const RewardPage({super.key});

  @override
  State<RewardPage> createState() => _RewardPageState();
}

class _RewardPageState extends State<RewardPage> {
  final otherService = OtherService();
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Center(
                  child: Text(
                    "Reward",
                    style: theme.textTheme.headlineMedium!
                        .copyWith(color: Colors.cyan[900]),
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.attach_money, color: Colors.amber),
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Center(
                    child: ValueListenableBuilder(
                        valueListenable: coinBox.listenable(),
                        builder: (context, Box coinBox, _) {
                          return Text(
                            '${coinBox.values.first.coinAmount}',
                            style: theme.textTheme.bodyLarge!
                                .copyWith(color: Colors.cyan[900]),
                          );
                        }),
                  ),
                ),
              ],
            ),
          ],
        ),
        Expanded(
          child: ValueListenableBuilder(
            valueListenable: rewardBox.listenable(),
            builder: (context, Box rewardBox, _) {
              final rewards = rewardBox.values.toList();
              rewards.sort((a, b) => a.title.compareTo(b.title));
              return ListView.builder(
                padding: EdgeInsets.only(right: 5, left: 5, bottom: 5),
                physics: BouncingScrollPhysics(),
                itemCount: rewards.length,
                itemBuilder: (context, index) {
                  final reward = rewards[index];
                  return Dismissible(
                    key: Key(reward.key.toString()),
                    direction: DismissDirection.horizontal,
                    confirmDismiss: (direction) async {
                      if (direction == DismissDirection.startToEnd) {
                        return true;
                      } else if (direction == DismissDirection.endToStart) {
                        _showEditRewardDialog(context, reward);
                        return false;
                      }
                      return false;
                    },
                    onDismissed: (direction) {
                      // Handle Delete Action
                      rewardBox.delete(reward.key);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("${reward.title} deleted"),
                          behavior: SnackBarBehavior.floating,
                          margin:
                              EdgeInsets.only(bottom: 80, left: 16, right: 16),
                          duration:
                              Duration(seconds: 1), // Shortens the display time
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
                        children: [RewardTile(reward: reward)],
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
          _showAddRewardDialog(context);
        },
        backgroundColor: Colors.cyan[500],
        foregroundColor: Colors.white,
        shape: CircleBorder(),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showAddRewardDialog(BuildContext context) {
    String rewardTitle = "";
    int coinCost = 0;
    String? errorTitleMessage;
    String? errorCostMessage;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text("Add New Reward"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: InputDecoration(
                        labelText: "Reward Title",
                        errorText: errorTitleMessage),
                    onChanged: (value) => rewardTitle = value,
                  ),
                  TextField(
                    decoration: InputDecoration(
                        labelText: "Cost", errorText: errorCostMessage),
                    onChanged: (value) => coinCost = int.parse(value),
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
                  if (rewardTitle == "") {
                    setState(() {
                      errorTitleMessage = "Reward title field is required";
                    });
                  }
                  if (coinCost == 0) {
                    setState(() {
                      errorCostMessage = "Cost should not be zero";
                    });
                  } else {
                    setState(() {
                      errorCostMessage = null;
                      errorTitleMessage = null;
                    });
                    try {
                      rewardBox
                          .add(Reward(title: rewardTitle, coinCost: coinCost));
                    } catch (error) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Failed to add reward: $error"),
                          behavior: SnackBarBehavior.floating,
                          margin:
                              EdgeInsets.only(bottom: 80, left: 16, right: 16),
                          duration:
                              Duration(seconds: 1), // Shortens the display time
                        ),
                      );
                    }
                    Navigator.pop(context); // Close the dialog
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

  void _showEditRewardDialog(BuildContext context, Reward reward) {
    String rewardTitle = reward.title;
    int coinCost = reward.coinCost;
    final titleController = TextEditingController(text: rewardTitle);
    final costController = TextEditingController(text: coinCost.toString());
    String? errorTitleMessage;
    String? errorCostMessage;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text("Edit Reward"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                        labelText: "Reward Title",
                        errorText: errorTitleMessage),
                    onChanged: (value) => rewardTitle = value,
                  ),
                  TextField(
                    controller: costController,
                    decoration: InputDecoration(
                        labelText: "Cost", errorText: errorCostMessage),
                    onChanged: (value) => coinCost = int.parse(value),
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
                  if (rewardTitle == "") {
                    setState(() {
                      errorTitleMessage = "Reward title field is required";
                    });
                  }
                  if (coinCost == 0) {
                    setState(() {
                      errorCostMessage = "Cost should not be zero";
                    });
                  } else {
                    setState(() {
                      errorCostMessage = null;
                      errorTitleMessage = null;
                    });
                    try {
                      rewardBox.put(reward.key,
                          Reward(title: rewardTitle, coinCost: coinCost));
                    } catch (error) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Failed to add reward: $error"),
                          behavior: SnackBarBehavior.floating,
                          margin:
                              EdgeInsets.only(bottom: 80, left: 16, right: 16),
                          duration:
                              Duration(seconds: 1), // Shortens the display time
                        ),
                      );
                    }
                    Navigator.pop(context); // Close the dialog
                  }
                },
                child: Text("Save"),
              ),
            ],
          );
        });
      },
    );
  }
}
