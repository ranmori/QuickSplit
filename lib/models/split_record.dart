class SplitRecord {
  final String id;
  final String title;
  final String totalAmount;
  final String? dateTime;
  final List<Map<String, dynamic>> items;
  final int peopleCount;
  final String perPersonAmount;
  final double subtotal;
  final double tax; 
  final double tip;
  // This is the missing piece for dynamic names!
  final Map<String, double>? individualTotals; 
  

  SplitRecord({
    required this.id,
    required this.title,
    required this.totalAmount,
    required this.dateTime,
    required this.items,
    required this.peopleCount,
    required this.perPersonAmount,
    this.subtotal = 0.0,
    this.tax = 0.0,
    this.tip = 0.0,
    this.individualTotals, // Add this to constructor
  });
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'totalAmount': totalAmount,
      'dateTime': dateTime,
      'items': items,
      'peopleCount': peopleCount,
      'perPersonAmount': perPersonAmount,
      'subtotal': subtotal,
      'tax': tax,
      'tip': tip,
      'individualTotals': individualTotals, // Include in map
    };
  }
}