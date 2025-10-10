import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../core/constants/currencies.dart';
import '../../../core/di/di.dart';
import '../../../core/theme/theme_cubit.dart';
import '../../../core/utils/date_format_helper.dart';
import '../../onboarding/domain/entities/user_profile.dart';
import '../../onboarding/domain/repositories/user_profile_repository.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  void _showDateFormatDialog(BuildContext context, UserProfile profile) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Date Format'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: DateFormatHelper.allFormats.map((format) {
            final exampleDate = DateTime(2025, 10, 25);
            final example = DateFormatHelper.formatDate(exampleDate, format);

            return RadioListTile<DateFormatPattern>(
              title: Text(format.displayName),
              subtitle: Text('Example: $example'),
              value: format,
              groupValue: DateFormatPattern.fromString(profile.dateFormat),
              onChanged: (value) async {
                if (value != null) {
                  final updatedProfile = UserProfile(
                    id: profile.id,
                    name: profile.name,
                    currencyCode: profile.currencyCode,
                    dateFormat: value.pattern,
                    createdAt: profile.createdAt,
                  );

                  await getIt<UserProfileRepository>().saveUserProfile(updatedProfile);

                  if (context.mounted) {
                    Navigator.of(context).pop();
                    // Refresh the page
                    setState(() {});
                  }
                }
              },
              contentPadding: EdgeInsets.zero,
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: FutureBuilder(
        future: getIt<UserProfileRepository>().getUserProfile(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final result = snapshot.data;
          final profile = result?.data;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Profile',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        leading: const Icon(Icons.person),
                        title: const Text('Name'),
                        subtitle: Text(profile?.name ?? 'Not set'),
                        contentPadding: EdgeInsets.zero,
                      ),
                      ListTile(
                        leading: const Icon(Icons.attach_money),
                        title: const Text('Currency'),
                        subtitle: Text(
                          profile != null
                              ? '${Currencies.getByCode(profile.currencyCode)?.symbol ?? ''} ${profile.currencyCode}'
                              : 'Not set',
                        ),
                        contentPadding: EdgeInsets.zero,
                      ),
                      ListTile(
                        leading: const Icon(Icons.calendar_today),
                        title: const Text('Date Format'),
                        subtitle: Text(
                          profile != null
                              ? DateFormatPattern.fromString(profile.dateFormat).displayName
                              : 'Not set',
                        ),
                        contentPadding: EdgeInsets.zero,
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: profile != null
                            ? () => _showDateFormatDialog(context, profile)
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Appearance',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      BlocBuilder<ThemeCubit, AppThemeMode>(
                        builder: (context, currentTheme) {
                          return Column(
                            children: [
                              RadioListTile<AppThemeMode>(
                                title: const Row(
                                  children: [
                                    Icon(Icons.phone_android),
                                    SizedBox(width: 16),
                                    Text('System'),
                                  ],
                                ),
                                subtitle: const Text('Follow system theme'),
                                value: AppThemeMode.system,
                                groupValue: currentTheme,
                                onChanged: (value) {
                                  if (value != null) {
                                    context.read<ThemeCubit>().setTheme(value);
                                  }
                                },
                                contentPadding: EdgeInsets.zero,
                              ),
                              RadioListTile<AppThemeMode>(
                                title: const Row(
                                  children: [
                                    Icon(Icons.light_mode),
                                    SizedBox(width: 16),
                                    Text('Light'),
                                  ],
                                ),
                                subtitle: const Text('Always use light theme'),
                                value: AppThemeMode.light,
                                groupValue: currentTheme,
                                onChanged: (value) {
                                  if (value != null) {
                                    context.read<ThemeCubit>().setTheme(value);
                                  }
                                },
                                contentPadding: EdgeInsets.zero,
                              ),
                              RadioListTile<AppThemeMode>(
                                title: const Row(
                                  children: [
                                    Icon(Icons.dark_mode),
                                    SizedBox(width: 16),
                                    Text('Dark'),
                                  ],
                                ),
                                subtitle: const Text('Always use dark theme'),
                                value: AppThemeMode.dark,
                                groupValue: currentTheme,
                                onChanged: (value) {
                                  if (value != null) {
                                    context.read<ThemeCubit>().setTheme(value);
                                  }
                                },
                                contentPadding: EdgeInsets.zero,
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Manage',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        leading: const Icon(Icons.category),
                        title: const Text('Categories'),
                        subtitle: const Text('Manage your transaction categories'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        contentPadding: EdgeInsets.zero,
                        onTap: () => context.push('/categories'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'About',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      FutureBuilder<PackageInfo>(
                        future: PackageInfo.fromPlatform(),
                        builder: (context, snapshot) {
                          final version = snapshot.hasData
                              ? snapshot.data!.version
                              : 'Loading...';
                          return ListTile(
                            leading: const Icon(Icons.info_outline),
                            title: const Text('Version'),
                            subtitle: Text(version),
                            contentPadding: EdgeInsets.zero,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}