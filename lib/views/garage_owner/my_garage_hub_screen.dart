import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/garage_owner_provider.dart';
import '../../core/constants/app_colors.dart';
import 'garage_vehicles_screen.dart';
import 'garage_room_auth_screen.dart';
import 'garage_inventory_screen.dart';
import 'garage_payroll_screen.dart';
import 'garage_analytics_screen.dart';

class MyGarageHubScreen extends StatefulWidget {
  const MyGarageHubScreen({super.key});

  @override
  State<MyGarageHubScreen> createState() => _MyGarageHubScreenState();
}

class _MyGarageHubScreenState extends State<MyGarageHubScreen> {
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final prov = Provider.of<GarageOwnerProvider>(context, listen: false);
    await prov.checkExistingGarage();
    if (mounted) {
      setState(() {
        _isChecking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final garageProv = Provider.of<GarageOwnerProvider>(context);

    if (garageProv.garageId == null) {
      return const GarageRoomAuthScreen();
    }

    // Role Approval check
    if (garageProv.role == 'Pending') {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Pending Approval'),
          backgroundColor: AppColors.brown,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.exit_to_app),
              onPressed: () async {
                await garageProv.leaveGarage();
              },
            ),
          ],
        ),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Text(
              'Your request to join this Garage is pending admin approval.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
          ),
        ),
      );
    }

    final pending =
        garageProv.vehicles.where((v) => v.status == 'Pending').length;
    final repairing =
        garageProv.vehicles.where((v) => v.status == 'Repairing').length;
    final ready = garageProv.vehicles.where((v) => v.status == 'Ready').length;

    return Scaffold(
      appBar: AppBar(
        title: Text(garageProv.garageName ?? 'My Garage', style: const TextStyle(color: Colors.white)),
        backgroundColor: AppColors.brown,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app, color: Colors.white),
            onPressed: () async {
              await garageProv.leaveGarage();
            },
          )
        ],
      ),
      body: garageProv.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Room Code Badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.brown.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Room Code: ${garageProv.garageId}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.brown,
                          letterSpacing: 2.0),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                            context,
                            'Pending',
                            pending.toString(),
                            AppColors.orange,
                            Icons.hourglass_empty),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(context, 'Repairing',
                            repairing.toString(), AppColors.blue, Icons.build),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                            context,
                            'Ready',
                            ready.toString(),
                            AppColors.green,
                            Icons.check_circle),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ListTile(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: Colors.grey.shade300)),
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.brown,
                      child: Icon(Icons.directions_car, color: Colors.white),
                    ),
                    title: const Text('Manage Vehicles',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('Add repair jobs & update status'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const GarageVehiclesScreen()));
                    },
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: Colors.grey.shade300)),
                    leading: const CircleAvatar(
                      backgroundColor: Colors.teal,
                      child: Icon(Icons.build, color: Colors.white),
                    ),
                    title: const Text('Parts & Inventory',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('Manage stock & prices'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const GarageInventoryScreen()));
                    },
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: Colors.grey.shade300)),
                    leading: const CircleAvatar(
                      backgroundColor: Colors.orange,
                      child: Icon(Icons.bar_chart, color: Colors.white),
                    ),
                    title: const Text('Analytics & Reports',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('Revenue, expenses & profit'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const GarageAnalyticsScreen()));
                    },
                  ),
                  // If Admin, show employee management
                  if (garageProv.role == 'Admin') ...[
                    const SizedBox(height: 16),
                    ListTile(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: Colors.grey.shade300)),
                      leading: const CircleAvatar(
                        backgroundColor: Colors.indigo,
                        child: Icon(Icons.monetization_on, color: Colors.white),
                      ),
                      title: const Text('Mechanic Payroll',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: const Text('Track commissions'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const GaragePayrollScreen()));
                      },
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: Colors.grey.shade300)),
                      leading: const CircleAvatar(
                        backgroundColor: Colors.blueGrey,
                        child: Icon(Icons.people, color: Colors.white),
                      ),
                      title: const Text('Manage Mechanics',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: const Text('Approve or remove mechanics'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        _showEmployeesDialog(context, garageProv);
                      },
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  void _showEmployeesDialog(BuildContext context, GarageOwnerProvider prov) {
    showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: const Text('Manage Mechanics'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: prov.employees.length,
                itemBuilder: (context, index) {
                  final emp = prov.employees[index];
                  return ListTile(
                    title: Text(emp.name),
                    subtitle: Text(emp.role),
                    trailing: emp.role == 'Pending'
                        ? IconButton(
                            icon: const Icon(Icons.check_circle,
                                color: Colors.green),
                            onPressed: () {
                              prov.updateEmployeeRole(emp.name, 'Mechanic');
                              Navigator.pop(ctx);
                            },
                          )
                        : null,
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Close'),
              )
            ],
          );
        });
  }

  Widget _buildStatCard(BuildContext context, String title, String count,
      Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(count,
              style: TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          Text(title,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color.withValues(alpha: 0.8))),
        ],
      ),
    );
  }
}
