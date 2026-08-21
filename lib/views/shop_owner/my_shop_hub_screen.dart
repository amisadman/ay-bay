import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/shop_owner_provider.dart';
import '../../core/constants/app_colors.dart';
import 'inventory_screen.dart';
import 'pos_screen.dart';
import 'shop_analytics_screen.dart';
import 'shop_room_auth_screen.dart';
import 'shop_customers_screen.dart';
import 'shop_employees_screen.dart';
import 'shop_ledger_screen.dart';
import 'package:flutter/services.dart';

class MyShopHubScreen extends StatefulWidget {
  const MyShopHubScreen({super.key});

  @override
  State<MyShopHubScreen> createState() => _MyShopHubScreenState();
}

class _MyShopHubScreenState extends State<MyShopHubScreen> {
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final prov = Provider.of<ShopOwnerProvider>(context, listen: false);
    await prov.checkExistingShop();
    if (mounted) {
      setState(() {
        _isChecking = false;
      });
    }
  }

  Widget _buildDashboardButton(BuildContext context, String title, IconData icon, Color color, Widget destination) {
    return InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => destination));
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final prov = Provider.of<ShopOwnerProvider>(context);
    
    if (prov.shopId == null) {
      return const ShopRoomAuthScreen();
    }

    if (prov.role == 'Pending') {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Pending Approval'),
          backgroundColor: AppColors.orange,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.exit_to_app),
              onPressed: () async {
                await prov.leaveShop();
              },
            ),
          ],
        ),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Text(
              'Your join request has been sent!\n\nPlease wait for an Admin to approve your request before you can access the shop.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${prov.shopName} (${prov.role})'),
        backgroundColor: AppColors.orange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Room Code'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Your shop room code is:\n\n${prov.shopId}\n\nShare this code with employees so they can join the shop.', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.copy),
                        label: const Text('Copy Code'),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: prov.shopId!));
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Code copied!')));
                        },
                      ),
                    ],
                  ),
                  actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK'))],
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () async {
              await prov.leaveShop();
            },
          ),
        ],
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(20),
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          _buildDashboardButton(context, 'POS Checkout', Icons.point_of_sale, AppColors.orange, const POSScreen()),
          _buildDashboardButton(context, 'Inventory', Icons.inventory_2, AppColors.deepTeal, const InventoryScreen()),
          _buildDashboardButton(context, 'Customers', Icons.people, Colors.green, const ShopCustomersScreen()),
          _buildDashboardButton(context, 'Ledger', Icons.book, AppColors.vibrantGold, const ShopLedgerScreen()),
          _buildDashboardButton(context, 'Analytics', Icons.analytics, Colors.blue, const ShopAnalyticsScreen()),
          _buildDashboardButton(context, 'Employees', Icons.badge, Colors.purple, const ShopEmployeesScreen()),
        ],
      ),
    );
  }
}
