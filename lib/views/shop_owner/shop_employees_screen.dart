import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/shop_owner_provider.dart';

class ShopEmployeesScreen extends StatefulWidget {
  const ShopEmployeesScreen({super.key});

  @override
  State<ShopEmployeesScreen> createState() => _ShopEmployeesScreenState();
}

class _ShopEmployeesScreenState extends State<ShopEmployeesScreen> {
  void _showChangeRoleDialog(String employeeId, String employeeName, String currentRole) {
    String selectedRole = currentRole;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Change Role for $employeeName'),
              content: DropdownButtonFormField<String>(
                value: selectedRole,
                decoration: const InputDecoration(labelText: 'Role'),
                items: ['Admin', 'Staff']
                    .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => selectedRole = v);
                },
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () async {
                    if (selectedRole != currentRole) {
                      final prov = Provider.of<ShopOwnerProvider>(context, listen: false);
                      await prov.updateEmployeeRole(employeeId, selectedRole);
                    }
                    if (mounted) Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, foregroundColor: Colors.white),
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildEmployeeCard(dynamic emp, bool isAdmin) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: emp.role == 'Admin' ? Colors.deepPurple : Colors.purple.shade200,
          child: const Icon(Icons.badge, color: Colors.white),
        ),
        title: Text(emp.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${emp.phone}\nRole: ${emp.role}'),
        isThreeLine: true,
        trailing: (isAdmin && emp.id != null)
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _showChangeRoleDialog(emp.id!, emp.name, emp.role),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Remove Employee?'),
                          content: Text('Are you sure you want to remove ${emp.name}?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                            TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Remove', style: TextStyle(color: Colors.red))),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        await Provider.of<ShopOwnerProvider>(context, listen: false).removeEmployee(emp.id!);
                      }
                    },
                  ),
                ],
              )
            : null,
      ),
    );
  }

  Widget _buildRequestCard(dynamic emp, bool isAdmin) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.orange.shade50,
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.orange,
          child: Icon(Icons.person_add, color: Colors.white),
        ),
        title: Text(emp.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: const Text('Wants to join the shop'),
        trailing: isAdmin
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    tooltip: 'Reject',
                    onPressed: () async {
                      if (emp.id != null) {
                        await Provider.of<ShopOwnerProvider>(context, listen: false).removeEmployee(emp.id!);
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.check, color: Colors.green),
                    tooltip: 'Approve',
                    onPressed: () async {
                      if (emp.id != null) {
                        await Provider.of<ShopOwnerProvider>(context, listen: false).updateEmployeeRole(emp.id!, 'Staff');
                      }
                    },
                  ),
                ],
              )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<ShopOwnerProvider>(context);
    final isAdmin = prov.role == 'Admin';

    final activeEmployees = prov.employees.where((e) => e.role != 'Pending').toList();
    final pendingRequests = prov.employees.where((e) => e.role == 'Pending').toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Employees'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: prov.employees.isEmpty
          ? const Center(child: Text('No employees yet.'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (pendingRequests.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text('Join Requests', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange)),
                  ),
                  ...pendingRequests.map((emp) => _buildRequestCard(emp, isAdmin)),
                  const Divider(height: 32),
                ],
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text('Active Employees', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.purple)),
                ),
                if (activeEmployees.isEmpty)
                  const Text('No active employees.', style: TextStyle(color: Colors.grey))
                else
                  ...activeEmployees.map((emp) => _buildEmployeeCard(emp, isAdmin)),
              ],
            ),
    );
  }
}
