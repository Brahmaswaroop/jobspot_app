import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:jobspot_app/core/theme/app_theme.dart';
import 'package:jobspot_app/core/utils/supabase_service.dart';
import 'package:jobspot_app/data/services/profile_service.dart';
import 'package:jobspot_app/features/profile/presentation/widgets/edit_business_profile_dialog.dart';
import 'package:provider/provider.dart';

class EmployerProfileView extends StatefulWidget {
  const EmployerProfileView({super.key});

  @override
  State<StatefulWidget> createState() => _EmployerProfileViewState();
}

class _EmployerProfileViewState extends State<EmployerProfileView> {
  Map<String, dynamic>? _profile;

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    try {
      final user = SupabaseService.getCurrentUser();
      if (user != null) {
        _profile = await ProfileService.fetchEmployerProfile(user.id);
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        print(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('error'.tr(args: [e.toString()]))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Company Header
          const SizedBox(height: 20),
          CircleAvatar(
            radius: 50,
            backgroundColor: colorScheme.primary,
            child: const Icon(Icons.business, size: 50, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text(
            _profile?['company_name'] ?? '',
            style: textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          Text(
            '${_profile?['industry'] ?? ''} • + ${_profile?['city'] ?? ''}',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),

          // Business Info Section
          _buildSectionHeader(context, 'Business Information'),
          const SizedBox(height: 12),
          _buildInfoTile(context, Icons.language, 'Website', 'www.google.com'),
          _buildInfoTile(
            context,
            Icons.email_outlined,
            'Email',
            _profile?['official_email'] ?? '',
          ),
          _buildInfoTile(
            context,
            Icons.phone_outlined,
            'Phone',
            _profile?['contact_mobile'] ?? '',
          ),
          _buildInfoTile(
            context,
            Icons.location_on_outlined,
            'Address',
            _profile?['address'] ?? '',
          ),

          const SizedBox(height: 32),

          // Settings Section
          _buildSectionHeader(context, 'Settings'),
          const SizedBox(height: 12),
          _buildMenuTile(
            context,
            Icons.settings_display,
            'Dark Mode',
            () {},
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                        return ScaleTransition(
                          scale: animation,
                          child: FadeTransition(
                            opacity: animation,
                            child: child,
                          ),
                        );
                      },
                  child: Icon(
                    themeNotifier.isDarkMode
                        ? Icons.dark_mode
                        : Icons.light_mode,
                    key: ValueKey<bool>(themeNotifier.isDarkMode),
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Switch(
                  value: themeNotifier.isDarkMode,
                  activeThumbColor: colorScheme.primary,
                  onChanged: (value) {
                    themeNotifier.setThemeMode(
                      value ? ThemeMode.dark : ThemeMode.light,
                    );
                  },
                ),
              ],
            ),
          ),

          _buildMenuTile(
            context,
            Icons.edit_outlined,
            'Edit Business Profile',
            () {
              showDialog(
                context: context,
                builder: (context) =>
                    EditBusinessProfileDialog(profile: _profile),
              );
            },
          ),
          _buildMenuTile(
            context,
            Icons.notifications_none,
            'Notification Settings',
            () {},
          ),
          _buildMenuTile(
            context,
            Icons.security_outlined,
            'Security & Password',
            () {},
          ),
          _buildMenuTile(context, Icons.help_outline, 'Help & Support', () {}),

          const SizedBox(height: 32),

          // Logout Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                try {
                  await SupabaseService.signOut();
                } catch (e) {
                  messenger.showSnackBar(
                    SnackBar(content: Text('Error signing out: $e')),
                  );
                }
              },
              icon: Icon(Icons.logout, color: colorScheme.error),
              label: Text(
                'Log Out',
                style: TextStyle(color: colorScheme.error),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(color: colorScheme.error),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildInfoTile(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: colorScheme.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap, {
    Widget? trailing,
  }) {
    final theme = Theme.of(context);
    return Card(
      elevation: 1,
      color: theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: theme.colorScheme.primary),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface,
          ),
        ),
        trailing:
            trailing ??
            Icon(
              Icons.chevron_right,
              size: 20,
              color: theme.colorScheme.onSurfaceVariant,
            ),
        onTap: trailing == null ? onTap : null,
      ),
    );
  }
}
