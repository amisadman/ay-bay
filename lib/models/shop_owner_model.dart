import 'dart:convert';

class ProductModel {
  final String? id;
  final String name;
  final double price;
  final double cost;
  final int stock;
  final String? imagePath;
  final String createdAt;

  ProductModel({
    this.id,
    required this.name,
    required this.price,
    required this.cost,
    required this.stock,
    this.imagePath,
    required this.createdAt,
  });

  ProductModel copyWith({
    String? id,
    String? name,
    double? price,
    double? cost,
    int? stock,
    String? imagePath,
    String? createdAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      cost: cost ?? this.cost,
      stock: stock ?? this.stock,
      imagePath: imagePath ?? this.imagePath,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'cost': cost,
      'stock': stock,
      'imagePath': imagePath,
      'createdAt': createdAt,
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> map, String docId) {
    return ProductModel(
      id: docId,
      name: map['name'],
      price: map['price'].toDouble(),
      cost: map['cost'].toDouble(),
      stock: map['stock'],
      imagePath: map['imagePath'],
      createdAt: map['createdAt'],
    );
  }
}

class SaleItem {
  final String productId;
  final String productName;
  final int quantity;
  final double price;
  final double cost;

  SaleItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
    required this.cost,
  });

  Map<String, dynamic> toMap() => {
        'productId': productId,
        'productName': productName,
        'quantity': quantity,
        'price': price,
        'cost': cost,
      };

  factory SaleItem.fromMap(Map<String, dynamic> map) => SaleItem(
        productId: map['productId'],
        productName: map['productName'],
        quantity: map['quantity'],
        price: map['price'].toDouble(),
        cost: map['cost'].toDouble(),
      );
}

class SaleModel {
  final String? id;
  final String date;
  final List<SaleItem> items;
  final double totalAmount;
  final double totalProfit;
  final double discount;
  final String? customerId;
  final String? employeeId;

  SaleModel({
    this.id,
    required this.date,
    required this.items,
    required this.totalAmount,
    required this.totalProfit,
    this.discount = 0.0,
    this.customerId,
    this.employeeId,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'items': items.map((e) => e.toMap()).toList(),
      'totalAmount': totalAmount,
      'totalProfit': totalProfit,
      'discount': discount,
      'customerId': customerId,
      'employeeId': employeeId,
    };
  }

  factory SaleModel.fromMap(Map<String, dynamic> map, String docId) {
    final List<dynamic> jsonItems = map['items'] ?? [];
    return SaleModel(
      id: docId,
      date: map['date'],
      items: jsonItems.map((e) => SaleItem.fromMap(e)).toList(),
      totalAmount: map['totalAmount'].toDouble(),
      totalProfit: map['totalProfit'].toDouble(),
      discount: (map['discount'] ?? 0).toDouble(),
      customerId: map['customerId'],
      employeeId: map['employeeId'],
    );
  }
}

class CustomerModel {
  final String? id;
  final String name;
  final String phone;
  final double debt;

  CustomerModel({
    this.id,
    required this.name,
    required this.phone,
    this.debt = 0.0,
  });

  CustomerModel copyWith(
      {String? id, String? name, String? phone, double? debt}) {
    return CustomerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      debt: debt ?? this.debt,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'phone': phone,
        'debt': debt,
      };

  factory CustomerModel.fromMap(Map<String, dynamic> map, String docId) {
    return CustomerModel(
      id: docId,
      name: map['name'],
      phone: map['phone'],
      debt: (map['debt'] ?? 0).toDouble(),
    );
  }
}

class EmployeeModel {
  final String? id;
  final String name;
  final String phone;
  final String role; // e.g. "Admin", "Staff"

  EmployeeModel({
    this.id,
    required this.name,
    required this.phone,
    required this.role,
  });

  Map<String, dynamic> toMap() => {
        'name': name,
        'phone': phone,
        'role': role,
      };

  factory EmployeeModel.fromMap(Map<String, dynamic> map, String docId) {
    return EmployeeModel(
      id: docId,
      name: map['name'],
      phone: map['phone'],
      role: map['role'],
    );
  }
}

class LedgerModel {
  final String? id;
  final String title;
  final double amount;
  final String type; // "Income" or "Expense"
  final String date;

  LedgerModel({
    this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.date,
  });

  Map<String, dynamic> toMap() => {
        'title': title,
        'amount': amount,
        'type': type,
        'date': date,
      };

  factory LedgerModel.fromMap(Map<String, dynamic> map, String docId) {
    return LedgerModel(
      id: docId,
      title: map['title'],
      amount: map['amount'].toDouble(),
      type: map['type'],
      date: map['date'],
    );
  }
}
