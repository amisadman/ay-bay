import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/garage_vehicle_model.dart';
import '../models/garage_employee_model.dart';
import '../models/garage_part_model.dart';
import '../models/garage_expense_model.dart';

class GarageCloudService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String garageId;

  GarageCloudService(this.garageId);

  // --- Vehicles ---
  Future<GarageVehicleModel> addVehicle(GarageVehicleModel vehicle) async {
    final docRef = await _db
        .collection('garages')
        .doc(garageId)
        .collection('vehicles')
        .add(vehicle.toMap());
    return vehicle.copyWith(id: docRef.id);
  }

  Future<void> updateVehicle(GarageVehicleModel vehicle) async {
    if (vehicle.id == null) return;
    await _db
        .collection('garages')
        .doc(garageId)
        .collection('vehicles')
        .doc(vehicle.id)
        .update(vehicle.toMap());
  }

  Future<void> deleteVehicle(String id) async {
    await _db
        .collection('garages')
        .doc(garageId)
        .collection('vehicles')
        .doc(id)
        .delete();
  }

  Future<List<GarageVehicleModel>> getVehicles() async {
    final snap = await _db
        .collection('garages')
        .doc(garageId)
        .collection('vehicles')
        .get();
    return snap.docs
        .map((doc) => GarageVehicleModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  // --- Employees (Mechanics/Admin) ---
  Future<void> addEmployee(GarageEmployeeModel emp) async {
    await _db
        .collection('garages')
        .doc(garageId)
        .collection('employees')
        .doc(emp.name)
        .set(emp.toMap());
  }

  Future<void> updateEmployeeRole(String empName, String newRole) async {
    await _db
        .collection('garages')
        .doc(garageId)
        .collection('employees')
        .doc(empName)
        .update({'role': newRole});
  }

  Future<void> removeEmployee(String empName) async {
    await _db
        .collection('garages')
        .doc(garageId)
        .collection('employees')
        .doc(empName)
        .delete();
  }

  Future<List<GarageEmployeeModel>> getEmployees() async {
    final snap = await _db
        .collection('garages')
        .doc(garageId)
        .collection('employees')
        .get();
    return snap.docs
        .map((doc) => GarageEmployeeModel.fromMap(doc.data()))
        .toList();
  }

  // --- Parts (Inventory) ---
  Future<GaragePartModel> addPart(GaragePartModel part) async {
    final docRef = await _db
        .collection('garages')
        .doc(garageId)
        .collection('parts')
        .add(part.toMap());
    return part.copyWith(id: docRef.id);
  }

  Future<void> updatePart(GaragePartModel part) async {
    if (part.id == null) return;
    await _db
        .collection('garages')
        .doc(garageId)
        .collection('parts')
        .doc(part.id)
        .update(part.toMap());
  }

  Future<void> deletePart(String id) async {
    await _db
        .collection('garages')
        .doc(garageId)
        .collection('parts')
        .doc(id)
        .delete();
  }

  Future<List<GaragePartModel>> getParts() async {
    final snap =
        await _db.collection('garages').doc(garageId).collection('parts').get();
    return snap.docs
        .map((doc) => GaragePartModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  // --- Expenses ---
  Future<GarageExpenseModel> addExpense(GarageExpenseModel exp) async {
    final docRef = await _db
        .collection('garages')
        .doc(garageId)
        .collection('expenses')
        .add(exp.toMap());
    return exp.copyWith(id: docRef.id);
  }

  Future<void> deleteExpense(String id) async {
    await _db
        .collection('garages')
        .doc(garageId)
        .collection('expenses')
        .doc(id)
        .delete();
  }

  Future<List<GarageExpenseModel>> getExpenses() async {
    final snap = await _db
        .collection('garages')
        .doc(garageId)
        .collection('expenses')
        .get();
    return snap.docs
        .map((doc) => GarageExpenseModel.fromMap(doc.data(), doc.id))
        .toList();
  }
}
