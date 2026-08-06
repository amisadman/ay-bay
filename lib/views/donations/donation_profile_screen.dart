import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aybay_flutter/core/constants/app_colors.dart';
import 'package:aybay_flutter/providers/finance_provider.dart';
import 'package:aybay_flutter/providers/theme_provider.dart';
import 'package:aybay_flutter/core/utils/currency_formatter.dart';
import 'package:intl/intl.dart';

class DonationProfileScreen extends StatefulWidget {
  final int donationId;
  const DonationProfileScreen({super.key, required this.donationId});

  @override
  State<DonationProfileScreen> createState() => _DonationProfileScreenState();
}

class _DonationProfileScreenState extends State<DonationProfileScreen> {
  void _showAddExpenseDialog(BuildContext context, String orgName) {
    final _formKey = GlobalKey<FormState>();
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
                const Text('Log Donation Expense', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.brown)),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Amount Donated',
                    prefixIcon: const Icon(Icons.attach_money_rounded, color: AppColors.green),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (v) => v!.isEmpty ? 'Enter amount' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _noteController,
                  decoration: InputDecoration(
                    labelText: 'Note (Optional)',
                    prefixIcon: const Icon(Icons.note_alt_outlined, color: AppColors.brown),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      Provider.of<FinanceProvider>(context, listen: false).addDonationExpense(
                        widget.donationId,
                        double.parse(_amountController.text),
                        _noteController.text,
                      );
                      Navigator.pop(ctx);
                    }
                  },
                  child: const Text('Add Expense', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
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
    
    // Fallback if deleted
    final donationIndex = finProv.donations.indexWhere((d) => d.id == widget.donationId);
    if (donationIndex == -1) {
      return Scaffold(
        appBar: AppBar(title: const Text('Donation Not Found')),
        body: const Center(child: Text('This donation profile was deleted.')),
      );
    }
    
    final donation = finProv.donations[donationIndex];
    
    // Find associated transactions
    final titleMatch = 'Donation: ${donation.organizationName}';
    final relatedTxs = finProv.transactions.where((tx) => tx.title == titleMatch && tx.type == 'expense').toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.blue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(donation.organizationName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (c) => AlertDialog(
                  title: const Text('Delete Profile?'),
                  content: const Text('This will delete the donation profile, but existing expenses will remain in history.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
                    TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
                  ],
                ),
              );
              if (confirm == true) {
                finProv.deleteDonation(donation.id!);
                Navigator.pop(context);
              }
            },
          )
        ],
      ),
      body: Column(
        children: [
          // Header Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: AppColors.blue,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
            ),
            child: Column(
              children: [
                const Text('Total Donated', style: TextStyle(color: Colors.white70, fontSize: 16)),
                const SizedBox(height: 8),
                Text(
                  CurrencyFormatter.formatSimple(donation.totalDonated, sym),
                  style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                ),
                if (donation.amount > 0) ...[
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Target: ', style: TextStyle(color: Colors.white70)),
                      Text(CurrencyFormatter.formatSimple(donation.amount, sym), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ]
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Transactions List
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Donation History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.brown)),
                  const SizedBox(height: 12),
                  Expanded(
                    child: relatedTxs.isEmpty
                        ? const Center(child: Text('No donations made yet.', style: TextStyle(color: Colors.grey)))
                        : ListView.builder(
                            itemCount: relatedTxs.length,
                            itemBuilder: (context, index) {
                              final tx = relatedTxs[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: AppColors.blue.withValues(alpha: 0.1),
                                    child: const Icon(Icons.favorite_rounded, color: AppColors.blue),
                                  ),
                                  title: Text(tx.note?.isNotEmpty == true ? tx.note! : 'Donation', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: Text(DateFormat.yMMMd().format(DateTime.parse(tx.date))),
                                  trailing: Text(
                                    CurrencyFormatter.formatSimple(tx.amount, sym),
                                    style: const TextStyle(color: AppColors.blue, fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddExpenseDialog(context, donation.organizationName),
        backgroundColor: AppColors.blue,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Expense', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
