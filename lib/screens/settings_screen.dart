import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';
import '../widgets/custom_text.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const CustomText(
          text: 'Settings',
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: SwitchListTile(
                // Enhancement 3: dark/light mode was moved from the home page
                // into this settings page.
                value: themeProvider.isDark,
                onChanged: (_) => themeProvider.toggleTheme(),
                secondary: Icon(
                  themeProvider.isDark
                      ? Icons.dark_mode_outlined
                      : Icons.light_mode_outlined,
                ),
                title: const CustomText(
                  text: 'Dark Mode',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
                subtitle: CustomText(
                  text: themeProvider.isDark
                      ? 'Using dark theme'
                      : 'Using light theme',
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
