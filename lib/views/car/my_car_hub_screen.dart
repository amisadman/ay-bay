import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/finance_provider.dart';
import '../../models/car_model.dart';
import '../../core/constants/app_colors.dart';
import 'car_profile_screen.dart';

class MyCarHubScreen extends StatelessWidget {
  const MyCarHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final finProv = Provider.of<FinanceProvider>(context);
    final cars = finProv.cars;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.blue,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('My Car',style: TextStyle(color: Colors.white)),
        elevation: 0,
      ),
      body: cars.isEmpty
          ? const Center(
              child: Text(
                'No cars added yet.\nTap + to add a car.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: cars.length,
              itemBuilder: (context, index) {
                final car = cars[index];
                return Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.blue,
                      child: Icon(Icons.time_to_leave, color: Colors.white),
                    ),
                    title: Text(car.carName,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('License: ${car.licensePlate}'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CarProfileScreen(car: car),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.blue,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => _showAddCarDialog(context, finProv),
      ),
    );
  }

  void _showAddCarDialog(BuildContext context, FinanceProvider finProv) {
    final nameCtrl = TextEditingController();
    final plateCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add New Car'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(
                labelText: 'Car Name (e.g. My Toyota)',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: plateCtrl,
              decoration: InputDecoration(
                labelText: 'License Plate',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blue, foregroundColor: Colors.white),
            onPressed: () async {
              if (nameCtrl.text.isEmpty || plateCtrl.text.isEmpty) return;
              final newCar = CarModel(
                carName: nameCtrl.text.trim(),
                licensePlate: plateCtrl.text.trim(),
                expenses: '[]',
                createdAt: DateTime.now().toIso8601String(),
              );
              await finProv.addCar(newCar);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Add Car'),
          ),
        ],
      ),
    );
  }
}
