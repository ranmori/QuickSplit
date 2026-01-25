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
    this.individualTotals,
  });

  // --- 1. TO MAP (Saves to Firestore) ---
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
      'individualTotals': individualTotals,
    };
  }

  // --- 2. FROM MAP (Reads from Firestore) ---
  factory SplitRecord.fromMap(Map<String, dynamic> map, String docId) {
    return SplitRecord(
      id: docId, // Use the Firestore document ID
      title: map['title'] ?? '',
      totalAmount: map['totalAmount'] ?? '',
      dateTime: map['dateTime'],
      // Firestore returns Lists as List<dynamic>, so we cast it back safely
      items: List<Map<String, dynamic>>.from(map['items'] ?? []),
      peopleCount: map['peopleCount'] ?? 0,
      perPersonAmount: map['perPersonAmount'] ?? '',
      subtotal: (map['subtotal'] ?? 0.0).toDouble(),
      tax: (map['tax'] ?? 0.0).toDouble(),
      tip: (map['tip'] ?? 0.0).toDouble(),
      // Converting the map back to double values safely
      individualTotals: map['individualTotals'] != null 
          ? Map<String, double>.from(map['individualTotals'].map((k, v) => MapEntry(k, v.toDouble())))
          : null,
    );
  }
}