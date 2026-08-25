import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/garage_owner_provider.dart';
import '../../models/garage_vehicle_model.dart';
import '../../models/garage_part_model.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/theme_provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/utils/garage_invoice_pdf.dart';

class GarageJobDetailsScreen extends StatefulWidget {
  final String vehicleId;

  const GarageJobDetailsScreen({super.key, required this.vehicleId});

  @override
  State<GarageJobDetailsScreen> createState() => _GarageJobDetailsScreenState();
}

class _GarageJobDetailsScreenState extends State<GarageJobDetailsScreen> {
  void _addPartToJob(GarageVehicleModel vehicle, GaragePartModel part,
      GarageOwnerProvider prov) {
    if (part.stock <= 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Part out of stock!')));
      return;
    }

    final updatedParts = List<Map<String, dynamic>>.from(vehicle.usedParts);
    final existingIdx = updatedParts.indexWhere((p) => p['id'] == part.id);

    if (existingIdx != -1) {
      updatedParts[existingIdx]['qty'] =
          (updatedParts[existingIdx]['qty'] as int) + 1;
    } else {
      updatedParts.add({
        'id': part.id,
        'name': part.name,
        'cost': part.sellPrice,
        'qty': 1,
      });
    }

    // Deduct stock
    prov.updatePart(part.copyWith(stock: part.stock - 1));

    // Update job
    final newCost = vehicle.estimatedCost + part.sellPrice;
    prov.updateVehicle(vehicle.copyWith(
      usedParts: updatedParts,
      estimatedCost: newCost,
    ));
  }

  void _updateLaborCost(GarageVehicleModel vehicle, GarageOwnerProvider prov) {
    final ctrl = TextEditingController(text: vehicle.laborCost.toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Set Labor Cost'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Labor Cost'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final newLabor = double.tryParse(ctrl.text) ?? 0.0;
              final diff = newLabor - vehicle.laborCost;
              prov.updateVehicle(vehicle.copyWith(
                laborCost: newLabor,
                estimatedCost: vehicle.estimatedCost + diff,
              ));
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _claimJob(GarageVehicleModel vehicle, GarageOwnerProvider prov) {
    final me = Provider.of<AuthProvider>(context, listen: false).userName;
    prov.updateVehicle(vehicle.copyWith(mechanicName: me));
  }

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<GarageOwnerProvider>(context);
    final vehicle = prov.vehicles.firstWhere((v) => v.id == widget.vehicleId,
        orElse: () => GarageVehicleModel(
            clientName: '',
            licensePlate: '',
            makeModel: '',
            status: '',
            estimatedCost: 0,
            createdAt: ''));

    if (vehicle.id == null)
      return const Scaffold(body: Center(child: Text('Vehicle not found')));

    final currency = Provider.of<ThemeProvider>(context).currencySymbol;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.brown,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text('${vehicle.makeModel} Job'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status & Basic Info
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(vehicle.licensePlate,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        DropdownButton<String>(
                          value: vehicle.status,
                          items: ['Pending', 'Repairing', 'Ready', 'Delivered']
                              .map((s) =>
                                  DropdownMenuItem(value: s, child: Text(s)))
                              .toList(),
                          onChanged: (val) {
                            if (val != null)
                              prov.updateVehicleStatus(vehicle, val);
                          },
                        ),
                      ],
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(vehicle.clientName),
                      subtitle: const Text('Client'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.build),
                      title: Text(vehicle.mechanicName ?? 'Unassigned'),
                      subtitle: const Text('Mechanic'),
                      trailing: vehicle.mechanicName == null
                          ? TextButton(
                              onPressed: () => _claimJob(vehicle, prov),
                              child: const Text('Claim Job'))
                          : null,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Financials (Labor + Parts)
            const Text('Job Costs',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    ListTile(
                      title: const Text('Labor Cost'),
                      trailing: Text(
                          '$currency${vehicle.laborCost.toStringAsFixed(2)}'),
                      onTap: () => _updateLaborCost(vehicle, prov),
                    ),
                    const Divider(),
                    const Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Text('Used Parts',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        )),
                    if (vehicle.usedParts.isEmpty)
                      const Text('No parts attached yet.',
                          style: TextStyle(color: Colors.grey)),
                    ...vehicle.usedParts.map((p) => ListTile(
                          dense: true,
                          title: Text(p['name']),
                          subtitle: Text('Qty: ${p['qty']}'),
                          trailing: Text(
                              '$currency${(p['cost'] * p['qty']).toStringAsFixed(2)}'),
                        )),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Show bottom sheet to pick parts
                        showModalBottomSheet(
                          context: context,
                          builder: (ctx) => ListView.builder(
                            itemCount: prov.parts.length,
                            itemBuilder: (c, i) {
                              final part = prov.parts[i];
                              return ListTile(
                                title: Text(part.name),
                                subtitle: Text(
                                    'Stock: ${part.stock} | Cost: $currency${part.sellPrice}'),
                                trailing: const Icon(Icons.add_circle,
                                    color: AppColors.brown),
                                onTap: () {
                                  _addPartToJob(vehicle, part, prov);
                                  Navigator.pop(ctx);
                                },
                              );
                            },
                          ),
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Attach Part'),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade200,
                          foregroundColor: Colors.black),
                    ),
                    const Divider(),
                    ListTile(
                      title: const Text('Total Estimated Cost',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      trailing: Text(
                          '$currency${vehicle.estimatedCost.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: AppColors.brown)),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.brown,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12)),
                        icon: const Icon(Icons.picture_as_pdf),
                        label: const Text('Generate Invoice PDF'),
                        onPressed: () {
                          GarageInvoicePdf.generateAndShareInvoice(
                              vehicle, prov.garageName ?? 'Garage', currency);
                        },
                      ),
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
