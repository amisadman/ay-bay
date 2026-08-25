import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/gym_member_model.dart';
import '../models/gym_payment_model.dart';

class GymEmployeeModel {
  final String name;
  final String role; // "Admin", "Trainer", "Pending"

  GymEmployeeModel({required this.name, required this.role});

  Map<String, dynamic> toMap() => {'name': name, 'role': role};
  factory GymEmployeeModel.fromMap(Map<String, dynamic> map) =>
      GymEmployeeModel(name: map['name'] ?? '', role: map['role'] ?? 'Pending');
}

class GymCloudService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String gymId;

  GymCloudService(this.gymId);

  // --- Members ---
  Future<GymMemberModel> addMember(GymMemberModel member) async {
    final docRef = await _db
        .collection('gyms')
        .doc(gymId)
        .collection('members')
        .add(member.toMap());
    return member.copyWith(cloudId: docRef.id);
  }

  Future<void> updateMember(GymMemberModel member, String stringId) async {
    await _db
        .collection('gyms')
        .doc(gymId)
        .collection('members')
        .doc(stringId)
        .update(member.toMap());
  }

  Future<void> deleteMember(String stringId) async {
    await _db
        .collection('gyms')
        .doc(gymId)
        .collection('members')
        .doc(stringId)
        .delete();
  }

  Future<List<GymMemberModel>> getMembers() async {
    final snap =
        await _db.collection('gyms').doc(gymId).collection('members').get();
    return snap.docs
        .map((doc) => GymMemberModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  // --- Employees ---
  Future<void> addEmployee(GymEmployeeModel emp) async {
    await _db
        .collection('gyms')
        .doc(gymId)
        .collection('employees')
        .doc(emp.name)
        .set(emp.toMap());
  }

  Future<void> updateEmployeeRole(String empName, String newRole) async {
    await _db
        .collection('gyms')
        .doc(gymId)
        .collection('employees')
        .doc(empName)
        .update({'role': newRole});
  }

  Future<List<GymEmployeeModel>> getEmployees() async {
    final snap =
        await _db.collection('gyms').doc(gymId).collection('employees').get();
    return snap.docs
        .map((doc) => GymEmployeeModel.fromMap(doc.data()))
        .toList();
  }

  // --- Payments ---
  Future<GymPaymentModel> addPayment(GymPaymentModel payment) async {
    final docRef = await _db
        .collection('gyms')
        .doc(gymId)
        .collection('payments')
        .add(payment.toMap());
    return payment.copyWith(id: docRef.id);
  }

  Future<List<GymPaymentModel>> getPayments() async {
    final snap =
        await _db.collection('gyms').doc(gymId).collection('payments').get();
    return snap.docs
        .map((doc) => GymPaymentModel.fromMap(doc.data(), doc.id))
        .toList();
  }
}
