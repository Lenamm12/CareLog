import 'package:carelog/screens/calender_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'l10n/app_localizations.dart';
import 'notifiers/locale_notifier.dart';
import 'screens/products_screen.dart';
import 'screens/routines_screen.dart';
import 'screens/settings_screen.dart';
import 'notifiers/theme_notifier.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final themeNotifier = ThemeNotifier();
  await themeNotifier.loadTheme();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
        ChangeNotifierProvider(create: (_) => LocaleNotifier()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, child) {
        return MaterialApp(
          title: 'Carelog',
          theme: themeNotifier.currentTheme,
          home: const MainScreen(),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''), // English, no country code
            Locale('de', ''), // German, no country code
          ],
        );
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    ProductsScreen(),
    RoutinesScreen(),
    CalendarScreen(),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Consumer2<ThemeNotifier, LocaleNotifier>(
      builder: (context, themeNotifier, locale, child) {
        return Scaffold(
          body: Center(child: _widgetOptions.elementAt(_selectedIndex)),
          bottomNavigationBar: BottomNavigationBar(
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.shopping_bag),
                label: l10n.products,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.list),
                label: l10n.routines,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.calendar_month),
                label: l10n.calendar,
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: l10n.settings,
              ),
            ],
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            backgroundColor:
                themeNotifier.isDarkMode ? Colors.black : Colors.white,
            selectedItemColor:
                themeNotifier.isDarkMode ? Colors.white : Colors.black,
            unselectedItemColor: Colors.grey,
          ),
        );
      },
    );
  }
}
