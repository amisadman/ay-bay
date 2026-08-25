import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/home_owner_provider.dart';
import '../../models/apartment_model.dart';
import '../../core/constants/app_colors.dart';

class EditApartmentDialog extends StatefulWidget {
  final ApartmentModel apartment;

  const EditApartmentDialog({super.key, required this.apartment});

  @override
  State<EditApartmentDialog> createState() => _EditApartmentDialogState();
}

class _EditApartmentDialogState extends State<EditApartmentDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _boarderNameController;
  late TextEditingController _boarderPhoneController;
  late TextEditingController _rentController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.apartment.name);
    _boarderNameController =
        TextEditingController(text: widget.apartment.boarderName);
    _boarderPhoneController =
        TextEditingController(text: widget.apartment.boarderPhone);
    _rentController = TextEditingController(
        text: widget.apartment.rentAmount.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _boarderNameController.dispose();
    _boarderPhoneController.dispose();
    _rentController.dispose();
    super.dispose();
  }

  void _saveApartment() {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();
      final boarderName = _boarderNameController.text.trim();
      final boarderPhone = _boarderPhoneController.text.trim();
      final rent = double.tryParse(_rentController.text) ?? 0;

      final updatedAppt = widget.apartment.copyWith(
        name: name,
        boarderName: boarderName,
        boarderPhone: boarderPhone,
        rentAmount: rent,
      );

      Provider.of<HomeOwnerProvider>(context, listen: false)
          .updateApartment(updatedAppt);
      Navigator.pop(context, updatedAppt);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Edit Apartment',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.deepTeal),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Apartment Name (e.g. Apt 2B)',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (v) => v!.isEmpty ? 'Enter apartment name' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _boarderNameController,
                  decoration: InputDecoration(
                    labelText: 'Boarder Name',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (v) => v!.isEmpty ? 'Enter boarder name' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _boarderPhoneController,
                  decoration: InputDecoration(
                    labelText: 'Boarder Phone Number',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (v) => v!.isEmpty ? 'Enter phone number' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _rentController,
                  decoration: InputDecoration(
                    labelText: 'Monthly Rent Amount',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Enter rent amount';
                    if (double.tryParse(v) == null) return 'Enter valid number';
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel',
                          style: TextStyle(color: Colors.grey)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.deepTeal,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _saveApartment,
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
