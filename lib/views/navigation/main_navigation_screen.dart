import 'package:flutter/material.dart';
import 'package:aybay_flutter/core/constants/app_colors.dart';
import 'package:aybay_flutter/views/dashboard/dashboard_screen.dart';
import 'package:aybay_flutter/views/filter/filter_screen.dart';
import 'package:aybay_flutter/views/profile/profile_settings_screen.dart';
import 'package:aybay_flutter/views/walleo_ai/walleo_ai_chat_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;
  const MainNavigationScreen({super.key, this.initialIndex = 0});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int _currentIndex;

  final List<Widget> _pages = const [
    DashboardScreen(),
    FilterScreen(),
    WalleoAIChatScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: IndexedStack(
          index: _currentIndex,
          children: _pages,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: AppColors.green,
        unselectedItemColor: Theme.of(context).textTheme.bodyLarge?.color ?? AppColors.brown,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 10,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          FocusManager.instance.primaryFocus?.unfocus();
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Dashboard',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.smart_toy_outlined),
            label: 'Walleo AI',
          ),
        ],
      ),
    );
  }
}
