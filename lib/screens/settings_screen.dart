import 'package:carelog/models/theme_notifier.dart';
import 'package:flutter/material.dart';
import 'package:carelog/services/auth_service.dart'; // Import the AuthService
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Future<void> _signInWithGoogle() async {
    try {
      final userCredential = await AuthService().signInWithGoogle();

      if (userCredential != null) {
        print("Signed in with Google!");
        await AuthService().synchronizeData(); // Synchronize data after sign-in
      }
    } catch (e) {
      print(e); // Handle errors appropriately
    }
  }

  void rateApp() async {
    final Uri url = Uri.parse(
      'https://play.google.com/store/apps/details?id=de.lenazeise.carelog',
    );
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  void contactUs() async {
    final Uri url = Uri.parse('mailto:carelog@jelestudios.de');
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  void openPlayStore() async {
    final Uri url = Uri.parse(
      'https://play.google.com/store/apps/developer?id=jelestudios',
    );
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  void openWeb() async {
    final Uri url = Uri.parse('https://jelestudios.de');
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  void termsOfService() async {
    final Uri url = Uri.parse('https://carelog.jelestudios.de/terms');
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  void privacyPolicy() async {
    final Uri url = Uri.parse('https://carelog.jelestudios.de/privacy');
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final colorSchemes = {
      'Pink': Colors.pink[300]!,
      'Purple': Colors.purple[300]!,
      'Blue': Colors.blue,
      // 'Grey': Colors.grey[200]!,
      'Beige': Colors.brown[200]!,
    };

    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          Text(
            'Personalization',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 20),
          Text('Font Size: ${themeNotifier.fontSize.toStringAsFixed(1)}'),
          Slider(
            value: themeNotifier.fontSize,
            min: 12.0,
            max: 24.0,
            divisions: 6,
            label: themeNotifier.fontSize.round().toString(),
            onChanged: (double value) {
              themeNotifier.setFontSize(value);
            },
          ),
          const SizedBox(height: 20),
          const Text('Color Scheme'),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children:
                colorSchemes.entries.map((entry) {
                  final colorName = entry.key;
                  final color = entry.value;
                  final isSelected = themeNotifier.colorScheme == colorName;

                  return GestureDetector(
                    onTap: () => themeNotifier.setColorScheme(colorName),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(8),
                        border:
                            isSelected
                                ? Border.all(color: Colors.black, width: 2)
                                : null,
                      ),
                    ),
                  );
                }).toList(),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Text('Dark Mode'),
              Switch(
                value: themeNotifier.isDarkMode,
                onChanged: (bool value) {
                  themeNotifier.setDarkMode(value);
                },
                thumbColor: WidgetStateProperty.all(
                  themeNotifier.isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          Text('User data', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 20),
          Text(
            'If you want to save your data across devices, please sign in with Google',
          ),
          Center(
            child: ElevatedButton(
              onPressed: _signInWithGoogle,
              child: const Text('Sign in with Google'),
            ),
          ),
          const SizedBox(height: 40),
          Text('Feedback', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 20),
          Row(
            children: [
              TextButton(
                onPressed: rateApp,
                child: const Text('Rate this app'),
              ),
              TextButton(onPressed: contactUs, child: const Text('Contact Us')),
            ],
          ),

          const SizedBox(height: 40),
          Text('Information', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 20),
          Row(
            children: [
              TextButton(
                onPressed: openPlayStore,
                child: const Text('Other apps'),
              ),
              TextButton(onPressed: openWeb, child: const Text('Our website')),
            ],
          ),

          const SizedBox(height: 20),
          Row(
            children: [
              TextButton(
                onPressed: termsOfService,
                child: const Text('Terms of Service'),
              ),
              TextButton(
                onPressed: privacyPolicy,
                child: const Text('Privacy Policy'),
              ),
            ],
          ),

          const Text('Version: 1.0.0'),
        ],
      ),
    );
  }
}
