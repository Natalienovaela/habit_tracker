import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';

class MyHeatMap extends StatelessWidget {
  const MyHeatMap({super.key});

  @override
  Widget build(BuildContext context) {
    return HeatMap(
      datasets: {
        DateTime(2025, 3, 12): 1,
        DateTime(2025, 3, 13): 30,
        DateTime(2025, 3, 14): 10,
        DateTime(2025, 3, 15): 16,
        DateTime(2025, 3, 16): 7,
      },
      startDate: DateTime.now().subtract(Duration(days: 30)),
      endDate: DateTime.now().add(Duration(days: 40)),
      colorMode: ColorMode.opacity,
      defaultColor: Colors.white,
      size: 25,
      showText: true,
      textColor: Colors.cyan[800],
      scrollable: true,
      colorsets: {
        1: Colors.cyan[500]!, // Lightest cyan
        5: Colors.cyan[400]!,
        10: Colors.cyan[300]!,
        15: Colors.cyan[200]!,
        20: Colors.cyan[100]!, // Medium cyan
      },
      onClick: (date) {},
    );
  }
}
