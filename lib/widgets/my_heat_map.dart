import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';

class MyHeatMap extends StatelessWidget {
  const MyHeatMap({super.key, required this.datasets});

  final Map<DateTime, int> datasets;

  @override
  Widget build(BuildContext context) {
    return HeatMap(
      datasets: datasets,
      startDate: DateTime.now().subtract(Duration(days: 30)),
      endDate: DateTime.now().add(Duration(days: 40)),
      colorMode: ColorMode.opacity,
      defaultColor: Colors.grey[100],
      size: 25,
      showText: true,
      textColor: Colors.cyan[900],
      scrollable: true,
      colorsets: {
        1: Colors.cyan[700]!, // Lightest cyan
        2: Colors.cyan[500]!,
        3: Colors.cyan[300]!,
        4: Colors.cyan[100]!,
        5: Colors.cyan[50]!, // Medium cyan
      },
      onClick: (date) {},
    );
  }
}
