import 'package:flutter/material.dart';
import '../models/shop_owner_model.dart';
import '../services/shop_cloud_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShopOwnerProvider extends ChangeNotifier {
  ShopCloudService? _cloudService;

  String? _shopId;
  String? _shopName;
  String? _role; // "Admin" or "Staff"

  String? get shopId => _shopId;
  String? get shopName => _shopName;
  String? get role => _role;

  List<ProductModel> _products = [];
  List<SaleModel> _sales = [];
  List<CustomerModel> _customers = [];
  List<EmployeeModel> _employees = [];
  List<LedgerModel> _ledger = [];

  bool _isLoading = false;

  List<ProductModel> get products => _products;
  List<SaleModel> get sales => _sales;
  List<CustomerModel> get customers => _customers;
  List<EmployeeModel> get employees => _employees;
  List<LedgerModel> get ledger => _ledger;
  bool get isLoading => _isLoading;

  Future<void> initShop(
      String id, String name, String userRole, String userName) async {
    _shopId = id;
    _shopName = name;
    _role = userRole;
    _cloudService = ShopCloudService(id);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('shop_id', id);
    await prefs.setString('shop_name', name);
    await prefs.setString('shop_role', userRole);
    await prefs.setString('shop_user_name', userName);

    await loadData();
  }

  Future<bool> checkExistingShop() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('shop_id');
    final name = prefs.getString('shop_name');
    final r = prefs.getString('shop_role');

    if (id != null && name != null) {
      _shopId = id;
      _shopName = name;
      _role = r ?? 'Staff';
      _cloudService = ShopCloudService(id);
      await loadData();
      return true;
    }
    return false;
  }

  Future<void> leaveShop() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('shop_id');
    await prefs.remove('shop_name');
    await prefs.remove('shop_role');

    _shopId = null;
    _shopName = null;
    _role = null;
    _cloudService = null;

    _products.clear();
    _sales.clear();
    _customers.clear();
    _employees.clear();
    _ledger.clear();

    notifyListeners();
  }

  Future<void> loadData() async {
    if (_cloudService == null) return;

    _isLoading = true;
    notifyListeners();

    _products = await _cloudService!.getProducts();
    _sales = await _cloudService!.getSales();
    _customers = await _cloudService!.getCustomers();
    _employees = await _cloudService!.getEmployees();
    _ledger = await _cloudService!.getLedger();

    // Sync role from cloud
    final prefs = await SharedPreferences.getInstance();
    final myName = prefs.getString('shop_user_name');
    if (myName != null) {
      final myEmp = _employees.where((e) => e.name == myName).firstOrNull;
      if (myEmp != null) {
        _role = myEmp.role;
        await prefs.setString('shop_role', myEmp.role);
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  // --- Products ---
  Future<void> addProduct(ProductModel prod) async {
    final newProd = await _cloudService!.addProduct(prod);
    _products.add(newProd);
    notifyListeners();
  }

  Future<void> updateProduct(ProductModel prod) async {
    await _cloudService!.updateProduct(prod);
    final index = _products.indexWhere((p) => p.id == prod.id);
    if (index != -1) {
      _products[index] = prod;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String id) async {
    await _cloudService!.deleteProduct(id);
    _products.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  // --- Sales ---
  Future<void> recordSale(List<SaleItem> items,
      {double discount = 0, String? customerId, String? employeeId}) async {
    double totalAmt = 0;
    double totalProfit = 0;

    for (var item in items) {
      totalAmt += (item.price * item.quantity);
      totalProfit += ((item.price - item.cost) * item.quantity);

      // Reduce stock
      final pIndex = _products.indexWhere((p) => p.id == item.productId);
      if (pIndex != -1) {
        final p = _products[pIndex];
        final newStock = p.stock - item.quantity;
        final updatedProd = p.copyWith(stock: newStock < 0 ? 0 : newStock);
        await updateProduct(updatedProd);
      }
    }

    totalAmt -= discount;

    final sale = SaleModel(
      date: DateTime.now().toIso8601String(),
      items: items,
      totalAmount: totalAmt,
      totalProfit: totalProfit,
      discount: discount,
      customerId: customerId,
      employeeId: employeeId,
    );

    final newSale = await _cloudService!.recordSale(sale);
    _sales.add(newSale);

    if (customerId != null) {
      final cIndex = _customers.indexWhere((c) => c.id == customerId);
      if (cIndex != -1) {
        final c = _customers[cIndex];
        _customers[cIndex] = c.copyWith(debt: c.debt + totalAmt);
      }
    }

    notifyListeners();
  }

  // --- Customers ---
  Future<void> addCustomer(CustomerModel cust) async {
    final newCust = await _cloudService!.addCustomer(cust);
    _customers.add(newCust);
    notifyListeners();
  }

  Future<void> updateCustomer(CustomerModel cust) async {
    await _cloudService!.updateCustomer(cust);
    final index = _customers.indexWhere((c) => c.id == cust.id);
    if (index != -1) {
      _customers[index] = cust;
      notifyListeners();
    }
  }

  // --- Employees ---
  Future<void> addEmployee(EmployeeModel emp) async {
    final newEmp = await _cloudService!.addEmployee(emp);
    _employees.add(newEmp);
    notifyListeners();
  }

  Future<void> removeEmployee(String id) async {
    await _cloudService!.removeEmployee(id);
    _employees.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  Future<void> updateEmployeeRole(String id, String newRole) async {
    await _cloudService!.updateEmployeeRole(id, newRole);
    final index = _employees.indexWhere((e) => e.id == id);
    if (index != -1) {
      _employees[index] = EmployeeModel(
          id: id,
          name: _employees[index].name,
          phone: _employees[index].phone,
          role: newRole);
      notifyListeners();
    }
  }

  // --- Ledger ---
  Future<void> addLedgerEntry(LedgerModel entry) async {
    final newEntry = await _cloudService!.addLedgerEntry(entry);
    _ledger.add(newEntry);
    notifyListeners();
  }
}
