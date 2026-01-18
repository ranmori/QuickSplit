import 'package:flutter/material.dart';

class SplitSummaryData {
  final double subtotal;
  final double tax;
  final double tip;
  final double total;
  final List<Map<String, dynamic>> items;
  final List<TextEditingController> people;
  final Map<String, double> individualTotals;
  final String dateString;

  SplitSummaryData({
    required this.subtotal,
    required this.tax,
    required this.tip,
    required this.total,
    required this.items,
    required this.individualTotals,
    required this.dateString,
    required this.people,
  });
}