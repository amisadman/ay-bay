import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/shop_owner_provider.dart';
import '../../models/shop_owner_model.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../providers/theme_provider.dart';

class ShopLedgerScreen extends StatefulWidget {
  const ShopLedgerScreen({super.key});

  @override
  State<ShopLedgerScreen> createState() => _ShopLedgerScreenState();
}

class _ShopLedgerScreenState extends State<ShopLedgerScreen> {
  void _showAddLedgerDialog() {
    final titleCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    String type = 'Income';

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Entry'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleCtrl,
                      decoration: const InputDecoration(labelText: 'Description/Title'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: amountCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Amount'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: type,
                      decoration: const InputDecoration(labelText: 'Type'),
                      items: ['Income', 'Expense']
                          .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => type = v);
                      },
                    )
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () async {
                    final title = titleCtrl.text.trim();
                    final amt = double.tryParse(amountCtrl.text.trim()) ?? 0.0;
                    if (title.isNotEmpty && amt > 0) {
                      final prov = Provider.of<ShopOwnerProvider>(context, listen: false);
                      await prov.addLedgerEntry(
                        LedgerModel(
                          title: title,
                          amount: amt,
                          type: type,
                          date: DateTime.now().toIso8601String(),
                        ),
                      );
                      if (mounted) Navigator.pop(ctx);
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.vibrantGold, foregroundColor: Colors.white),
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showSaleDetails(SaleModel sale, String sym) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Sale Details'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Date: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(sale.date))}'),
                const SizedBox(height: 8),
                const Divider(),
                ...sale.items.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text('${item.productName} (x${item.quantity})')),
                      Text(CurrencyFormatter.formatSimple(item.price * item.quantity, sym)),
                    ],
                  ),
                )),
                const Divider(),
                if (sale.discount > 0)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Discount:', style: TextStyle(color: Colors.red)),
                      Text('- ${CurrencyFormatter.formatSimple(sale.discount, sym)}', style: const TextStyle(color: Colors.red)),
                    ],
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(CurrencyFormatter.formatSimple(sale.totalAmount, sym), style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Profit: ${CurrencyFormatter.formatSimple(sale.totalProfit, sym)}', style: const TextStyle(color: Colors.green, fontSize: 12)),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<ShopOwnerProvider>(context);
    final themeProv = Provider.of<ThemeProvider>(context);
    final sym = themeProv.currencySymbol;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Ledger & Logs'),
          backgroundColor: AppColors.vibrantGold,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Ledger'),
              Tab(text: 'Sales Logs'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Ledger
            Scaffold(
              body: prov.ledger.isEmpty
                  ? const Center(child: Text('No ledger entries.'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: prov.ledger.length,
                      itemBuilder: (context, index) {
                        final entry = prov.ledger.reversed.toList()[index];
                        final isIncome = entry.type == 'Income';
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isIncome ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                              child: Icon(isIncome ? Icons.arrow_downward : Icons.arrow_upward, color: isIncome ? Colors.green : Colors.red),
                            ),
                            title: Text(entry.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(entry.date))),
                            trailing: Text(
                              '${isIncome ? '+' : '-'} ${CurrencyFormatter.formatSimple(entry.amount, sym)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: isIncome ? Colors.green : Colors.red,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
              floatingActionButton: FloatingActionButton(
                onPressed: _showAddLedgerDialog,
                backgroundColor: AppColors.vibrantGold,
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ),

            // Tab 2: Sales
            prov.sales.isEmpty
                ? const Center(child: Text('No sales recorded yet.'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: prov.sales.length,
                    itemBuilder: (context, index) {
                      final sale = prov.sales.reversed.toList()[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Colors.blue,
                            child: Icon(Icons.receipt, color: Colors.white),
                          ),
                          title: Text('Sale #${sale.id?.substring(0, 5) ?? index}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(sale.date))),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                CurrencyFormatter.formatSimple(sale.totalAmount, sym),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              Text(
                                'Items: ${sale.items.length}',
                                style: const TextStyle(fontSize: 10, color: Colors.grey),
                              ),
                            ],
                          ),
                          onTap: () => _showSaleDetails(sale, sym),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
