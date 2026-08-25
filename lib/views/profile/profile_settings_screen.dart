import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aybay_flutter/core/constants/app_colors.dart';
import 'package:aybay_flutter/providers/auth_provider.dart';
import 'package:aybay_flutter/providers/theme_provider.dart';
import 'package:aybay_flutter/providers/finance_provider.dart';
import 'package:aybay_flutter/views/navigation/main_navigation_screen.dart';
import 'package:aybay_flutter/services/update_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfileSettingsScreen extends StatelessWidget {
  const ProfileSettingsScreen({super.key});

  String getThemeName(int index) {
    switch (index) {
      case 0:
        return 'AyBay Green';
      case 1:
        return 'Ocean Blue';
      case 2:
        return 'Midnight Black';
      case 3:
        return 'Royal Purple';
      case 4:
        return 'Sunset Orange';
      case 5:
        return 'Van Gogh Starry Night';
      case 6:
        return 'Cartoon Pattern';
      default:
        return 'AyBay Green';
    }
  }

  void _showChangeCardThemeDialog(
      BuildContext context, ThemeProvider themeProv) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        height: 400,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text('Select Card Theme',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            ),
            Expanded(
              child: PageView.builder(
                controller: PageController(
                    viewportFraction: 0.8,
                    initialPage: themeProv.cardThemeIndex),
                itemCount: 7,
                onPageChanged: (index) => themeProv.setCardTheme(index),
                itemBuilder: (ctx, index) {
                  final isSelected = themeProv.cardThemeIndex == index;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: EdgeInsets.symmetric(
                        horizontal: 10, vertical: isSelected ? 20 : 40),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: index < 5 ? _getColorForTheme(index) : null,
                      image: index >= 5
                          ? DecorationImage(
                              image: AssetImage(index == 5
                                  ? 'assets/images/vangogh_card.jpg'
                                  : 'assets/images/cartoon_card.jpg'),
                              fit: BoxFit.cover,
                            )
                          : null,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 5))
                      ],
                    ),
                    child: Center(
                      child: Text(
                        getThemeName(index),
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Done', style: TextStyle(fontSize: 18)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Color _getColorForTheme(int index) {
    switch (index) {
      case 0:
        return AppColors.green;
      case 1:
        return const Color(0xFF1E88E5);
      case 2:
        return const Color(0xFF212121);
      case 3:
        return const Color(0xFF7B1FA2);
      case 4:
        return const Color(0xFFF57C00);
      default:
        return AppColors.green;
    }
  }

  void _showChangeNameDialog(BuildContext context, AuthProvider authProv) {
    final nameController = TextEditingController(text: authProv.userName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Change Username',
            style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold)),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(
            labelText: 'Enter your name',
            prefixIcon:
                Icon(Icons.person, color: Theme.of(context).iconTheme.color),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white),
            onPressed: () async {
              await authProv.changeUserName(nameController.text);
              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Username updated successfully!')),
                );
              }
            },
            child: const Text('Save Name'),
          ),
        ],
      ),
    );
  }

  void _showChangePinDialog(BuildContext context, AuthProvider authProv) {
    final pinController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Change Security PIN',
            style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold)),
        content: TextField(
          controller: pinController,
          keyboardType: TextInputType.number,
          obscureText: true,
          maxLength: 4,
          decoration: InputDecoration(
            labelText: 'Enter 4-digit PIN',
            prefixIcon:
                Icon(Icons.lock, color: Theme.of(context).iconTheme.color),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white),
            onPressed: () async {
              final success = await authProv.changePin(pinController.text);
              if (ctx.mounted) Navigator.pop(ctx);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(success
                          ? 'PIN updated successfully!'
                          : 'Invalid PIN (Min 4 digits)')),
                );
              }
            },
            child: const Text('Save PIN'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickProfileImage(
      BuildContext context, AuthProvider authProv) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      await authProv.setProfileImage(image.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProv = Provider.of<ThemeProvider>(context);
    final authProv = Provider.of<AuthProvider>(context);
    final finProv = Provider.of<FinanceProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios,
              color: Theme.of(context).iconTheme.color),
          onPressed: () => Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
              (route) => false),
        ),
        title: Text(
          'Settings',
          style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontWeight: FontWeight.bold,
              fontSize: 24),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: GestureDetector(
              onTap: () => _pickProfileImage(context, authProv),
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.brown,
                    backgroundImage: authProv.profileImagePath != null
                        ? FileImage(File(authProv.profileImagePath!))
                        : null,
                    child: authProv.profileImagePath == null
                        ? const Icon(Icons.person,
                            size: 48, color: Colors.white)
                        : null,
                  ),
                  const CircleAvatar(
                    radius: 14,
                    backgroundColor: AppColors.green,
                    child:
                        Icon(Icons.camera_alt, size: 14, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  authProv.userName,
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge?.color),
                ),
                IconButton(
                  icon: Icon(Icons.edit,
                      size: 20, color: Theme.of(context).colorScheme.primary),
                  onPressed: () => _showChangeNameDialog(context, authProv),
                )
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Divider(color: Colors.grey),

          // Security PIN Lock Switch
          SwitchListTile(
            secondary:
                Icon(Icons.security, color: Theme.of(context).iconTheme.color),
            title: const Text('Require PIN Lock on Launch',
                style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(authProv.isPinEnabled
                ? 'PIN Security is ON'
                : 'Bypass Login directly to App'),
            value: authProv.isPinEnabled,
            activeColor: Theme.of(context).colorScheme.primary,
            onChanged: (val) => authProv.togglePinEnabled(val),
          ),

          // Biometric Fingerprint Lock Switch
          SwitchListTile(
            secondary: Icon(Icons.fingerprint,
                color: Theme.of(context).iconTheme.color),
            title: const Text('Use Biometrics / Fingerprint',
                style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(authProv.isBiometricEnabled
                ? 'Biometrics ON'
                : 'Biometrics OFF'),
            value: authProv.isBiometricEnabled,
            activeColor: Theme.of(context).colorScheme.primary,
            onChanged: (val) => authProv.toggleBiometrics(val),
          ),

          // Change PIN Button
          ListTile(
            leading: Icon(Icons.lock_outline,
                color: Theme.of(context).iconTheme.color),
            title: const Text('Change Security PIN'),
            subtitle:
                const Text('Current PIN: ****'), // Don't show actual hashed PIN
            trailing: Icon(Icons.edit,
                size: 20, color: Theme.of(context).colorScheme.primary),
            onTap: () => _showChangePinDialog(context, authProv),
          ),
          const Divider(color: Colors.grey),

          // Currency Setting
          ListTile(
            leading: Icon(Icons.attach_money,
                color: Theme.of(context).colorScheme.primary),
            title: const Text('Currency'),
            subtitle: Text(themeProv.currencySymbol == '৳'
                ? 'Taka (৳ BDT)'
                : 'Dollar (\$ USD)'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              final newSym = themeProv.currencySymbol == '৳' ? '\$' : '৳';
              themeProv.setCurrency(newSym);
            },
          ),

          // Reset Balance Monthly
          SwitchListTile(
            secondary: Icon(Icons.calendar_today,
                color: Theme.of(context).iconTheme.color),
            title: const Text('Reset Balance Monthly',
                style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('Start fresh with a zero balance every month'),
            value: finProv.resetBalanceMonthly,
            activeColor: Theme.of(context).colorScheme.primary,
            onChanged: (val) => finProv.toggleResetBalanceMonthly(val),
          ),

          // Card Theme Setting
          ListTile(
            leading: Icon(Icons.credit_card,
                color: Theme.of(context).colorScheme.primary),
            title: const Text('Aybay Card Theme'),
            subtitle: Text(getThemeName(themeProv.cardThemeIndex)),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _showChangeCardThemeDialog(context, themeProv),
          ),

          // Dark Theme Setting
          SwitchListTile(
            secondary:
                const Icon(Icons.dark_mode, color: AppColors.vibrantGold),
            title: const Text('Dark Mode'),
            subtitle: const Text('Switch between light and dark themes'),
            value: themeProv.isDarkMode,
            activeColor: Theme.of(context).colorScheme.primary,
            onChanged: (val) => themeProv.toggleTheme(val),
          ),

          // Check for Updates
          ListTile(
            leading: Icon(Icons.system_update,
                color: Theme.of(context).colorScheme.primary),
            title: const Text('Check for Updates'),
            subtitle: const Text('Ensure you have the latest features'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () =>
                UpdateService.checkForUpdate(context, manualCheck: true),
          ),

          const Divider(color: Colors.grey),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text('Add-on Modules',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.grey)),
          ),

          // Home Owner Mode
          SwitchListTile(
            secondary: Icon(Icons.home_work,
                color: Theme.of(context).colorScheme.primary),
            title: const Text('My Home (Home Owner)'),
            subtitle: const Text('Manage apartments, boarders, and rent'),
            value: authProv.isHomeOwnerMode,
            activeColor: Theme.of(context).colorScheme.primary,
            onChanged: (val) => authProv.toggleHomeOwnerMode(val),
          ),

          // Shop Owner Mode
          SwitchListTile(
            secondary: Icon(Icons.storefront,
                color: Theme.of(context).colorScheme.primary),
            title: const Text('My Shop (Shop Owner)'),
            subtitle: const Text('Manage inventory, sales, and POS'),
            value: authProv.isShopOwnerMode,
            activeColor: Theme.of(context).colorScheme.primary,
            onChanged: (val) => authProv.toggleShopOwnerMode(val),
          ),

          // Subscription Mode
          SwitchListTile(
            secondary: Icon(Icons.subscriptions,
                color: Theme.of(context).colorScheme.primary),
            title: const Text('My Subscriptions'),
            subtitle: const Text('Track recurring bills and payments'),
            value: authProv.isSubscriptionMode,
            activeColor: Theme.of(context).colorScheme.primary,
            onChanged: (val) => authProv.toggleSubscriptionMode(val),
          ),

          // Gym Owner Mode
          SwitchListTile(
            secondary: Icon(Icons.fitness_center,
                color: Theme.of(context).colorScheme.primary),
            title: const Text('My Gym (Gym Owner)'),
            subtitle: const Text('Manage members and memberships'),
            value: authProv.isGymOwnerMode,
            activeColor: Theme.of(context).colorScheme.primary,
            onChanged: (val) => authProv.toggleGymOwnerMode(val),
          ),

          // Garage Owner Mode
          SwitchListTile(
            secondary: Icon(Icons.directions_car,
                color: Theme.of(context).colorScheme.primary),
            title: const Text('My Garage (Garage Owner)'),
            subtitle: const Text('Manage mechanic jobs and shop inventory'),
            value: authProv.isGarageOwnerMode,
            activeColor: Theme.of(context).colorScheme.primary,
            onChanged: (val) => authProv.toggleGarageOwnerMode(val),
          ),

          // Car Owner Mode
          SwitchListTile(
            secondary: Icon(Icons.time_to_leave,
                color: Theme.of(context).colorScheme.primary),
            title: const Text('My Car (Car Expenses)'),
            subtitle: const Text('Track fuel, maintenance, and car expenses'),
            value: authProv.isCarOwnerMode,
            activeColor: Theme.of(context).colorScheme.primary,
            onChanged: (val) => authProv.toggleCarOwnerMode(val),
          ),

          // Tuition Mode
          SwitchListTile(
            secondary: Icon(Icons.school,
                color: Theme.of(context).colorScheme.primary),
            title: const Text('Tuition Fees'),
            subtitle: const Text('Track personal or child tuition payments'),
            value: authProv.isTuitionMode,
            activeColor: Theme.of(context).colorScheme.primary,
            onChanged: (val) => authProv.toggleTuitionMode(val),
          ),

          const SizedBox(height: 100), // padding for bottom scrolling
        ],
      ),
    );
  }
}
