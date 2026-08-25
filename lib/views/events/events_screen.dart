import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aybay_flutter/core/constants/app_colors.dart';
import 'package:aybay_flutter/providers/cloud_event_provider.dart';
import 'package:aybay_flutter/providers/auth_provider.dart';
import 'package:aybay_flutter/models/cloud_event_model.dart';
import 'package:aybay_flutter/providers/theme_provider.dart';
import 'package:aybay_flutter/core/utils/currency_formatter.dart';

import 'event_profile_screen.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final _joinCodeController = TextEditingController();
  final _createTitleController = TextEditingController();
  final _createDescController = TextEditingController();
  final _createBudgetController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProv = Provider.of<AuthProvider>(context, listen: false);
      final evProv = Provider.of<CloudEventProvider>(context, listen: false);
      final uid = authProv.userName.toLowerCase().replaceAll(' ', '_');
      evProv.listenToMyEvents(uid);
    });
  }

  void _showJoinDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          title: const Text('Join Event',
              style: TextStyle(
                  color: AppColors.brown, fontWeight: FontWeight.bold)),
          content: TextField(
            controller: _joinCodeController,
            decoration: InputDecoration(
              labelText: 'Invite Code (e.g. A1B2C3)',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final authProv =
                    Provider.of<AuthProvider>(context, listen: false);
                final evProv =
                    Provider.of<CloudEventProvider>(context, listen: false);
                final uid =
                    authProv.userName.toLowerCase().replaceAll(' ', '_');
                final result = await evProv.joinEvent(
                    _joinCodeController.text.trim().toUpperCase(), uid);
                if (mounted) {
                  Navigator.pop(ctx);
                  String message = 'Successfully joined event!';
                  if (result == 'not_found')
                    message = 'Invalid code or event not found.';
                  if (result == 'already_joined')
                    message = 'You are already a member of this event.';

                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(message),
                  ));
                }
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.black,
                  foregroundColor: Colors.white),
              child: const Text('Join'),
            ),
          ],
        );
      },
    );
  }

  void _showCreateDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          title: const Text('Create Event',
              style: TextStyle(
                  color: AppColors.brown, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _createTitleController,
                  decoration: InputDecoration(
                      labelText: 'Event Title',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12))),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _createDescController,
                  decoration: InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12))),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _createBudgetController,
                  decoration: InputDecoration(
                      labelText: 'Total Budget',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12))),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final authProv =
                    Provider.of<AuthProvider>(context, listen: false);
                final evProv =
                    Provider.of<CloudEventProvider>(context, listen: false);
                final uid =
                    authProv.userName.toLowerCase().replaceAll(' ', '_');
                final title = _createTitleController.text.trim();
                final desc = _createDescController.text.trim();
                final budget =
                    double.tryParse(_createBudgetController.text.trim()) ?? 0.0;
                if (title.isNotEmpty) {
                  await evProv.createEvent(title, desc, budget, uid);
                  if (mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Event Created!')));
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.black,
                  foregroundColor: Colors.white),
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final evProv = Provider.of<CloudEventProvider>(context);
    final themeProv = Provider.of<ThemeProvider>(context);
    final sym = themeProv.currencySymbol;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.brown,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Event Management',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 22)),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Expanded(
            child: evProv.myEvents.isEmpty
                ? const Center(
                    child: Text('No events yet. Join or create one!',
                        style: TextStyle(color: Colors.grey, fontSize: 16)))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: evProv.myEvents.length,
                    itemBuilder: (context, index) {
                      final event = evProv.myEvents[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      EventProfileScreen(event: event)));
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor:
                                        AppColors.brown.withOpacity(0.1),
                                    child: const Icon(Icons.event,
                                        color: AppColors.brown),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(event.title,
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Theme.of(context)
                                                        .textTheme
                                                        .bodyLarge
                                                        ?.color ??
                                                    AppColors.black)),
                                        Text(
                                            '${event.members.length} members • Code: ${event.inviteCode}',
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey)),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    CurrencyFormatter.formatSimple(
                                        event.budget, sym),
                                    style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.brown),
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
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            heroTag: 'join',
            backgroundColor: AppColors.brown,
            onPressed: _showJoinDialog,
            icon: const Icon(Icons.vpn_key, color: Colors.white),
            label: const Text('Join', style: TextStyle(color: Colors.white)),
          ),
          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'create',
            backgroundColor: AppColors.green,
            onPressed: _showCreateDialog,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text('Create', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
