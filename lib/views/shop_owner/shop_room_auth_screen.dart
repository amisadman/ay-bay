import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../providers/shop_owner_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../services/super_module_db_helper.dart';

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

  Future<void> _createShop() async {
    if (_createNameController.text.trim().isEmpty) return;

    final roomCode = _uuid.v4().substring(0, 6).toUpperCase();
    final shopName = _createNameController.text.trim();

    final authProv = Provider.of<AuthProvider>(context, listen: false);
    final userName = authProv.userName;

    final prov = Provider.of<ShopOwnerProvider>(context, listen: false);
    await prov.initShop(roomCode, shopName, 'Admin', userName);
    await prov
        .addEmployee(EmployeeModel(name: userName, phone: '', role: 'Admin'));
        
    await SuperModuleDBHelper.instance.insertRoomHistory('Shop', roomCode, shopName);
    _loadHistory();
  }

  Future<void> _joinShop() async {
    if (_joinCodeController.text.trim().isEmpty) return;

    final roomCode = _joinCodeController.text.trim().toUpperCase();
    final authProv = Provider.of<AuthProvider>(context, listen: false);
    final userName = authProv.userName;

    final prov = Provider.of<ShopOwnerProvider>(context, listen: false);
    await prov.initShop(roomCode, 'Joined Shop', 'Pending', userName);

    final existing = prov.employees.any((e) => e.name == userName);
    if (!existing) {
      await prov.addEmployee(
          EmployeeModel(name: userName, phone: '', role: 'Pending'));
    }
    
    await SuperModuleDBHelper.instance.insertRoomHistory('Shop', roomCode, 'Joined Shop ($roomCode)');
    _loadHistory();
  }
  
  List<Map<String, dynamic>> _recentRooms = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final history = await SuperModuleDBHelper.instance.getRoomHistory('Shop');
    setState(() {
      _recentRooms = history;
    });
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
              const Text('Join an Existing Shop',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextField(
                controller: _joinCodeController,
                decoration: InputDecoration(
                  hintText: 'Enter 6-digit Room Code',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _joinShop,
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.orange,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50)),
                child: const Text('Join Room'),
              ),
              const SizedBox(height: 40),
              const Divider(),
              const SizedBox(height: 40),
              const Text('Create a New Shop',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextField(
                controller: _createNameController,
                decoration: InputDecoration(
                  hintText: 'Enter Shop Name',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _createShop,
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.vibrantGold,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50)),
                child: const Text('Create Room'),
              ),
              
              if (_recentRooms.isNotEmpty) ...[
                const SizedBox(height: 40),
                const Text('Recent Rooms', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 16),
                ..._recentRooms.map((room) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const Icon(Icons.history, color: AppColors.orange),
                    title: Text(room['roomName']),
                    subtitle: Text('Code: ${room['roomCode']}'),
                    onTap: () {
                      _joinCodeController.text = room['roomCode'];
                      _joinShop();
                    },
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () async {
                        await SuperModuleDBHelper.instance.deleteRoomHistory('Shop', room['roomCode']);
                        _loadHistory();
                      },
                    ),
                  ),
                )).toList(),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
