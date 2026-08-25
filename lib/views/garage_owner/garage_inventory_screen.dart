import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/garage_owner_provider.dart';
import '../../models/garage_part_model.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/theme_provider.dart';

class GarageInventoryScreen extends StatelessWidget {
  const GarageInventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<GarageOwnerProvider>(context);
    final currency = Provider.of<ThemeProvider>(context).currencySymbol;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.brown,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Parts & Inventory'),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showPartDialog(context, null),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Part', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.brown,
      ),
      body: prov.parts.isEmpty
          ? const Center(child: Text('No parts in inventory.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: prov.parts.length,
              itemBuilder: (context, index) {
                final part = prov.parts[index];
                final outOfStock = part.stock <= 0;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: outOfStock
                          ? Colors.red.withValues(alpha: 0.2)
                          : AppColors.brown.withValues(alpha: 0.2),
                      child: Icon(Icons.build,
                          color: outOfStock ? Colors.red : AppColors.brown),
                    ),
                    title: Text(part.name,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Stock: ${part.stock}',
                            style: TextStyle(
                                color: outOfStock ? Colors.red : null,
                                fontWeight:
                                    outOfStock ? FontWeight.bold : null)),
                        Text(
                            'Cost: $currency${part.unitCost} | Sell: $currency${part.sellPrice}'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showPartDialog(context, part),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => prov.deletePart(part.id!),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showPartDialog(BuildContext context, GaragePartModel? existing) {
    final nameCtrl = TextEditingController(text: existing?.name);
    final stockCtrl = TextEditingController(text: existing?.stock.toString());
    final costCtrl = TextEditingController(text: existing?.unitCost.toString());
    final sellCtrl =
        TextEditingController(text: existing?.sellPrice.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(existing == null ? 'Add Part' : 'Edit Part'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Part Name'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: stockCtrl,
                decoration: const InputDecoration(labelText: 'Stock Quantity'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: costCtrl,
                decoration: const InputDecoration(labelText: 'Unit Cost'),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: sellCtrl,
                decoration: const InputDecoration(labelText: 'Selling Price'),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
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
                backgroundColor: AppColors.brown,
                foregroundColor: Colors.white),
            onPressed: () {
              final name = nameCtrl.text.trim();
              final stock = int.tryParse(stockCtrl.text) ?? 0;
              final cost = double.tryParse(costCtrl.text) ?? 0.0;
              final sell = double.tryParse(sellCtrl.text) ?? 0.0;

              if (name.isEmpty) return;

              final prov =
                  Provider.of<GarageOwnerProvider>(context, listen: false);

              if (existing == null) {
                prov.addPart(GaragePartModel(
                    name: name, stock: stock, unitCost: cost, sellPrice: sell));
              } else {
                prov.updatePart(existing.copyWith(
                    name: name, stock: stock, unitCost: cost, sellPrice: sell));
              }

              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
