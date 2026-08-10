import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/shop_owner_model.dart';

class ShopCloudService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String shopId;

  ShopCloudService(this.shopId);

  // --- Products ---
  Future<ProductModel> addProduct(ProductModel prod) async {
    final docRef = await _db.collection('shops').doc(shopId).collection('products').add(prod.toMap());
    return prod.copyWith(id: docRef.id);
  }

  Future<void> updateProduct(ProductModel prod) async {
    if (prod.id == null) return;
    await _db.collection('shops').doc(shopId).collection('products').doc(prod.id).update(prod.toMap());
  }

  Future<void> deleteProduct(String id) async {
    await _db.collection('shops').doc(shopId).collection('products').doc(id).delete();
  }

  Future<List<ProductModel>> getProducts() async {
    final snap = await _db.collection('shops').doc(shopId).collection('products').get();
    return snap.docs.map((doc) => ProductModel.fromMap(doc.data(), doc.id)).toList();
  }

  // --- Sales ---
  Future<SaleModel> recordSale(SaleModel sale) async {
    final docRef = await _db.collection('shops').doc(shopId).collection('sales').add(sale.toMap());
    
    // Update customer debt if applicable
    if (sale.customerId != null && sale.customerId!.isNotEmpty) {
      // The totalAmount of the sale adds to their debt if it's on credit
      final customerRef = _db.collection('shops').doc(shopId).collection('customers').doc(sale.customerId);
      await customerRef.update({
        'debt': FieldValue.increment(sale.totalAmount),
      });
    }

    return SaleModel(
      id: docRef.id,
      date: sale.date,
      items: sale.items,
      totalAmount: sale.totalAmount,
      totalProfit: sale.totalProfit,
      discount: sale.discount,
      customerId: sale.customerId,
      employeeId: sale.employeeId,
    );
  }

  Future<List<SaleModel>> getSales() async {
    final snap = await _db.collection('shops').doc(shopId).collection('sales').get();
    return snap.docs.map((doc) => SaleModel.fromMap(doc.data(), doc.id)).toList();
  }

  // --- Customers ---
  Future<CustomerModel> addCustomer(CustomerModel customer) async {
    final docRef = await _db.collection('shops').doc(shopId).collection('customers').add(customer.toMap());
    return customer.copyWith(id: docRef.id);
  }

  Future<void> updateCustomer(CustomerModel customer) async {
    if (customer.id == null) return;
    await _db.collection('shops').doc(shopId).collection('customers').doc(customer.id).update(customer.toMap());
  }

  Future<List<CustomerModel>> getCustomers() async {
    final snap = await _db.collection('shops').doc(shopId).collection('customers').get();
    return snap.docs.map((doc) => CustomerModel.fromMap(doc.data(), doc.id)).toList();
  }

  // --- Employees ---
  Future<EmployeeModel> addEmployee(EmployeeModel employee) async {
    final docRef = await _db.collection('shops').doc(shopId).collection('employees').add(employee.toMap());
    return EmployeeModel(id: docRef.id, name: employee.name, phone: employee.phone, role: employee.role);
  }

  Future<void> removeEmployee(String id) async {
    await _db.collection('shops').doc(shopId).collection('employees').doc(id).delete();
  }

  Future<void> updateEmployeeRole(String id, String newRole) async {
    await _db.collection('shops').doc(shopId).collection('employees').doc(id).update({'role': newRole});
  }

  Future<List<EmployeeModel>> getEmployees() async {
    final snap = await _db.collection('shops').doc(shopId).collection('employees').get();
    return snap.docs.map((doc) => EmployeeModel.fromMap(doc.data(), doc.id)).toList();
  }

  // --- Ledger ---
  Future<LedgerModel> addLedgerEntry(LedgerModel ledger) async {
    final docRef = await _db.collection('shops').doc(shopId).collection('ledger').add(ledger.toMap());
    return LedgerModel(
      id: docRef.id,
      title: ledger.title,
      amount: ledger.amount,
      type: ledger.type,
      date: ledger.date,
    );
  }

  Future<List<LedgerModel>> getLedger() async {
    final snap = await _db.collection('shops').doc(shopId).collection('ledger').get();
    return snap.docs.map((doc) => LedgerModel.fromMap(doc.data(), doc.id)).toList();
  }
}
