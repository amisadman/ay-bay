import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:aybay_flutter/core/constants/app_colors.dart';
import 'package:aybay_flutter/providers/finance_provider.dart';
import 'package:aybay_flutter/providers/theme_provider.dart';
import 'package:aybay_flutter/core/utils/currency_formatter.dart';

class LoanProfileScreen extends StatefulWidget {
  final int loanId;
  const LoanProfileScreen({super.key, required this.loanId});

  @override
  State<LoanProfileScreen> createState() => _LoanProfileScreenState();
}

class _LoanProfileScreenState extends State<LoanProfileScreen> {
  
  void _makeCall(String phoneNumber) async {
    if (phoneNumber.isEmpty) return;
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  void _showAddInstallmentDialog(BuildContext context, FinanceProvider finProv) {
    final amountCtrl = TextEditingController();
    bool logToGlobal = true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateBuilder) => AlertDialog(
          title: const Text('Add Installment', style: TextStyle(color: AppColors.brown, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Installment Amount',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text('Log as Income/Expense', style: TextStyle(fontSize: 14)),
                value: logToGlobal,
                activeColor: AppColors.black,
                contentPadding: EdgeInsets.zero,
                onChanged: (val) {
                  setStateBuilder(() => logToGlobal = val);
                },
              ),
            ],
          ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.black, foregroundColor: Colors.white),
            onPressed: () {
              final amount = double.tryParse(amountCtrl.text.trim()) ?? 0.0;
              if (amount > 0) {
                final date = DateTime.now().toIso8601String().split('T')[0];
                finProv.addLoanInstallment(widget.loanId, amount, date, logToTransactions: logToGlobal);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final finProv = Provider.of<FinanceProvider>(context);
    final themeProv = Provider.of<ThemeProvider>(context);
    final sym = themeProv.currencySymbol;

    // Find the loan
    final idx = finProv.loans.indexWhere((l) => l.id == widget.loanId);
    if (idx == -1) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile Not Found')),
        body: const Center(child: Text('This profile no longer exists.')),
      );
    }
    final loan = finProv.loans[idx];
    final isCompleted = loan.status == 'settled' || loan.amountPaid >= loan.amount;
    
    List<dynamic> installments = [];
    try {
      installments = jsonDecode(loan.installments);
    } catch (e) {}

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: loan.type == 'loan' ? const Color(0xFFD84315) : AppColors.purple,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Profile Details', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)),
        actions: [
          if (loan.phoneNumber.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.phone, color: Colors.white),
              onPressed: () => _makeCall(loan.phoneNumber),
            ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Header
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: loan.type == 'loan' ? const Color(0xFFD84315) : AppColors.purple,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircleAvatar(
                      radius: 26,
                      backgroundColor: Colors.white24,
                      child: Icon(Icons.person, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(loan.personName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                        if (loan.phoneNumber.isNotEmpty)
                          Text(loan.phoneNumber, style: const TextStyle(fontSize: 14, color: Colors.white70)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Total Amount', style: TextStyle(color: Colors.white70)),
                        Text(CurrencyFormatter.formatSimple(loan.amount, sym), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Total Paid', style: TextStyle(color: Colors.white70)),
                        Text(CurrencyFormatter.formatSimple(loan.amountPaid, sym), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Remaining', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(
                      CurrencyFormatter.formatSimple(loan.amount - loan.amountPaid, sym), 
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)
                    ),
                  ],
                ),
                if (isCompleted) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(16)),
                    child: const Text('COMPLETED', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                  ),
                ]
              ],
            ),
          ),
          
          if (!isCompleted)
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 0),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.black, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
                      icon: const Icon(Icons.add_card),
                      label: const Text('Add Installment'),
                      onPressed: () => _showAddInstallmentDialog(context, finProv),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.green, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
                      icon: const Icon(Icons.check_circle),
                      label: const Text('Complete'),
                      onPressed: () {
                        finProv.completeLoan(loan.id!);
                      },
                    ),
                  ),
                ],
              ),
            ),
            
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Installment History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.brown)),
          ),
          
          Expanded(
            child: installments.isEmpty
                ? const Center(child: Text('No installments added yet.', style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    itemCount: installments.length,
                    itemBuilder: (context, index) {
                      // Reverse order to show newest first
                      final inst = installments[installments.length - 1 - index];
                      final amount = (inst['amount'] as num).toDouble();
                      final date = inst['date'] as String;
                      return ListTile(
                        leading: const CircleAvatar(backgroundColor: AppColors.green, child: Icon(Icons.check, color: Colors.white)),
                        title: Text('Installment Paid', style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(date),
                        trailing: Text('+ ${CurrencyFormatter.formatSimple(amount, sym)}', style: const TextStyle(color: AppColors.green, fontWeight: FontWeight.bold, fontSize: 16)),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
