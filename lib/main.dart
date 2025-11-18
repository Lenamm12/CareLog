import 'package:carelog/models/product.dart';
import 'package:carelog/models/routine.dart';
import 'package:carelog/models/theme_notifier.dart';
import 'package:carelog/screens/add_product_screen.dart';
import 'package:carelog/screens/add_routine_screen.dart';
import 'package:carelog/screens/calender_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'l10n/app_localizations.dart';
import 'screens/products_screen.dart';
import 'screens/routines_screen.dart';
import 'screens/settings_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final themeNotifier = ThemeNotifier();
  await themeNotifier.loadTheme(); // Load the theme

  runApp(
    ChangeNotifierProvider(
      create: (_) => themeNotifier,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, theme, child) {
        return MaterialApp(
          title: 'My Skincare',
          theme: theme.currentTheme,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'), // English
            Locale('de'), // German
          ],
          home: const MainScreen(),
          onGenerateRoute: (settings) {
            switch (settings.name) {
              case '/add_product':
                final args = settings.arguments as Product?;
                return MaterialPageRoute(
                  builder: (context) {
                    return AddProductScreen(product: args);
                  },
                );
              case '/add_routine':
                final args = settings.arguments as Routine?;
                return MaterialPageRoute(
                  builder: (context) {
                    return AddRoutineScreen(routine: args);
                  },
                );
              default:
                return null;
            }
          },
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

  final List<Widget> _screens = [
    const ProductsScreen(),
    const RoutinesScreen(),
    const CalendarScreen(),
    const SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: const Icon(Icons.shelves),
            label: l10n.products,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.list_alt),
            label: l10n.routines,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.calendar_today),
            label: l10n.calendar,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: l10n.settings,
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.black,
        selectedItemColor: themeNotifier.isDarkMode ? Colors.white : Colors.black,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}
