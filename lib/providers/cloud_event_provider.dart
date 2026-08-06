import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aybay_flutter/models/cloud_event_model.dart';
import 'dart:math';

class CloudEventProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<CloudEventModel> _myEvents = [];
  List<CloudEventModel> get myEvents => _myEvents;

  // Stream sub for my events
  // We'll just fetch events where the user's UID is in the members list
  void listenToMyEvents(String uid) {
    _firestore
        .collection('events')
        .where('members', arrayContains: uid)
        .snapshots()
        .listen((snapshot) {
      _myEvents = snapshot.docs
          .map((doc) => CloudEventModel.fromMap(doc.data(), doc.id))
          .toList();
      notifyListeners();
    });
  }

  Future<String> createEvent(String title, String description, double budget,
      String creatorUid) async {
    // generate a random 6 char invite code
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    final inviteCode = String.fromCharCodes(Iterable.generate(
        6, (_) => chars.codeUnitAt(random.nextInt(chars.length))));

    final newEvent = CloudEventModel(
      eventId: '', // Firestore generates this
      title: title,
      description: description,
      inviteCode: inviteCode,
      budget: budget,
      createdBy: creatorUid,
      members: [creatorUid],
    );

    final docRef = await _firestore.collection('events').add(newEvent.toMap());
    return docRef.id;
  }

  Future<bool> joinEvent(String inviteCode, String uid) async {
    final query = await _firestore
        .collection('events')
        .where('inviteCode', isEqualTo: inviteCode)
        .get();
    if (query.docs.isEmpty) {
      return false; // Code not found
    }
    final doc = query.docs.first;
    final event = CloudEventModel.fromMap(doc.data(), doc.id);

    if (!event.members.contains(uid)) {
      final updatedMembers = List<String>.from(event.members)..add(uid);
      await _firestore
          .collection('events')
          .doc(event.eventId)
          .update({'members': updatedMembers});
    }
    return true;
  }

  Stream<List<CloudEventExpenseModel>> streamEventExpenses(String eventId) {
    return _firestore
        .collection('events')
        .doc(eventId)
        .collection('expenses')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CloudEventExpenseModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> addExpense(
      String eventId, CloudEventExpenseModel expense) async {
    await _firestore
        .collection('events')
        .doc(eventId)
        .collection('expenses')
        .add(expense.toMap());
  }

  Future<void> updateEventBudget(String eventId, double newBudget) async {
    await _firestore
        .collection('events')
        .doc(eventId)
        .update({'budget': newBudget});
  }
}
