import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../providers/shop_owner_provider.dart';
import '../../core/constants/app_colors.dart';

import '../../providers/auth_provider.dart';
import '../../models/shop_owner_model.dart';

class ShopRoomAuthScreen extends StatefulWidget {
  const ShopRoomAuthScreen({super.key});

  @override
  State<ShopRoomAuthScreen> createState() => _ShopRoomAuthScreenState();
}

class _ShopRoomAuthScreenState extends State<ShopRoomAuthScreen> {
  final _joinCodeController = TextEditingController();
  final _createNameController = TextEditingController();
  final _uuid = const Uuid();

  void _createShop() async {
    if (_createNameController.text.trim().isEmpty) return;
    
    final roomCode = _uuid.v4().substring(0, 6).toUpperCase();
    final shopName = _createNameController.text.trim();
    
    final authProv = Provider.of<AuthProvider>(context, listen: false);
    final userName = authProv.userName;

    final prov = Provider.of<ShopOwnerProvider>(context, listen: false);
    await prov.initShop(roomCode, shopName, 'Admin', userName);
    await prov.addEmployee(EmployeeModel(name: userName, phone: '', role: 'Admin'));
  }

  void _joinShop() async {
    if (_joinCodeController.text.trim().isEmpty) return;
    
    final roomCode = _joinCodeController.text.trim().toUpperCase();
    final authProv = Provider.of<AuthProvider>(context, listen: false);
    final userName = authProv.userName;

    final prov = Provider.of<ShopOwnerProvider>(context, listen: false);
    await prov.initShop(roomCode, 'Joined Shop', 'Pending', userName);
    
    final existing = prov.employees.any((e) => e.name == userName);
    if (!existing) {
      await prov.addEmployee(EmployeeModel(name: userName, phone: '', role: 'Pending'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Shop Setup'),
        backgroundColor: AppColors.orange,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Join an Existing Shop', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextField(
                controller: _joinCodeController,
                decoration: InputDecoration(
                  hintText: 'Enter 6-digit Room Code',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _joinShop,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.orange, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 50)),
                child: const Text('Join Room'),
              ),
              const SizedBox(height: 40),
              const Divider(),
              const SizedBox(height: 40),
              const Text('Create a New Shop', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextField(
                controller: _createNameController,
                decoration: InputDecoration(
                  hintText: 'Enter Shop Name',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _createShop,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.vibrantGold, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 50)),
                child: const Text('Create Room'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
