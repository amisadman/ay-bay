import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aybay_flutter/core/constants/app_colors.dart';
import 'package:aybay_flutter/models/loan_model.dart';
import 'package:aybay_flutter/providers/finance_provider.dart';
import 'package:aybay_flutter/providers/theme_provider.dart';
import 'package:aybay_flutter/core/utils/currency_formatter.dart';
import 'package:aybay_flutter/views/loans/loan_profile_screen.dart';

class LoanScreen extends StatefulWidget {
  final String initialType;
  const LoanScreen({super.key, this.initialType = 'loan'});

  @override
  State<LoanScreen> createState() => _LoanScreenState();
}

class _LoanScreenState extends State<LoanScreen> {
  void _showAddLoanDialog() {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    String dialogType = widget.initialType;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateBuilder) => AlertDialog(
          title: const Text('Add Profile', style: TextStyle(color: AppColors.brown, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(labelText: 'Person Name', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(labelText: 'Phone Number', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: amountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Total Amount', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.black, foregroundColor: Colors.white),
              onPressed: () {
                final name = nameCtrl.text.trim();
                final phone = phoneCtrl.text.trim();
                final amount = double.tryParse(amountCtrl.text.trim()) ?? 0.0;
                if (name.isNotEmpty && amount > 0) {
                  final newLoan = LoanModel(
                    personName: name,
                    phoneNumber: phone,
                    amount: amount,
                    amountPaid: 0.0,
                    type: dialogType,
                    dueDate: DateTime.now().toIso8601String().split('T')[0],
                    status: 'pending',
                    installments: '[]',
                    createdAt: DateTime.now().toIso8601String(),
                  );
                  Provider.of<FinanceProvider>(context, listen: false).addLoan(newLoan);
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Create Profile'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final finProv = Provider.of<FinanceProvider>(context);
    final themeProv = Provider.of<ThemeProvider>(context);
    final sym = themeProv.currencySymbol;

    final filteredLoans = finProv.loans.where((l) => l.type == widget.initialType).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: widget.initialType == 'loan' ? const Color(0xFFD84315) : AppColors.purple,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.initialType == 'loan' ? 'Loans Given' : 'Owes Borrowed',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.black,
        onPressed: _showAddLoanDialog,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          // Total Summary
          Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.white1,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Remaining', style: TextStyle(fontSize: 16, color: Colors.grey.shade700)),
                    const SizedBox(height: 4),
                    Text(
                      CurrencyFormatter.formatSimple(widget.initialType == 'loan' ? finProv.totalLoanGiven : finProv.totalOweBorrowed, sym),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: widget.initialType == 'loan' ? const Color(0xFFD84315) : AppColors.purple,
                      ),
                    ),
                  ],
                ),
                Icon(
                  widget.initialType == 'loan' ? Icons.handshake_rounded : Icons.credit_score_rounded,
                  color: widget.initialType == 'loan' ? const Color(0xFFD84315) : AppColors.purple,
                  size: 40,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // List
          Expanded(
            child: filteredLoans.isEmpty
                ? const Center(child: Text('No profiles found.', style: TextStyle(color: Colors.grey, fontSize: 16)))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredLoans.length,
                    itemBuilder: (context, index) {
                      final loan = filteredLoans[index];
                      final progress = loan.amount > 0 ? (loan.amountPaid / loan.amount).clamp(0.0, 1.0) : 0.0;
                      final isCompleted = loan.status == 'settled' || progress >= 1.0;

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => LoanProfileScreen(loanId: loan.id!)),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isCompleted ? AppColors.white.withOpacity(0.5) : AppColors.white1,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: isCompleted ? AppColors.green.withOpacity(0.5) : Colors.grey.shade300),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: widget.initialType == 'loan' ? const Color(0xFFD84315).withOpacity(0.1) : AppColors.purple.withOpacity(0.1),
                                    child: Icon(Icons.person, color: widget.initialType == 'loan' ? const Color(0xFFD84315) : AppColors.purple),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(loan.personName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.black)),
                                        Text(loan.dueDate, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                      ],
                                    ),
                                  ),
                                  if (isCompleted)
                                    const Icon(Icons.check_circle, color: AppColors.green)
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Paid: ${CurrencyFormatter.formatSimple(loan.amountPaid, sym)}',
                                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                                  ),
                                  Text(
                                    'Total: ${CurrencyFormatter.formatSimple(loan.amount, sym)}',
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.brown),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              LinearProgressIndicator(
                                value: progress,
                                backgroundColor: Colors.grey.shade300,
                                color: isCompleted ? AppColors.green : (widget.initialType == 'loan' ? const Color(0xFFD84315) : AppColors.purple),
                                minHeight: 8,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    '${(progress * 100).toStringAsFixed(0)}% Completed',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: isCompleted ? AppColors.green : Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

}
