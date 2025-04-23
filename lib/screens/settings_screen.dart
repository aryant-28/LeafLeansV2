import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/language_model.dart';
import '../utils/app_localization.dart';
import 'reminder_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalization.of(context);
    final languageModel = Provider.of<LanguageModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localization?.translate('settings') ?? 'Settings'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.alarm),
              title: Text(localization?.translate('plant_reminders') ??
                  'Plant Reminders'),
              subtitle: Text(localization?.translate('set_daily_reminders') ??
                  'Set daily reminders to check your plants'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ReminderScreen(),
                  ),
                );
              },
            ),
          ),
          // Language section
          _buildSectionHeader(
              context, localization?.translate('language') ?? 'Language'),
          const SizedBox(height: 8),

          _buildLanguageOption(
            context,
            'English',
            'en',
            languageModel.currentLanguage == 'en',
            () => languageModel.changeLanguage('en'),
          ),

          _buildLanguageOption(
            context,
            'हिंदी (Hindi)',
            'hi',
            languageModel.currentLanguage == 'hi',
            () => languageModel.changeLanguage('hi'),
          ),

          _buildLanguageOption(
            context,
            'मराठी (Marathi)',
            'mr',
            languageModel.currentLanguage == 'mr',
            () => languageModel.changeLanguage('mr'),
          ),

          const SizedBox(height: 24),

          // About section
          _buildSectionHeader(
              context, localization?.translate('about') ?? 'About'),
          const SizedBox(height: 8),

          _buildInfoCard(
            context,
            title: localization?.translate('app_name') ?? 'LeafLens',
            description: localization?.translate('app_description') ??
                'AI-powered plant disease diagnostic tool',
            icon: Icons.eco,
          ),

          const SizedBox(height: 16),

          // Version info
          ListTile(
            title: Text(localization?.translate('version') ?? 'Version'),
            trailing: const Text('1.0.0'),
            dense: true,
          ),

          // AI models info
          ExpansionTile(
            title: Text(
                localization?.translate('ai_models_used') ?? 'AI Models Used'),
            tilePadding: EdgeInsets.zero,
            childrenPadding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              ListTile(
                title: const Text('ResNet-50'),
                subtitle: Text(localization?.translate('resnet_description') ??
                    'Deep residual network for image classification'),
                dense: true,
              ),
              ListTile(
                title: const Text('EfficientNet-B0'),
                subtitle: Text(localization
                        ?.translate('efficientnet_description') ??
                    'Compact convolutional neural network optimized for mobile'),
                dense: true,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Help section
          _buildSectionHeader(context,
              localization?.translate('help_support') ?? 'Help & Support'),
          const SizedBox(height: 8),

          ListTile(
            leading: const Icon(Icons.contact_support_outlined),
            title: Text(localization?.translate('contact_support') ??
                'Contact Support'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Open contact support page
            },
          ),

          ListTile(
            leading: const Icon(Icons.help_outline),
            title: Text(localization?.translate('how_to_use') ?? 'How to Use'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Open help guide
            },
          ),

          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: Text(
                localization?.translate('privacy_policy') ?? 'Privacy Policy'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Open privacy policy
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    String name,
    String code,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return ListTile(
      title: Text(name),
      trailing: isSelected
          ? Icon(
              Icons.check_circle,
              color: Theme.of(context).primaryColor,
            )
          : null,
      onTap: onTap,
      selected: isSelected,
      selectedTileColor: Theme.of(context).primaryColor.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Theme.of(context).primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
