import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aybay_flutter/core/constants/app_colors.dart';
import 'package:aybay_flutter/providers/finance_provider.dart';
import 'package:aybay_flutter/providers/theme_provider.dart';
import 'package:aybay_flutter/core/utils/currency_formatter.dart';
import 'package:aybay_flutter/models/donation_model.dart';
import 'donation_profile_screen.dart';

class DonationScreen extends StatefulWidget {
  const DonationScreen({super.key});

  @override
  State<DonationScreen> createState() => _DonationScreenState();
}

class _DonationScreenState extends State<DonationScreen> {
  void _showAddDonationDialog(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final _orgController = TextEditingController();
    final _amountController = TextEditingController();
    final _noteController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('New Donation Profile',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.brown)),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _orgController,
                  decoration: InputDecoration(
                    labelText: 'Organization / Cause',
                    prefixIcon: const Icon(Icons.business_rounded,
                        color: AppColors.blue),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (v) =>
                      v!.isEmpty ? 'Enter organization name' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Target Amount (Optional)',
                    prefixIcon: const Icon(Icons.attach_money_rounded,
                        color: AppColors.green),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _noteController,
                  decoration: InputDecoration(
                    labelText: 'Note (Optional)',
                    prefixIcon: const Icon(Icons.note_alt_outlined,
                        color: AppColors.brown),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final newDonation = DonationModel(
                        organizationName: _orgController.text,
                        amount: double.tryParse(_amountController.text) ?? 0.0,
                        totalDonated: 0.0,
                        note: _noteController.text,
                        createdAt: DateTime.now().toIso8601String(),
                      );
                      Provider.of<FinanceProvider>(context, listen: false)
                          .addDonation(newDonation);
                      Navigator.pop(ctx);
                    }
                  },
                  child: const Text('Add Profile',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final finProv = Provider.of<FinanceProvider>(context);
    final sym = Provider.of<ThemeProvider>(context).currencySymbol;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.blue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Donations',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22)),
      ),
      body: finProv.donations.isEmpty
          ? const Center(
              child: Text('No donation profiles found. Create one!',
                  style: TextStyle(color: Colors.grey, fontSize: 16)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: finProv.donations.length,
              itemBuilder: (context, index) {
                final d = finProv.donations[index];
                final progress = d.amount > 0
                    ? (d.totalDonated / d.amount).clamp(0.0, 1.0)
                    : 0.0;

                return GestureDetector(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              DonationProfileScreen(donationId: d.id!))),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4))
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                d.organizationName,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.color ??
                                        AppColors.black),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.blue.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                CurrencyFormatter.formatSimple(
                                    d.totalDonated, sym),
                                style: const TextStyle(
                                    color: AppColors.blue,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                        if (d.amount > 0) ...[
                          const SizedBox(height: 12),
                          LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.grey.shade200,
                            color: AppColors.blue,
                            minHeight: 8,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Target: ${CurrencyFormatter.formatSimple(d.amount, sym)}',
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 12),
                          ),
                        ]
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.blue,
        child: const Icon(Icons.add, color: AppColors.white),
        onPressed: () => _showAddDonationDialog(context),
      ),
    );
  }
}
