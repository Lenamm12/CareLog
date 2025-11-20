import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../notifiers/locale_notifier.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.selectLanguage)),
      body: ListView(
        children: [
          ListTile(
            title: Text("${AppLocalizations.of(context)!.english} - english"),
            onTap: () {
              Provider.of<LocaleNotifier>(
                context,
                listen: false,
              ).setLocale(const Locale('en', ''));
            },
          ),
          ListTile(
            title: Text("${AppLocalizations.of(context)!.german} - deutsch"),
            onTap: () {
              Provider.of<LocaleNotifier>(
                context,
                listen: false,
              ).setLocale(const Locale('de', ''));
            },
          ),
        ],
      ),
    );
  }
}
