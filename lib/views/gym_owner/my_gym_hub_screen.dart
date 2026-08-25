import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/gym_owner_provider.dart';
import '../../core/constants/app_colors.dart';
import 'gym_members_screen.dart';
import 'gym_room_auth_screen.dart';
import 'gym_trainer_dashboard.dart';
import 'gym_analytics_screen.dart';

class MyGymHubScreen extends StatefulWidget {
  const MyGymHubScreen({super.key});

  @override
  State<MyGymHubScreen> createState() => _MyGymHubScreenState();
}

class _MyGymHubScreenState extends State<MyGymHubScreen> {
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final prov = Provider.of<GymOwnerProvider>(context, listen: false);
    await prov.checkExistingGym();
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

    final gymProv = Provider.of<GymOwnerProvider>(context);

    if (gymProv.gymId == null) {
      return const GymRoomAuthScreen();
    }

    if (gymProv.role == 'Pending') {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Pending Approval'),
          backgroundColor: AppColors.blue,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.exit_to_app),
              onPressed: () async {
                await gymProv.leaveGym();
              },
            ),
          ],
        ),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Text(
              'Your request to join this Gym is pending admin approval.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
          ),
        ),
      );
    }

    final activeCount =
        gymProv.members.where((m) => m.status == 'Active').length;
    final expiredCount =
        gymProv.members.where((m) => m.status == 'Expired').length;

    return Scaffold(
      appBar: AppBar(
        title: Text(gymProv.gymName ?? 'My Gym', style: const TextStyle(color: Colors.white)),
        backgroundColor: AppColors.blue,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app, color: Colors.white),
            onPressed: () async {
              await gymProv.leaveGym();
            },
          )
        ],
      ),
      body: gymProv.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Room Code: ${gymProv.gymId}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.blue,
                          letterSpacing: 2.0),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          context,
                          'Active Members',
                          activeCount.toString(),
                          AppColors.green,
                          Icons.check_circle_outline,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          context,
                          'Expired Plans',
                          expiredCount.toString(),
                          AppColors.red,
                          Icons.warning_amber_rounded,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ListTile(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: Colors.grey.shade300)),
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.blue,
                      child: Icon(Icons.people, color: Colors.white),
                    ),
                    title: const Text('Manage Members',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('Add, edit, or remove gym members'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const GymMembersScreen()));
                    },
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: Colors.grey.shade300)),
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.green,
                      child: Icon(Icons.bar_chart, color: Colors.white),
                    ),
                    title: const Text('Gym Analytics & Report',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('View revenue & export PDF'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const GymAnalyticsScreen()));
                    },
                  ),
                  if (gymProv.role == 'Admin') ...[
                    const SizedBox(height: 16),
                    ListTile(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: Colors.grey.shade300)),
                      leading: const CircleAvatar(
                        backgroundColor: Colors.blueGrey,
                        child: Icon(Icons.admin_panel_settings,
                            color: Colors.white),
                      ),
                      title: const Text('Manage Trainers',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: const Text('Approve or remove trainers'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        _showEmployeesDialog(context, gymProv);
                      },
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: Colors.grey.shade300)),
                      leading: const CircleAvatar(
                        backgroundColor: AppColors.orange,
                        child: Icon(Icons.sports, color: Colors.white),
                      ),
                      title: const Text('Trainer Dashboard',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: const Text('View assigned clients'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const GymTrainerDashboard()));
                      },
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  void _showEmployeesDialog(BuildContext context, GymOwnerProvider prov) {
    showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: const Text('Manage Trainers'),
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
                              prov.updateEmployeeRole(emp.name, 'Trainer');
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 12),
          Text(count,
              style: TextStyle(
                  fontSize: 28, fontWeight: FontWeight.bold, color: color)),
          Text(title,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color.withValues(alpha: 0.8))),
        ],
      ),
    );
  }
}
