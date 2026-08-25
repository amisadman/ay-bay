import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/garage_vehicle_model.dart';
import '../models/garage_employee_model.dart';
import '../models/garage_part_model.dart';
import '../models/garage_expense_model.dart';
import '../services/garage_cloud_service.dart';

class GarageOwnerProvider extends ChangeNotifier {
  GarageCloudService? _cloudService;

  String? _garageId;
  String? _garageName;
  String? _role; // "Admin", "Mechanic", "Pending"

  String? get garageId => _garageId;
  String? get garageName => _garageName;
  String? get role => _role;

  List<GarageVehicleModel> _vehicles = [];
  List<GarageEmployeeModel> _employees = [];
  List<GaragePartModel> _parts = [];
  List<GarageExpenseModel> _expenses = [];
  bool _isLoading = false;

  List<GarageVehicleModel> get vehicles => _vehicles;
  List<GarageEmployeeModel> get employees => _employees;
  List<GaragePartModel> get parts => _parts;
  List<GarageExpenseModel> get expenses => _expenses;
  bool get isLoading => _isLoading;

  Future<void> initGarage(
      String id, String name, String userRole, String userName) async {
    _garageId = id;
    _garageName = name;
    _role = userRole;
    _cloudService = GarageCloudService(id);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('garage_id', id);
    await prefs.setString('garage_name', name);
    await prefs.setString('garage_role', userRole);
    await prefs.setString('garage_user_name', userName);

    await fetchVehicles();
  }

  Future<bool> checkExistingGarage() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('garage_id');
    final name = prefs.getString('garage_name');
    final r = prefs.getString('garage_role');

    if (id != null && name != null) {
      _garageId = id;
      _garageName = name;
      _role = r ?? 'Pending';
      _cloudService = GarageCloudService(id);
      await fetchVehicles();
      return true;
    }
    return false;
  }

  Future<void> leaveGarage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('garage_id');
    await prefs.remove('garage_name');
    await prefs.remove('garage_role');

    _garageId = null;
    _garageName = null;
    _role = null;
    _cloudService = null;

    _vehicles.clear();
    _employees.clear();
    _parts.clear();
    _expenses.clear();

    notifyListeners();
  }

  Future<void> fetchVehicles() async {
    if (_cloudService == null) return;

    _isLoading = true;
    notifyListeners();

    _vehicles = await _cloudService!.getVehicles();
    _employees = await _cloudService!.getEmployees();
    _parts = await _cloudService!.getParts();
    _expenses = await _cloudService!.getExpenses();

    // Sync role from cloud
    final prefs = await SharedPreferences.getInstance();
    final myName = prefs.getString('garage_user_name');
    if (myName != null) {
      final myEmp = _employees.where((e) => e.name == myName).firstOrNull;
      if (myEmp != null) {
        _role = myEmp.role;
        await prefs.setString('garage_role', _role!);
      }
    }

    // Sort vehicles
    _vehicles.sort((a, b) {
      const statusOrder = {
        'Pending': 0,
        'Repairing': 1,
        'Ready': 2,
        'Delivered': 3
      };
      final orderA = statusOrder[a.status] ?? 4;
      final orderB = statusOrder[b.status] ?? 4;
      return orderA.compareTo(orderB);
    });

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addVehicle(GarageVehicleModel vehicle) async {
    if (_cloudService == null) return;
    await _cloudService!.addVehicle(vehicle);
    await fetchVehicles();
  }

  Future<void> updateVehicleStatus(
      GarageVehicleModel vehicle, String newStatus) async {
    if (_cloudService == null) return;
    final updated = vehicle.copyWith(status: newStatus);
    await _cloudService!.updateVehicle(updated);
    await fetchVehicles();
  }

  Future<void> updateVehicle(GarageVehicleModel vehicle) async {
    if (_cloudService == null) return;
    await _cloudService!.updateVehicle(vehicle);
    await fetchVehicles();
  }

  Future<void> deleteVehicle(String id) async {
    if (_cloudService == null) return;
    await _cloudService!.deleteVehicle(id);
    await fetchVehicles();
  }

  Future<void> addEmployee(GarageEmployeeModel emp) async {
    if (_cloudService == null) return;
    await _cloudService!.addEmployee(emp);
    await fetchVehicles();
  }

  Future<void> updateEmployeeRole(String empName, String newRole) async {
    if (_cloudService == null) return;
    await _cloudService!.updateEmployeeRole(empName, newRole);
    await fetchVehicles();
  }

  // --- Parts ---
  Future<void> addPart(GaragePartModel part) async {
    if (_cloudService == null) return;
    await _cloudService!.addPart(part);
    await fetchVehicles();
  }

  Future<void> updatePart(GaragePartModel part) async {
    if (_cloudService == null) return;
    await _cloudService!.updatePart(part);
    await fetchVehicles();
  }

  Future<void> deletePart(String id) async {
    if (_cloudService == null) return;
    await _cloudService!.deletePart(id);
    await fetchVehicles();
  }

  // --- Expenses ---
  Future<void> addExpense(GarageExpenseModel exp) async {
    if (_cloudService == null) return;
    await _cloudService!.addExpense(exp);
    await fetchVehicles();
  }

  Future<void> deleteExpense(String id) async {
    if (_cloudService == null) return;
    await _cloudService!.deleteExpense(id);
    await fetchVehicles();
  }
}
