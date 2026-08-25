import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/gym_member_model.dart';
import '../models/gym_payment_model.dart';
import '../services/gym_cloud_service.dart';

class GymOwnerProvider extends ChangeNotifier {
  GymCloudService? _cloudService;

  String? _gymId;
  String? _gymName;
  String? _role;

  String? get gymId => _gymId;
  String? get gymName => _gymName;
  String? get role => _role;

  List<GymMemberModel> _members = [];
  List<GymEmployeeModel> _employees = [];
  List<GymPaymentModel> _payments = [];
  bool _isLoading = false;

  List<GymMemberModel> get members => _members;
  List<GymEmployeeModel> get employees => _employees;
  List<GymPaymentModel> get payments => _payments;
  bool get isLoading => _isLoading;

  Future<void> initGym(
      String id, String name, String userRole, String userName) async {
    _gymId = id;
    _gymName = name;
    _role = userRole;
    _cloudService = GymCloudService(id);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('gym_id', id);
    await prefs.setString('gym_name', name);
    await prefs.setString('gym_role', userRole);
    await prefs.setString('gym_user_name', userName);

    await fetchMembers();
  }

  Future<bool> checkExistingGym() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('gym_id');
    final name = prefs.getString('gym_name');
    final r = prefs.getString('gym_role');

    if (id != null && name != null) {
      _gymId = id;
      _gymName = name;
      _role = r ?? 'Pending';
      _cloudService = GymCloudService(id);
      await fetchMembers();
      return true;
    }
    return false;
  }

  Future<void> leaveGym() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('gym_id');
    await prefs.remove('gym_name');
    await prefs.remove('gym_role');

    _gymId = null;
    _gymName = null;
    _role = null;
    _cloudService = null;

    _members.clear();
    _employees.clear();
    _payments.clear();

    notifyListeners();
  }

  Future<void> fetchMembers() async {
    if (_cloudService == null) return;

    _isLoading = true;
    notifyListeners();

    _members = await _cloudService!.getMembers();
    _employees = await _cloudService!.getEmployees();
    _payments = await _cloudService!.getPayments();

    // Sync role
    final prefs = await SharedPreferences.getInstance();
    final myName = prefs.getString('gym_user_name');
    if (myName != null) {
      final myEmp = _employees.where((e) => e.name == myName).firstOrNull;
      if (myEmp != null) {
        _role = myEmp.role;
        await prefs.setString('gym_role', _role!);
      }
    }

    // Auto-update status based on expiry date
    final now = DateTime.now();
    bool needsUpdate = false;
    for (var i = 0; i < _members.length; i++) {
      try {
        final expiry = DateTime.parse(_members[i].expiryDate);
        final isExpired = now.isAfter(expiry);
        final currentStatus = _members[i].status;
        final newStatus = isExpired ? 'Expired' : 'Active';

        if (currentStatus != newStatus) {
          _members[i] = _members[i].copyWith(status: newStatus);
          await _cloudService!.updateMember(_members[i], _members[i].cloudId!);
          needsUpdate = true;
        }
      } catch (e) {
        // Parse error
      }
    }

    if (needsUpdate) {
      _members = await _cloudService!.getMembers();
    }
    _members.sort((a, b) => a.expiryDate.compareTo(b.expiryDate));

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addMember(GymMemberModel member) async {
    if (_cloudService == null) return;
    await _cloudService!.addMember(member);
    await fetchMembers();
  }

  Future<void> updateMember(GymMemberModel member) async {
    if (_cloudService == null || member.cloudId == null) return;
    await _cloudService!.updateMember(member, member.cloudId!);
    await fetchMembers();
  }

  Future<void> deleteMember(String stringId) async {
    if (_cloudService == null) return;
    await _cloudService!.deleteMember(stringId);
    await fetchMembers();
  }

  Future<void> addEmployee(GymEmployeeModel emp) async {
    if (_cloudService == null) return;
    await _cloudService!.addEmployee(emp);
    await fetchMembers();
  }

  Future<void> updateEmployeeRole(String empName, String newRole) async {
    if (_cloudService == null) return;
    await _cloudService!.updateEmployeeRole(empName, newRole);
    await fetchMembers();
  }

  // --- Payments ---
  Future<void> addPayment(GymPaymentModel payment) async {
    if (_cloudService == null) return;
    await _cloudService!.addPayment(payment);
    await fetchMembers();
  }
}
