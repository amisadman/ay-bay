import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aybay_flutter/core/constants/app_colors.dart';
import 'package:aybay_flutter/providers/cloud_event_provider.dart';
import 'package:aybay_flutter/providers/auth_provider.dart';
import 'package:aybay_flutter/models/cloud_event_model.dart';

import 'event_profile_screen.dart';

class EventsHubScreen extends StatefulWidget {
  const EventsHubScreen({super.key});

  @override
  State<EventsHubScreen> createState() => _EventsHubScreenState();
}

class _EventsHubScreenState extends State<EventsHubScreen> {
  final _joinCodeController = TextEditingController();
  final _createTitleController = TextEditingController();
  final _createDescController = TextEditingController();
  final _createBudgetController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Start listening to events when this screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProv = Provider.of<AuthProvider>(context, listen: false);
      final evProv = Provider.of<CloudEventProvider>(context, listen: false);
      // Generate a temporary UID if none exists (since we aren't enforcing Firebase Auth fully yet)
      final uid = authProv.userName
          .toLowerCase()
          .replaceAll(' ', '_'); // Just a fake UID for now
      evProv.listenToMyEvents(uid);
    });
  }

  void _showJoinDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          title: const Text('Join Event'),
          content: TextField(
            controller: _joinCodeController,
            decoration:
                const InputDecoration(labelText: 'Invite Code (e.g. A1B2C3)'),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('CANCEL')),
            ElevatedButton(
              onPressed: () async {
                final authProv =
                    Provider.of<AuthProvider>(context, listen: false);
                final evProv =
                    Provider.of<CloudEventProvider>(context, listen: false);
                final uid =
                    authProv.userName.toLowerCase().replaceAll(' ', '_');
                final success = await evProv.joinEvent(
                    _joinCodeController.text.trim().toUpperCase(), uid);
                if (mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(success
                        ? 'Successfully joined event!'
                        : 'Invalid code or event not found.'),
                  ));
                }
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.green,
                  foregroundColor: Colors.white),
              child: const Text('JOIN'),
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
          title: const Text('Create Event'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                    controller: _createTitleController,
                    decoration:
                        const InputDecoration(labelText: 'Event Title')),
                TextField(
                    controller: _createDescController,
                    decoration:
                        const InputDecoration(labelText: 'Description')),
                TextField(
                    controller: _createBudgetController,
                    decoration:
                        const InputDecoration(labelText: 'Total Budget'),
                    keyboardType: TextInputType.number),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('CANCEL')),
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
                  backgroundColor: AppColors.green,
                  foregroundColor: Colors.white),
              child: const Text('CREATE'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final evProv = Provider.of<CloudEventProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.brown,
        title: const Text('Events Hub', style: TextStyle(color: Colors.white)),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
        ),
      ),
      body: evProv.myEvents.isEmpty
          ? const Center(
              child: Text('No events yet. Join or create one!',
                  style: TextStyle(color: Colors.grey)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: evProv.myEvents.length,
              itemBuilder: (context, index) {
                final event = evProv.myEvents[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.vibrantGold,
                      child: Icon(Icons.event, color: Colors.white),
                    ),
                    title: Text(event.title,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18)),
                    subtitle: Text(
                        '${event.members.length} members • Code: ${event.inviteCode}'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  EventProfileScreen(event: event)));
                    },
                  ),
                );
              },
            ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'join',
            backgroundColor: AppColors.brown,
            onPressed: _showJoinDialog,
            child: const Icon(Icons.vpn_key, color: Colors.white),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'create',
            backgroundColor: AppColors.green,
            onPressed: _showCreateDialog,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
