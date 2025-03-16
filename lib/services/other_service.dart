import 'package:flutter/material.dart';

class OtherService {
  String formatDate(DateTime date) {
    return '${date.day.toString()} ${convertMonth(date.month)} ${date.year.toString()}';
  }

  String convertMonth(int month) {
    switch (month) {
      case 1:
        return "January";
      case 2:
        return "February";
      case 3:
        return "March";
      case 4:
        return "April";
      case 5:
        return "May";
      case 6:
        return "June";
      case 7:
        return "July";
      case 8:
        return "August";
      case 9:
        return "September";
      case 10:
        return "October";
      case 11:
        return "November";
      case 12:
        return "December";
      default:
        return "";
    }
  }

  SnackBar message(String message) {
    return SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.only(bottom: 80, left: 16, right: 16),
      duration: Duration(seconds: 1), // Shortens the display time
    );
  }

  DateTime normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}
