import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../providers/gym_owner_provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../services/super_module_db_helper.dart';

class GymRoomAuthScreen extends StatefulWidget {
  const GymRoomAuthScreen({super.key});

  @override
  State<GymRoomAuthScreen> createState() => _GymRoomAuthScreenState();
}

class _GymRoomAuthScreenState extends State<GymRoomAuthScreen> {
  final _joinCtrl = TextEditingController();
  final _createCtrl = TextEditingController();

  Future<void> _joinGym() async {
    final code = _joinCtrl.text.trim().toUpperCase();
    if (code.isEmpty) return;

    final me = Provider.of<AuthProvider>(context, listen: false).userName ?? 'Unknown';
    final prov = Provider.of<GymOwnerProvider>(context, listen: false);
    prov.initGym(code, 'Gym Room $code', 'Pending', me);
    await SuperModuleDBHelper.instance.insertRoomHistory('Gym', code, 'Gym Room $code');
    _loadHistory();
  }

  Future<void> _createGym() async {
    final name = _createCtrl.text.trim();
    if (name.isEmpty) return;

    final code = const Uuid().v4().substring(0, 6).toUpperCase();
    final me = Provider.of<AuthProvider>(context, listen: false).userName ?? 'Unknown';
    final prov = Provider.of<GymOwnerProvider>(context, listen: false);
    prov.initGym(code, name, 'Admin', me);
    await SuperModuleDBHelper.instance.insertRoomHistory('Gym', code, name);
    _loadHistory();
  }

  List<Map<String, dynamic>> _recentRooms = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final history = await SuperModuleDBHelper.instance.getRoomHistory('Gym');
    setState(() {
      _recentRooms = history;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.fitness_center, size: 80, color: AppColors.blue),
              const SizedBox(height: 16),
              const Text('Gym Cloud Access',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const Text('Join an existing gym or create a new one.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 40),
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text('Join Existing Gym',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _joinCtrl,
                        decoration: const InputDecoration(
                            labelText: 'Room Code',
                            border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                              onPressed: _joinGym, child: const Text('Join')))
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text('OR',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 24),
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text('Create New Gym Room',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _createCtrl,
                        decoration: const InputDecoration(
                            labelText: 'Gym Name',
                            border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.blue,
                                  foregroundColor: Colors.white),
                              onPressed: _createGym,
                              child: const Text('Create')))
                    ],
                  ),
                ),
              ),
              if (_recentRooms.isNotEmpty) ...[
                const SizedBox(height: 40),
                const Text('Recent Rooms', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 16),
                ..._recentRooms.map((room) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const Icon(Icons.history, color: AppColors.blue),
                    title: Text(room['roomName']),
                    subtitle: Text('Code: ${room['roomCode']}'),
                    onTap: () {
                      _joinCtrl.text = room['roomCode'];
                      _joinGym();
                    },
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () async {
                        await SuperModuleDBHelper.instance.deleteRoomHistory('Gym', room['roomCode']);
                        _loadHistory();
                      },
                    ),
                  ),
                )).toList(),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
