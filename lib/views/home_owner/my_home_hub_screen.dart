import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/home_owner_provider.dart';
import '../../core/constants/app_colors.dart';
import 'apartment_profile_screen.dart';
import 'add_apartment_dialog.dart';
import 'package:intl/intl.dart';

class MyHomeHubScreen extends StatefulWidget {
  const MyHomeHubScreen({super.key});

  @override
  State<MyHomeHubScreen> createState() => _MyHomeHubScreenState();
}

class _MyHomeHubScreenState extends State<MyHomeHubScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HomeOwnerProvider>(context, listen: false).loadApartments();
    });
  }

  void _showAddApartmentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => const AddApartmentDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final homeProv = Provider.of<HomeOwnerProvider>(context);
    final now = DateTime.now();
    final currentMonthKey = DateFormat('yyyy-MM').format(now);
    final monthName = DateFormat('MMMM yyyy').format(now);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('My Home Hub'),
        backgroundColor: AppColors.deepTeal,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddApartmentDialog(context),
        backgroundColor: AppColors.deepTeal,
        icon: const Icon(Icons.add, color: Colors.white),
        label:
            const Text('Add Apartment', style: TextStyle(color: Colors.white)),
      ),
      body: homeProv.isLoading
          ? const Center(child: CircularProgressIndicator())
          : homeProv.apartments.isEmpty
              ? _buildEmptyState(context)
              : Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      width: double.infinity,
                      color: AppColors.deepTeal.withValues(alpha: 0.1),
                      child: Column(
                        children: [
                          const Text(
                            'Rent Status for',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          Text(
                            monthName,
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.deepTeal),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: homeProv.apartments.length,
                        itemBuilder: (context, index) {
                          final appt = homeProv.apartments[index];
                          final isPaid =
                              appt.paidMonths.contains(currentMonthKey);

                          return Card(
                            elevation: 2,
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              leading: CircleAvatar(
                                backgroundColor: isPaid
                                    ? AppColors.green.withValues(alpha: 0.2)
                                    : AppColors.red.withValues(alpha: 0.2),
                                child: Icon(
                                  isPaid ? Icons.check_circle : Icons.cancel,
                                  color:
                                      isPaid ? AppColors.green : AppColors.red,
                                ),
                              ),
                              title: Text(
                                appt.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(appt.boarderName),
                                  Text(
                                    'Rent: ?${appt.rentAmount.toStringAsFixed(2)}',
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              trailing: const Icon(Icons.arrow_forward_ios,
                                  size: 16, color: Colors.grey),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ApartmentProfileScreen(
                                      apartment: appt,
                                      currentMonthKey: currentMonthKey,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.home_work_outlined, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No Apartments Yet',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add an apartment to manage your boarders.',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
