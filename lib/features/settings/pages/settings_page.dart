import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/currencies.dart';
import '../../../core/di/di.dart';
import '../../../core/theme/theme_cubit.dart';
import '../../../core/utils/date_format_helper.dart';
import '../../../core/services/notification_service.dart';
import '../../onboarding/domain/entities/user_profile.dart';
import '../../onboarding/domain/repositories/user_profile_repository.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  static const String _notificationEnabledKey = 'daily_notification_enabled';
  static const String _notificationHourKey = 'notification_hour';
  static const String _notificationMinuteKey = 'notification_minute';

  bool _notificationsEnabled = true;
  TimeOfDay _selectedTime = const TimeOfDay(hour: 19, minute: 0); // Default 7:00 PM
  final _notificationService = getIt<NotificationService>();
  final _prefs = getIt<SharedPreferences>();

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
  }

  Future<void> _loadNotificationSettings() async {
    final enabled = _prefs.getBool(_notificationEnabledKey) ?? true;
    final hour = _prefs.getInt(_notificationHourKey) ?? 19;
    final minute = _prefs.getInt(_notificationMinuteKey) ?? 0;

    setState(() {
      _notificationsEnabled = enabled;
      _selectedTime = TimeOfDay(hour: hour, minute: minute);
    });
  }

  Future<void> _saveNotificationTime(TimeOfDay time) async {
    await _prefs.setInt(_notificationHourKey, time.hour);
    await _prefs.setInt(_notificationMinuteKey, time.minute);
    setState(() {
      _selectedTime = time;
    });

    // Reschedule notification with new time if enabled
    if (_notificationsEnabled) {
      await _notificationService.scheduleDailyReminder(
        hour: time.hour,
        minute: time.minute,
      );
    }
  }

  Future<void> _showTimePicker() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedTime) {
      await _saveNotificationTime(picked);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Reminder time updated to ${picked.format(context)}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  Future<void> _toggleNotifications(bool value) async {
    if (value) {
      // Check if we can schedule exact alarms before enabling
      final canSchedule = await _notificationService.canScheduleExactAlarms();

      if (!canSchedule) {
        // Show dialog to guide user to settings
        if (mounted) {
          final proceed = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Permission Required'),
              content: const Text(
                'This app needs permission to schedule exact alarms for daily reminders.\n\n'
                'Please allow "Alarms & reminders" permission in the next screen.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Open Settings'),
                ),
              ],
            ),
          );

          if (proceed != true) {
            return;
          }

          // Request exact alarm permission
          await _notificationService.requestExactAlarmPermission();
        }
      }
    }

    setState(() {
      _notificationsEnabled = value;
    });

    await _prefs.setBool(_notificationEnabledKey, value);

    if (value) {
      // Enable notifications
      await _notificationService.scheduleDailyReminder(
        hour: _selectedTime.hour,
        minute: _selectedTime.minute,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Daily reminders enabled at ${_formatTime(_selectedTime)}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } else {
      // Disable notifications
      await _notificationService.cancelAllNotifications();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Daily reminders disabled'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

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
                        'Notifications',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        secondary: const Icon(Icons.notifications_active),
                        title: const Text('Daily Reminders'),
                        subtitle: Text('Get reminded to add transactions ${_notificationsEnabled ? 'daily' : ''}'),
                        value: _notificationsEnabled,
                        onChanged: _toggleNotifications,
                        contentPadding: EdgeInsets.zero,
                      ),
                      if (_notificationsEnabled) ...[
                        const SizedBox(height: 8),
                        ListTile(
                          leading: const Icon(Icons.access_time),
                          title: const Text('Reminder Time'),
                          subtitle: Text(_formatTime(_selectedTime)),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          contentPadding: EdgeInsets.zero,
                          onTap: _showTimePicker,
                        ),
                      ],
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