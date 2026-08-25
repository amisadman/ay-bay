import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../providers/garage_owner_provider.dart';
import '../../core/constants/app_colors.dart';

import '../../providers/auth_provider.dart';
import '../../models/garage_employee_model.dart';

class GarageRoomAuthScreen extends StatefulWidget {
  const GarageRoomAuthScreen({super.key});

  @override
  State<GarageRoomAuthScreen> createState() => _GarageRoomAuthScreenState();
}

class _GarageRoomAuthScreenState extends State<GarageRoomAuthScreen> {
  final _joinCodeController = TextEditingController();
  final _createNameController = TextEditingController();
  final _uuid = const Uuid();

  void _createGarage() async {
    if (_createNameController.text.trim().isEmpty) return;

    final roomCode = _uuid.v4().substring(0, 6).toUpperCase();
    final garageName = _createNameController.text.trim();

    final authProv = Provider.of<AuthProvider>(context, listen: false);
    final userName = authProv.userName;

    final prov = Provider.of<GarageOwnerProvider>(context, listen: false);
    await prov.initGarage(roomCode, garageName, 'Admin', userName);
    await prov.addEmployee(
        GarageEmployeeModel(name: userName, phone: '', role: 'Admin'));
  }

  void _joinGarage() async {
    if (_joinCodeController.text.trim().isEmpty) return;

    final roomCode = _joinCodeController.text.trim().toUpperCase();
    final authProv = Provider.of<AuthProvider>(context, listen: false);
    final userName = authProv.userName;

    final prov = Provider.of<GarageOwnerProvider>(context, listen: false);
    await prov.initGarage(roomCode, 'Joined Garage', 'Pending', userName);

    final existing = prov.employees.any((e) => e.name == userName);
    if (!existing) {
      await prov.addEmployee(
          GarageEmployeeModel(name: userName, phone: '', role: 'Pending'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.brown,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Garage Setup'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.car_repair, size: 80, color: AppColors.brown),
            const SizedBox(height: 24),
            const Text(
              'Join or Create a Garage Room to collaborate with mechanics in real-time.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 48),

            // Create Section
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text('Create a New Garage',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _createNameController,
                      decoration: const InputDecoration(
                          labelText: 'Garage Name',
                          border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.brown,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 50)),
                      onPressed: _createGarage,
                      child: const Text('Create & Become Admin'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
            const Center(
                child: Text('OR',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.grey))),
            const SizedBox(height: 24),

            // Join Section
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text('Join Existing Garage',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _joinCodeController,
                      decoration: const InputDecoration(
                          labelText: '6-Digit Room Code',
                          border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade800,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 50)),
                      onPressed: _joinGarage,
                      child: const Text('Join Room'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
