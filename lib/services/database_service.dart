import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseService {
  // 1. Get an instance of the database and the current user
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 2. This function saves your history item
  Future<void> saveHistoryItem(String content) async {
    try {
      String? uid = _auth.currentUser?.uid;
      
      if (uid != null) {
        // This saves data at: users -> [Your ID] -> history -> [New Random ID]
        await _db.collection('users').doc(uid).collection('history').add({
          'text': content,
          'timestamp': FieldValue.serverTimestamp(), // This ensures correct timing
        });
        print("Item saved successfully!");
      }
    } catch (e) {
      print("Error saving to Firestore: $e");
    }
  }

  // 3. This function "Listens" to the history and updates the UI automatically
  Stream<QuerySnapshot> getHistoryStream() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      // Return empty stream when not authenticated
      return const Stream.empty();
    }
    return _db
        .collection('users')
        .doc(uid)
        .collection('history')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }}