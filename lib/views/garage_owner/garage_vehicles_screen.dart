import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/garage_owner_provider.dart';
import '../../providers/theme_provider.dart';
import '../../models/garage_vehicle_model.dart';
import '../../core/constants/app_colors.dart';
import 'garage_job_details_screen.dart';

class GarageVehiclesScreen extends StatefulWidget {
  const GarageVehiclesScreen({super.key});

  @override
  State<GarageVehiclesScreen> createState() => _GarageVehiclesScreenState();
}

class _GarageVehiclesScreenState extends State<GarageVehiclesScreen> {
  void _showAddEditDialog(BuildContext context, {GarageVehicleModel? vehicle}) {
    final clientNameController =
        TextEditingController(text: vehicle?.clientName ?? '');
    final licensePlateController =
        TextEditingController(text: vehicle?.licensePlate ?? '');
    final makeModelController =
        TextEditingController(text: vehicle?.makeModel ?? '');
    final costController =
        TextEditingController(text: vehicle?.estimatedCost.toString() ?? '');
    String status = vehicle?.status ?? 'Pending';

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(vehicle == null ? 'Add Vehicle' : 'Edit Vehicle',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: clientNameController,
                      decoration: InputDecoration(
                        labelText: 'Client Name',
                        prefixIcon: Icon(Icons.person,
                            color: Theme.of(context).colorScheme.primary),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: makeModelController,
                      decoration: InputDecoration(
                        labelText: 'Make/Model (e.g., Honda Civic)',
                        prefixIcon: Icon(Icons.directions_car,
                            color: Theme.of(context).colorScheme.primary),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: licensePlateController,
                      decoration: InputDecoration(
                        labelText: 'License Plate',
                        prefixIcon: Icon(Icons.pin,
                            color: Theme.of(context).colorScheme.primary),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: costController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Est. Repair Cost',
                        prefixIcon: Icon(Icons.attach_money,
                            color: Theme.of(context).colorScheme.primary),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: status,
                      decoration: InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      items: ['Pending', 'Repairing', 'Ready', 'Delivered']
                          .map(
                              (c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (val) {
                        setState(() {
                          status = val!;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white),
                  onPressed: () {
                    if (clientNameController.text.trim().isEmpty ||
                        licensePlateController.text.trim().isEmpty ||
                        makeModelController.text.trim().isEmpty) return;

                    final cost = double.tryParse(costController.text) ?? 0.0;

                    final newVehicle = GarageVehicleModel(
                      id: vehicle?.id,
                      clientName: clientNameController.text.trim(),
                      licensePlate: licensePlateController.text.trim(),
                      makeModel: makeModelController.text.trim(),
                      status: status,
                      estimatedCost: cost,
                      createdAt: vehicle?.createdAt ??
                          DateTime.now().toIso8601String(),
                    );

                    final prov = Provider.of<GarageOwnerProvider>(context,
                        listen: false);
                    if (vehicle == null) {
                      prov.addVehicle(newVehicle);
                    } else {
                      prov.updateVehicle(newVehicle);
                    }
                    Navigator.pop(ctx);
                  },
                  child: Text(vehicle == null ? 'Add' : 'Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final garageProv = Provider.of<GarageOwnerProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.brown,
        title: const Text('Garage Vehicles'),
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditDialog(context),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Job', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.brown,
      ),
      body: garageProv.vehicles.isEmpty
          ? const Center(child: Text('No repair jobs found.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: garageProv.vehicles.length,
              itemBuilder: (context, index) {
                final vehicle = garageProv.vehicles[index];

                Color statusColor;
                switch (vehicle.status) {
                  case 'Pending':
                    statusColor = AppColors.orange;
                    break;
                  case 'Repairing':
                    statusColor = AppColors.blue;
                    break;
                  case 'Ready':
                    statusColor = AppColors.green;
                    break;
                  case 'Delivered':
                    statusColor = Colors.grey;
                    break;
                  default:
                    statusColor = Colors.grey;
                }

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => GarageJobDetailsScreen(
                                  vehicleId: vehicle.id!)));
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(vehicle.licensePlate,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18)),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color:
                                          statusColor.withValues(alpha: 0.5)),
                                ),
                                child: Text(vehicle.status,
                                    style: TextStyle(
                                        color: statusColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12)),
                              )
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('${vehicle.makeModel} • ${vehicle.clientName}',
                              style: const TextStyle(fontSize: 14)),
                          const SizedBox(height: 8),
                          Text(
                              'Est. Cost: ${Provider.of<ThemeProvider>(context).currencySymbol}${vehicle.estimatedCost.toStringAsFixed(2)}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600)),
                          const Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              DropdownButton<String>(
                                value: vehicle.status,
                                icon: const Icon(Icons.arrow_drop_down),
                                underline: const SizedBox(),
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.color,
                                    fontSize: 13),
                                onChanged: (String? newValue) {
                                  if (newValue != null &&
                                      newValue != vehicle.status) {
                                    garageProv.updateVehicleStatus(
                                        vehicle, newValue);
                                  }
                                },
                                items: [
                                  'Pending',
                                  'Repairing',
                                  'Ready',
                                  'Delivered'
                                ].map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text('Set: $value'),
                                  );
                                }).toList(),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: Colors.blue),
                                    onPressed: () => _showAddEditDialog(context,
                                        vehicle: vehicle),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () => _showDeleteConfirm(
                                        context, vehicle.id!, garageProv),
                                  ),
                                ],
                              )
                            ],
                          ),
                          // Remove the extra one here
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showDeleteConfirm(
      BuildContext context, String id, GarageOwnerProvider garageProv) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Vehicle?'),
        content: const Text('Are you sure you want to remove this repair job?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              garageProv.deleteVehicle(id);
              Navigator.pop(ctx);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
