import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/shop_owner_provider.dart';
import '../../models/shop_owner_model.dart';
import '../../core/constants/app_colors.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  void _showProductDialog(BuildContext context, [ProductModel? product]) {
    showDialog(
      context: context,
      builder: (ctx) => ProductDialog(product: product),
    );
  }

  @override
  Widget build(BuildContext context) {
    final shopProv = Provider.of<ShopOwnerProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Inventory'), backgroundColor: AppColors.orange, foregroundColor: Colors.white),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showProductDialog(context),
        backgroundColor: AppColors.orange,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Product', style: TextStyle(color: Colors.white)),
      ),
      body: shopProv.isLoading
          ? const Center(child: CircularProgressIndicator())
          : shopProv.products.isEmpty
              ? const Center(child: Text('No products in inventory'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: shopProv.products.length,
                  itemBuilder: (context, index) {
                    final prod = shopProv.products[index];
                    final bool isLowStock = prod.stock <= 5;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: isLowStock ? const BorderSide(color: Colors.red, width: 1.5) : BorderSide.none),
                      child: ListTile(
                        onTap: () => _showProductDialog(context, prod),
                        leading: prod.imagePath != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(prod.imagePath!), // using dart:io below
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                    color: Colors.grey.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(8)),
                                child: const Icon(Icons.image, color: Colors.grey),
                              ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(prod.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            if (isLowStock)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(4)),
                                child: const Text('Low Stock', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                              ),
                          ],
                        ),
                        subtitle: Text('Stock: ${prod.stock}', style: TextStyle(color: isLowStock ? Colors.red : null, fontWeight: isLowStock ? FontWeight.bold : null)),
                        trailing: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('৳${prod.price.toStringAsFixed(2)}',
                                  style: TextStyle(
                                      color: Theme.of(context).colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                              Text('Cost: ৳${prod.cost.toStringAsFixed(2)}',
                                  style: const TextStyle(color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

class ProductDialog extends StatefulWidget {
  final ProductModel? product;
  const ProductDialog({super.key, this.product});

  @override
  State<ProductDialog> createState() => _ProductDialogState();
}

class _ProductDialogState extends State<ProductDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _costController;
  late TextEditingController _stockController;
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _priceController = TextEditingController(text: widget.product?.price.toStringAsFixed(2) ?? '');
    _costController = TextEditingController(text: widget.product?.cost.toStringAsFixed(2) ?? '');
    _stockController = TextEditingController(text: widget.product?.stock.toString() ?? '');
    _imagePath = widget.product?.imagePath;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _costController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imagePath = image.path;
      });
    }
  }

  void _saveProduct() {
    if (_formKey.currentState!.validate()) {
      final isEditing = widget.product != null;
      final prod = ProductModel(
        id: widget.product?.id,
        name: _nameController.text.trim(),
        price: double.parse(_priceController.text),
        cost: double.parse(_costController.text),
        stock: int.parse(_stockController.text),
        imagePath: _imagePath,
        createdAt: widget.product?.createdAt ?? DateTime.now().toIso8601String(),
      );

      final shopProv = Provider.of<ShopOwnerProvider>(context, listen: false);
      if (isEditing) {
        shopProv.updateProduct(prod);
      } else {
        shopProv.addProduct(prod);
      }
      Navigator.pop(context);
    }
  }

  void _deleteProduct() {
    if (widget.product != null) {
      Provider.of<ShopOwnerProvider>(context, listen: false).deleteProduct(widget.product!.id!);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.product != null;

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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(isEditing ? 'Edit Product' : 'New Product',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.orange)),
                    if (isEditing)
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: _deleteProduct,
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.orange.withValues(alpha: 0.5)),
                    ),
                    child: _imagePath != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(File(_imagePath!), fit: BoxFit.cover),
                          )
                        : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo, color: AppColors.orange),
                              SizedBox(height: 4),
                              Text('Add Photo', style: TextStyle(fontSize: 10, color: AppColors.orange)),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Product Name'),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(labelText: 'Selling Price'),
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _costController,
                  decoration: const InputDecoration(labelText: 'Cost Price'),
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _stockController,
                  decoration: const InputDecoration(labelText: 'Stock'),
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.orange, foregroundColor: Colors.white),
                      onPressed: _saveProduct,
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
