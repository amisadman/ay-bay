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

  Future<String> joinEvent(String inviteCode, String uid) async {
    final query = await _firestore
        .collection('events')
        .where('inviteCode', isEqualTo: inviteCode)
        .get();
    if (query.docs.isEmpty) {
      return 'not_found';
    }
    final doc = query.docs.first;
    final event = CloudEventModel.fromMap(doc.data(), doc.id);

    if (!event.members.contains(uid)) {
      final updatedMembers = List<String>.from(event.members)..add(uid);
      await _firestore
          .collection('events')
          .doc(event.eventId)
          .update({'members': updatedMembers});
      return 'success';
    } else {
      return 'already_joined';
    }
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

  Future<void> updateEventTitle(String eventId, String newTitle) async {
    await _firestore
        .collection('events')
        .doc(eventId)
        .update({'title': newTitle});
  }

  Future<void> updateExpense(String eventId, String expenseId, String newTitle, double newAmount) async {
    await _firestore
        .collection('events')
        .doc(eventId)
        .collection('expenses')
        .doc(expenseId)
        .update({
      'description': newTitle,
      'amount': newAmount,
    });
  }

  Future<void> deleteExpense(String eventId, String expenseId) async {
    await _firestore
        .collection('events')
        .doc(eventId)
        .collection('expenses')
        .doc(expenseId)
        .delete();
  }

  Future<void> unjoinEvent(String eventId, String uid) async {
    final docRef = _firestore.collection('events').doc(eventId);
    final doc = await docRef.get();
    if (doc.exists) {
      final event = CloudEventModel.fromMap(doc.data()!, doc.id);
      final updatedMembers = List<String>.from(event.members)..remove(uid);
      await docRef.update({'members': updatedMembers});
    }
  }

  Future<void> deleteEvent(String eventId) async {
    await _firestore.collection('events').doc(eventId).delete();
  }
}
