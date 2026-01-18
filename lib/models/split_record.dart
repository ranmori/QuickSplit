// lib/models/split_record.dart



class SplitRecord {
  final String title;
  final String totalAmount;
  final String dateTime;
  final int peopleCount;
  final String perPersonAmount;

  SplitRecord({
    required this.title,
    required this.totalAmount,
    required this.dateTime,
    required this.peopleCount,
    required this.perPersonAmount,
  });
}